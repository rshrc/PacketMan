// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:drift/drift.dart' hide Column, Table;
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RequestBodySection(),
                    SizedBox(width: 16),
                    ResponseBodySection(),
                  ],
                ),
                // Segmented Button with options Params, Authorization, Headers
                const SizedBox(height: 20),
                SegmentedButton<EditableOptions>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: Colors.orangeAccent,
                    side: const BorderSide(color: Colors.transparent),
                  ),
                  segments: const <ButtonSegment<EditableOptions>>[
                    ButtonSegment<EditableOptions>(
                        value: EditableOptions.params,
                        label: Text('Query Params'),
                        icon: Icon(
                          FontAwesomeIcons.question,
                        )),
                    ButtonSegment<EditableOptions>(
                        value: EditableOptions.authorization,
                        label: Text('Authorization'),
                        icon: Icon(
                          FontAwesomeIcons.shieldDog,
                        )),
                    ButtonSegment<EditableOptions>(
                      value: EditableOptions.headers,
                      label: Text('Headers'),
                      icon: Icon(Icons.calendar_view_month),
                    ),
                  ],
                  selected: <EditableOptions>{appState.selectedEditableOption},
                  onSelectionChanged: (Set<EditableOptions> newSelection) {
                    appState.setSelectedEditableOption(newSelection.first);
                  },
                ),
                const SizedBox(height: 12),
                if (appState.selectedEditableOption == EditableOptions.params)
                  const QueryParameterSection()
                else if (appState.selectedEditableOption ==
                    EditableOptions.authorization)
                  const AuthorizationSection()
                else if (appState.selectedEditableOption ==
                    EditableOptions.headers)
                  const HeadersSection()
              ],
            ),
          ],
        ),
      );
    });
  }
}

class QueryParameterSection extends StatelessWidget {
  const QueryParameterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.5,
        height: 300,
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          border: Border.all(color: Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Consumer<AppProvider>(builder: (context, appState, _) {
          return Table(
            columnWidths: const {
              0: FlexColumnWidth(0.5),
              1: FlexColumnWidth(1.0),
            },
            border: TableBorder.all(
                color: Colors.grey, borderRadius: BorderRadius.circular(8)),
            children: List.generate(4, (index) {
              final keyController = appState.keyControllers['key_$index'] ??
                  TextEditingController();
              final valueController =
                  appState.valueControllers['value_$index'] ??
                      TextEditingController();

              return TableRow(children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                      controller: keyController,
                      decoration: const InputDecoration(
                        labelText: 'Key',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                      ),
                      onChanged: (value) {
                        appState.updateQueryParamKey(index, value);
                      },
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      )),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: valueController,
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      appState.updateQueryParamValue(index, value);
                    },
                  ),
                ),
              ]);
            }),
          );
        }));
  }
}

class AuthorizationSection extends StatelessWidget {
  const AuthorizationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 300,
      color: Colors.blue,
    );
  }
}

class HeadersSection extends StatelessWidget {
  const HeadersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 300,
      color: Colors.green,
    );
  }
}
