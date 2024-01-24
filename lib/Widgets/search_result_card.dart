import 'package:flutter/material.dart';

import '../Utils/global_configs.dart';

class SearchResultCard extends StatelessWidget {
  final String resultText;
  final String searchQuery;

  const SearchResultCard({required this.resultText, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        color: CustomColors.AppBar_Bg_Theme1,
        elevation: 4,
        child: ListTile(
          title: RichText(
            text: highlightKeyword(resultText, searchQuery),
          ),
        ),
      ),
    );
  }

  TextSpan highlightKeyword(String text, String keyword) {
    List<TextSpan> spans = [];

    // Split the text into parts before and after the keyword
    List<String> parts = text.toLowerCase().split(keyword.toLowerCase());

    int lastIndex = parts.length - 1;

    for (int i = 0; i < lastIndex; i++) {
      spans.add(TextSpan(text: parts[i]));

      // Highlight the keyword
      spans.add(TextSpan(
        text: keyword,
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow, fontSize: 20),
      ));
    }

    spans.add(TextSpan(text: parts[lastIndex]));

    return TextSpan(children: spans);
  }
}

