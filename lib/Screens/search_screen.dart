import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../Widgets/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Search...',
          ),
        ),
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Transcribed Text').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error loading data'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No results found.'));
        }

        List<DocumentSnapshot> documents = snapshot.data!.docs;

        // Filter documents based on the search query
        List<DocumentSnapshot> filteredDocuments = searchQuery.isEmpty
            ? []
            : documents
                .where((document) =>
                    document['text'].toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

        return ListView.builder(
          itemCount: filteredDocuments.length,
          itemBuilder: (context, index) {
            String resultText = filteredDocuments[index]['text'];
            return SearchResultCard(resultText: resultText, searchQuery: searchQuery);
          },
        );
      },
    );
  }
}