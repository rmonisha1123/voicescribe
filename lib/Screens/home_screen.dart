import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:google_fonts/google_fonts.dart';
import 'package:voicescribe/Utils/global_configs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Widgets/list_uploaded_au_files.dart';
import 'upload_audio_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomeScreen extends StatefulWidget {
  final String? fileName;
  HomeScreen(this.fileName);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String modifiedFileName;
  bool timeoutOccurred = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    modifyFileName();
  }

  @override
  Widget build(BuildContext context) {
    print("------------------------------------- ${widget.fileName}");
    return Scaffold(
      appBar: AppBar(
        title: Center(child: GlobalConfigs.Appbar_Name),
        backgroundColor: CustomColors.AppBar_Bg_Theme1,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // 1st children
          Container(
            margin: EdgeInsets.all(10),
            height: 60,
            width: double.infinity,
            child: Card(
              elevation: 2,
              child: Center(child: Text("Search")),
            ),
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
            // Replace this with your actual list item UI
            return Container(
              // color: Colors.amber,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            print('Tapped on ${documents[index]['name']}');
                          },
                          icon: Icon(Icons.play_circle)),
                      Tooltip(
                        message: documents[index]
                            ['name'], // Full name for the tooltip
                        child: Container(
                          width:
                              75, // Set a fixed width or adjust based on your needs
                          child: Text(
                            documents[index]['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${documents[index]['duration']} seconds'),
                      IconButton(onPressed: () {}, icon: Icon(Icons.share)),
                      StreamBuilder<bool>(
                        stream: checkMatchingSubcollectionStream(
                            removeFileExtension(documents[index]['name'])),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else if (snapshot.data == true) {
                            // Matching subcollection found, you can show a success indicator or take further actions
                            return Icon(Icons.check, color: Colors.green);
                          } else {
                            // No matching subcollection found

                            // Use a Timer to track the timeout
                            Timer(Duration(seconds: 150), () {
                              // After 2 minutes and 30 seconds, set the flag and show the alert icon
                              if (!timeoutOccurred) {
                                setState(() {
                                  timeoutOccurred = true;
                                });
                              }
                            });

                            // Show the circular progress indicator or the alert icon based on the timeout flag
                            return timeoutOccurred
                                ? GestureDetector(
                                    onTap: () {
                                      // Show a toast message on pressing the alert icon
                                      showToast(
                                          "Something went wrong, kindly delete the audio & retry the process");
                                    },
                                    child: Icon(Icons.error, color: Colors.red),
                                  )
                                : Container(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(),
                                  );
                          }
                        },
                      ),
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
                await _deleteDocument(document);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Function to delete the document from Firebase and storage
  Future<void> _deleteDocument(DocumentSnapshot document) async {
    try {
      // Delete document from Firebase
      await FirebaseFirestore.instance
          .collection('Uploads')
          .doc(document.id)
          .delete();

      // Delete file from Firebase Storage (adjust the path accordingly)
      await FirebaseStorage.instance
          .ref('Uploads/${document['name']}')
          .delete();

      print('Document deleted successfully.');
    } catch (e) {
      print('Error deleting document: $e');
    }
  }

  // Function to modify the filename by removing the file extension
  void modifyFileName() {
    modifiedFileName = removeFileExtension(widget.fileName ?? "");
    print("************************ $modifiedFileName");
  }

  // Function to remove file extension
  String removeFileExtension(String fileName) {
    int dotIndex = fileName.lastIndexOf('.');
    if (dotIndex != -1) {
      return fileName.substring(0, dotIndex);
    } else {
      return fileName;
    }
  }

  Stream<bool> checkMatchingSubcollectionStream(
      String modifiedFileName) async* {
    print("^^^^^^^^^^inside the function^^^^^^^^^^^^");
    while (true) {
      try {
        var audiosDocSnapshot = await FirebaseFirestore.instance
            .collection('Segmented Audios')
            .doc('Audios')
            .get();

        if (audiosDocSnapshot.exists) {
          var subcollectionSnapshot = await audiosDocSnapshot.reference
              .collection(modifiedFileName)
              .get();

          if (subcollectionSnapshot.docs.isNotEmpty) {
            print("Subcollections exist for $modifiedFileName");
            // Matching subcollection found
            yield true;
          } else {
            // No subcollections found
            print("No matching subcollections for $modifiedFileName");
            yield false;
          }
        } else {
          // 'Audios' document does not exist
          print("'Audios' document does not exist");
          yield false;
        }

        await Future.delayed(
            Duration(seconds: 5)); // Adjust the delay as needed
      } catch (error) {
        print('Error checking subcollection: $error');
        yield false;
        await Future.delayed(
            Duration(seconds: 5)); // Adjust the delay as needed
      }
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
}
