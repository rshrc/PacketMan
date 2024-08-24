import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/json_viewer.dart';
import 'package:provider/provider.dart';

class RequestTestBody extends StatelessWidget {
  const RequestTestBody({super.key});

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
                            .copyWith(requestType: Value(newValue)));
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
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Enter URL',
                    ),
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
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.white),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 400, minHeight: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Body:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        TextField(
                            controller: appState.bodyController,
                            maxLines: 10,
                            decoration: const InputDecoration(
                              hintText: '{ \n  "key": "value"\n}',
                              border: OutlineInputBorder(),
                            ),
                            onTapOutside: (_) {
                              appState.updateRequest(
                                request: appState.selectedRequest!.copyWith(
                                  body: Value(appState.bodyController.text),
                                ),
                              );
                            },
                            onEditingComplete: () {
                              appState.updateRequest(
                                request: appState.selectedRequest!.copyWith(
                                  body: Value(appState.bodyController.text),
                                ),
                              );
                            }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      constraints: const BoxConstraints(
                        minWidth: 400,
                        minHeight: 300,
                      ),
                      child: JsonViewer(
                        jsonString: appState.responseText.isEmpty
                            ? '{"message": "Response will be shown here"}'
                            : appState.responseText,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
