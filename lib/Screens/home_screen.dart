import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:just_audio/just_audio.dart';
import 'package:voicescribe/Screens/segment_and_transcribe_audio.dart';
import 'package:voicescribe/Utils/global_configs.dart';
import 'package:voicescribe/Widgets/list_uploaded_au_files.dart';
import 'package:voicescribe/Widgets/upload_audio_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
          InkWell(
            child: UploadAudioCard(),
            onTap: () {
              print("clicked");
              _uploadFile(context); // Call the function to handle file upload
            },
          ),

          // 2nd children
          ListUploadedAUFiles(),
        ]),
      ),
    );
  }

  Future<void> _uploadFile(BuildContext context) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
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

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      SegmentAndTranscribeAudio(fileName: fileName)));
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
