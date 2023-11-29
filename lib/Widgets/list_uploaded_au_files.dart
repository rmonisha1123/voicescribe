import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListUploadedAUFiles extends StatelessWidget {
  const ListUploadedAUFiles({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: Container(
          margin: EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
    );
  }

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
                              100, // Set a fixed width or adjust based on your needs
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
}
