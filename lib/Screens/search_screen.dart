import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';

import '../Widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String searchQuery = "";
  AudioPlayer _audioPlayer = AudioPlayer(); // Added audio player instance
  bool _isPlaying = false; // Flag to track playback state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('Transcribed Text').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No results found.'));
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Filter documents based on the search query
        List<DocumentSnapshot> filteredDocuments = searchQuery.isEmpty
            ? []
            : documents
                .where((document) => document['text']
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();

        return ListView.builder(
          itemCount: filteredDocuments.length,
          itemBuilder: (context, index) {
            String resultText = filteredDocuments[index]['text'];
            return GestureDetector(
              child: SearchResultCard(
                  resultText: resultText, searchQuery: searchQuery),
              onTap: () {
                print("++++++++++++++++++ ${filteredDocuments[index].id}");
                _playAudio(filteredDocuments[index].id);
              },
            );
          },
        );
      },
    );
  }

  void _playAudio(
    String docID,
  ) async {
    try {
      // Find the index of the underscore
      int underscoreIndex = docID.indexOf('_');

      // Extract the substring before the underscore
      String result =
          underscoreIndex != -1 ? docID.substring(0, underscoreIndex) : docID;

      // Save the result in a variable
      String newVariable = result;

      // Print the result or use it as needed
      print("%%%%%%%%%%%%%%%%%%%% $newVariable");
      String audioURL = await FirebaseStorage.instance
          .ref('Segmented Audios/$newVariable/$docID')
          .getDownloadURL();

      await _audioPlayer.setUrl(audioURL);
      _isPlaying = true; // Set initial state to playing
      _showBottomSheet();
      await _audioPlayer.play();
      print('Audio playing successfully');
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  void _showBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: Icon(Icons.fast_rewind),
                    onPressed: _seekBackward,
                  ),
                  IconButton(
                      icon: _isPlaying
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                      onPressed: () {
                        _togglePlayback();
                      }),
                  IconButton(
                    icon: Icon(Icons.fast_forward),
                    onPressed: _seekForward,
                  ),
                ],
              ),
              SizedBox(height: 16),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  _audioPlayer.stop();
                  Navigator.pop(context);
                },
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceAround,
              //   children: [
              //     // Text(fileName),

              //   ],
              // )
            ],
          ),
        );
      },
    );
  }

  void _seekForward() {
    _audioPlayer.seek(_audioPlayer.position + Duration(seconds: 10));
    print('Seek forward 10 seconds');
  }

  void _seekBackward() {
    _audioPlayer.seek(_audioPlayer.position - Duration(seconds: 10));
    print('Seek backward 10 seconds');
  }

  Future<void> _togglePlayback() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
    setState(() {
      _isPlaying = !_isPlaying; // Toggle the playback state
    });
  }
}
