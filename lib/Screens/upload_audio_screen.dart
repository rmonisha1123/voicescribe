import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';

class UploadAudioScreen extends StatefulWidget {
  @override
  State<UploadAudioScreen> createState() => _UploadAudioScreenState();
}

class _UploadAudioScreenState extends State<UploadAudioScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/backgrounds/bg.jpg"),
                fit: BoxFit.cover)),
        child: Center(
            child: Container(
          margin: EdgeInsets.only(left: 30, right: 30),
          width: double.infinity,
          height: 300,
          child: Card(
            elevation: 2,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Upload audio from your device",
                      style: GoogleFonts.openSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.grey.shade400,
                        ),
                        height: 75,
                        width: double.infinity,
                        child: Center(
                            child: Text(
                          "Upload Audio",
                          style: GoogleFonts.openSans(),
                        )),
                      ),
                      onTap: () {
                        print("clicked");
                        _uploadFile(context);
                      },
                    ),
                    Text(
                      "Note: The audio lenght should be maximum 4mins",
                      style: GoogleFonts.openSans(),
                    )
                  ]),
            ),
          ),
        )),
      ),
    );
  }

  Future<void> _uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomeScreen(result.files.single.name)));
      String fileName = result.files.single.name;
      String filePath = result.files.single.path ?? "";

      // Show uploading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Uploading Audio"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("File: $fileName"),
                SizedBox(height: 20),
                CircularProgressIndicator(),
              ],
            ),
          );
        },
      );

      // Upload file to Firebase Storage
      final firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('Uploads/$fileName');
      final firebase_storage.UploadTask uploadTask =
          storageReference.putFile(File(filePath));

      // Get audio duration using just_audio
      final audioPlayer = AudioPlayer();
      final duration = await audioPlayer.setFilePath(filePath).then((_) {
        return audioPlayer.duration;
      });

      audioPlayer
          .dispose(); // Dispose the audio player after getting the duration

      if (duration != null) {
        await uploadTask.whenComplete(() async {
          Navigator.pop(context); // Close the uploading dialog

          // Add entry to Firestore
          await FirebaseFirestore.instance
              .collection('Uploads')
              .doc(fileName)
              .set({
            'timestamp': FieldValue.serverTimestamp(),
            'name': fileName,
            'url': await storageReference.getDownloadURL(),
            'duration': duration.inSeconds,
          });

          print('File uploaded successfully!');
        });
      } else {
        Navigator.pop(context); // Close the uploading dialog
        print('Failed to get audio duration');
      }
    } else {
      // User canceled the file picker
      print('User canceled file picking');
    }
  }
}
