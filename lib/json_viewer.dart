import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'dart:convert';

class JsonViewer extends StatelessWidget {
  final String jsonString;

  const JsonViewer({super.key, required this.jsonString});

  @override
  Widget build(BuildContext context) {
    // Format the JSON string
    var prettyString = _formatJson(jsonString);

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.orange),
        borderRadius: BorderRadius.circular(5),
      ),
      child: HighlightView(
        prettyString,
        language: 'json',
        theme: githubTheme, // You can change the theme here
        padding: const EdgeInsets.all(12),
        textStyle: const TextStyle(
          fontFamily: 'Courier', // A monospaced font for better readability
          fontSize: 16,
        ),
      ),
    );
  }

  String _formatJson(String jsonString) {
    var jsonObject = json.decode(jsonString);
    var encoder = const JsonEncoder.withIndent('  ');
    return encoder.convert(jsonObject);
  }
}
