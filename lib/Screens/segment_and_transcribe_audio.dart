import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

import '../Utils/global_configs.dart';

class SegmentAndTranscribeAudio extends StatefulWidget {
  String fileName;

  SegmentAndTranscribeAudio({required this.fileName});

  @override
  State<SegmentAndTranscribeAudio> createState() =>
      _SegmentAndTranscribeAudioState();
}

class _SegmentAndTranscribeAudioState extends State<SegmentAndTranscribeAudio> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    checkIfSubcollectionExists();
  }

  Future<void> checkIfSubcollectionExists() async {
    try {
      // Extract the name without extension
      String alteredName = widget.fileName.replaceAll(RegExp(r'\.mp3$'), '');

      // Access Firestore and check if subcollection exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Segmented Audios')
          .doc('Audios')
          .collection(alteredName)
          .get();

      // Check if the subcollection exists
      if (querySnapshot.docs.isNotEmpty) {
        // Subcollection exists, stop loading
        setState(() {
          isLoading = false;
        });
      } else {
        // Subcollection doesn't exist, continue loading
        // You can add additional logic or UI updates here if needed
      }
    } catch (error) {
      print("Error checking subcollection: $error");
      // Handle error if necessary
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            "T R A N S C R I B E A U D I O",
            style: TextStyle(color: Colors.white),
          ),
        ),
        backgroundColor: CustomColors.AppBar_Bg_Theme1,
      ),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : Text(
                "Subcollection found!",
                style: TextStyle(fontSize: 18),
              ),
      ),
    );
  }
}
