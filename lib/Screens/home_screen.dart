import 'dart:async';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:voicescribe/Screens/search_screen.dart';
import 'package:voicescribe/Utils/global_configs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'upload_audio_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  AudioPlayer _audioPlayer = AudioPlayer(); // Added audio player instance
  bool _isPlaying = false; // Flag to track playback state

  @override
  void dispose() {
    _audioPlayer.dispose();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: GlobalConfigs.Appbar_Name),
        backgroundColor: CustomColors.AppBar_Bg_Theme1,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // 1st children
          GestureDetector(
            child: Container(
              margin: EdgeInsets.all(10),
              height: 60,
              width: double.infinity,
              child: Card(
                elevation: 2,
                child: Center(child: Text("Search")),
              ),
            ),
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(),
                )),
          ),

          // 2nd children
          Container(
            margin: EdgeInsets.only(top: 5, left: 10, right: 10),
            width: double.infinity,
            child: Card(
              elevation: 2,
              child: Container(
                margin: EdgeInsets.all(20),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Uploaded Audios",
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      _buildUploadedAudioList()
                    ]),
              ),
            ),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("pressed");
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UploadAudioScreen(),
              ));
        },
        child: Icon(
          Icons.music_note,
          color: Colors.white,
        ),
        backgroundColor: CustomColors.AppBar_Bg_Theme1,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // get all the uploaded audios from the database
  Widget _buildUploadedAudioList() {
    // Use a ListView.builder to dynamically create the list of uploaded audio files
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Uploads').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator(); // Loading indicator while waiting for data
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;
        return ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            bool uploadStatus = documents[index]['upload_status'];

            // Inside your StreamBuilder's ListView.builder:
            double percent = calculatePercent(
              documents[index]['upload_status'],
              documents[index]['audio_segment'],
              documents[index]['converted_text'],
            );

            return Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            print('Tapped on ${documents[index].id}');
                            _playAudio(
                                documents[index].id, documents[index]['name']);
                          },
                          icon: Icon(Icons.play_circle)),

                      // Display the name only if upload_status is true
                      uploadStatus
                          ? Tooltip(
                              message: documents[index]['name'],
                              child: Container(
                                width: 100,
                                child: Text(
                                  documents[index]['name'],
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            )
                          : Tooltip(
                              message: documents[index]['name'],
                              child: Container(
                                width: 100,
                                child: Text(
                                  "Loading..",
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                      // Display different icons based on upload status
                      percent == 100.0
                          ? Icon(Icons
                              .check_circle) // Placeholder for indicating false status
                          : GestureDetector(
                              child: CircularPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                radius: 20, // Adjust the radius as needed
                                lineWidth: 3, // Adjust the line width as needed
                                percent: percent / 100,
                                progressColor: CustomColors.AppBar_Bg_Theme1,
                                backgroundColor:
                                    CustomColors.AppBar_Bg_Theme1.withOpacity(
                                        0.3),
                                circularStrokeCap: CircularStrokeCap.round,
                                center: Text(
                                  "${percent.toInt()}%",
                                  style: GoogleFonts.openSans(fontSize: 10),
                                ),
                              ),
                              onTap: () {
                                showToast("Audio is processing");
                              },
                            ), // Placeholder for indicating true status
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'delete',
                              child: ListTile(
                                leading: Icon(Icons.delete),
                                title: Text('Delete'),
                              ),
                            ),
                            // Add more PopupMenuItems for other actions as needed
                          ];
                        },
                        onSelected: (String action) {
                          if (action == 'delete') {
                            _showDeleteDialog(context, documents[index]);
                          }
                          // Handle other actions as needed
                        },
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Function to show a confirmation dialog before deleting
  Future<void> _showDeleteDialog(
      BuildContext context, DocumentSnapshot document) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete ${document['name']}?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _deleteDocument(document.id, document['name']);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete the document from Firebase and storage
  Future<void> _deleteDocument(String audioFileID, String fileName) async {
  try {
    // Fetch all doc IDs from "Transcribed Text" collection
    QuerySnapshot transcribedTextSnapshot = await FirebaseFirestore.instance
        .collection('Transcribed Text')
        .get();

    List<String> transcribedDocIDs = transcribedTextSnapshot.docs
        .map((doc) => doc.id)
        .toList();

    // Extract the base part of fileName (before the underscore)
    String baseFileName = audioFileID.split('_')[0];

    // Check if the baseFileName matches any processed doc IDs
    List<String> matchingDocIDs = transcribedDocIDs
        .where((transcribedDocID) => transcribedDocID.split('_')[0] == baseFileName)
        .toList();

    if (matchingDocIDs.isNotEmpty) {
      // Delete matching documents in "Transcribed Text" collection
      for (String docID in matchingDocIDs) {
        await FirebaseFirestore.instance
            .collection('Transcribed Text')
            .doc(docID)
            .delete();

        print('Document with ID $docID deleted successfully.');
      }

      // Delete document from Firebase
      await FirebaseFirestore.instance
          .collection('Uploads')
          .doc(audioFileID)
          .delete();

      // Delete file from Firebase Storage (adjust the path accordingly)
      await FirebaseStorage.instance
          .ref('Uploads/${audioFileID}/${audioFileID}.${fileName.split(".").last}')
          .delete();


      print('All matching documents deleted successfully.');
    } else {
      print('No matching documents found in "Transcribed Text" collection.');
    }
  } catch (e) {
    print('Error deleting documents: $e');
  }
}


  double calculatePercent(
      bool uploadStatus, String audioSegment, String convertedText) {
    if (uploadStatus) {
      if (convertedText == 'completed') {
        return 100.0;
      } else if (convertedText == 'in progress') {
        return 87.5;
      } else if (audioSegment == 'completed') {
        return 75.0;
      } else if (audioSegment == 'in progress') {
        return 50.0;
      } else if (audioSegment == 'not initiated') {
        return 25.0;
      } else {
        return 100.0; // Default if none of the conditions match
      }
    } else {
      return 0.0; // If uploadStatus is false
    }
  }

  // showToast function for displaying a toast message
  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _playAudio(String docID, String audioFileName) async {
    try {
      // Extract the file extension from the audioFileName
      String audioFileExtension = audioFileName.split('.').last;
      print("----------------------- $audioFileExtension");

      String audioURL = await FirebaseStorage.instance
          .ref('Uploads/$docID/$docID.$audioFileExtension')
          .getDownloadURL();

      await _audioPlayer.setUrl(audioURL);
      _isPlaying = true; // Set initial state to playing
      _showBottomSheet(audioFileName);
      await _audioPlayer.play();
      print('Audio playing successfully');
    } catch (e) {
      print('Error loading audio: $e');
    }
  }

  void _pauseAudio() {
    _audioPlayer.pause();
    print('Audio paused');
  }

  void _resumeAudio() {
    _audioPlayer.play();
    print('Audio resumed');
  }

  void _seekForward() {
    _audioPlayer.seek(_audioPlayer.position + Duration(seconds: 10));
    print('Seek forward 10 seconds');
  }

  void _seekBackward() {
    _audioPlayer.seek(_audioPlayer.position - Duration(seconds: 10));
    print('Seek backward 10 seconds');
  }

  void _showBottomSheet(String fileName) {
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(fileName),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      _audioPlayer.stop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
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
