// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/presentation/sections/sections.dart';

class APITestSection extends StatelessWidget {
  const APITestSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(builder: (context, appState, _) {
      if (appState.selectedRequest == null) {
        return const Center(
          child: Text("Select a request to test"),
        );
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: appState.dropdownValue,
                  onChanged: (String? newValue) {
                    appState.updateRequest(
                      request: appState.selectedRequest!
                          .copyWith(requestType: Value(newValue)),
                    );
                  },
                  items: <String>['GET', 'POST', 'PUT', 'DELETE', 'PATCH']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: appState.urlController,
                    decoration: InputDecoration(
                        hintText: 'https://api.example.com',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        suffixIcon: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              // copy appState.urlController to clipboard
                              await Clipboard.setData(
                                ClipboardData(
                                    text: appState.urlController.text),
                              );
                            },
                            child: const Icon(
                              Icons.copy,
                            ),
                          ),
                        )),
                    onEditingComplete: () {
                      appState.updateRequest(
                        request: appState.selectedRequest!.copyWith(
                          baseUrl: Value(appState.urlController.text),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: appState.makeRequest,
                    child: const Icon(
                      FontAwesomeIcons.solidPaperPlane,
                      size: 18,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RequestBodySection(),
                SizedBox(width: 16),
                ResponseBodySection(),
              ],
            ),
          ],
        ),
      );
    });
  }
}
