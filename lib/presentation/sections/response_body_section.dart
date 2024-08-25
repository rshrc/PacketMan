// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/json_viewer.dart';

class ResponseBodySection extends StatelessWidget {
  const ResponseBodySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Container(
            constraints: const BoxConstraints(
              minWidth: 400,
              minHeight: 300,
            ),
            child: Consumer<AppProvider>(
              builder: (context, appState, _) {
                return JsonViewer(
                  jsonString: appState.responseText.isEmpty
                      ? jsonEncode('{"message": "Response will be shown here"}')
                      : appState.responseText,
                );
              },
            )),
      ),
    );
  }
}
