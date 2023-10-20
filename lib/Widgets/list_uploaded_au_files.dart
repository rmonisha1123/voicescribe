import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          ]),
        ),
      ),
    );
  }
}
