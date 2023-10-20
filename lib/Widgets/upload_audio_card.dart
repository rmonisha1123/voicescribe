import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:voicescribe/Utils/global_configs.dart';

class UploadAudioCard extends StatelessWidget {
  const UploadAudioCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 5, left: 10, right: 10),
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: Container(
          margin: EdgeInsets.only(top: 20, bottom: 20),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
              backgroundColor: CustomColors.AppBar_Bg_Theme1,
              maxRadius: 50,
              child: FaIcon(
                FontAwesomeIcons.music,
                color: Colors.white,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Upload your Audio",
              style: GoogleFonts.openSans(fontSize: 18),
            ),
          ]),
        ),
      ),
    );
  }
}
