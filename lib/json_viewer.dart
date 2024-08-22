import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'dart:convert';

class JsonViewer extends StatelessWidget {
  final String jsonString;

  JsonViewer({required this.jsonString});

  @override
  Widget build(BuildContext context) {
    // Format the JSON string
    var prettyString = _formatJson(jsonString);

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(5),
      ),
      child: HighlightView(
        prettyString,
        language: 'json',
        theme: githubTheme, // You can change the theme here
        padding: EdgeInsets.all(12),
        textStyle: TextStyle(
          fontFamily: 'Courier', // A monospaced font for better readability
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatJson(String jsonString) {
    var jsonObject = json.decode(jsonString);
    var encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }
}