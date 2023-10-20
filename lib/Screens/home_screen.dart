import 'package:flutter/material.dart';
import 'package:voicescribe/Utils/global_configs.dart';
import 'package:voicescribe/Widgets/list_uploaded_au_files.dart';
import 'package:voicescribe/Widgets/upload_audio_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GlobalConfigs.Appbar_Name,
        backgroundColor: CustomColors.AppBar_Bg_Theme1,
      ),
      body: SingleChildScrollView(
        child: Column(children: [
          // 1st children
          InkWell(
            child: UploadAudioCard(),
            onTap: () {
              print("clicked");
            },
          ),

          // 2nd children 
          ListUploadedAUFiles(),
        ]),
      ),
    );
  }
}
