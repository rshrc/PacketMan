import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/application/providers.dart';
import 'package:packet_man/db/database.dart';
import 'package:packet_man/di/injection.dart';
import 'dart:convert';

import 'package:packet_man/json_viewer.dart';
import 'package:packet_man/presentation/forms/create_projects.dart';
import 'package:packet_man/presentation/project_list.dart';
import 'package:packet_man/utils/colors.dart';
import 'package:provider/provider.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();

  runApp(const PacketMan());
}

class PacketMan extends StatelessWidget {
  const PacketMan({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: MaterialApp(
        title: 'PacketMan',
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    final provider = Provider.of<AppProvider>(context, listen: false);
    provider.initApp();
  }

  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PacketMan',
            style: TextStyle(
              color: Colors.orange,
            )),
      ),
      body: Row(
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                      onPressed: () {
                        // create project, but first open dialog box
                        showDialog(
                            context: context,
                            builder: (context) {
                              return const CreateProjectDialog();
                            });
                      },
                      child: const Text("Create Project")),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: ProjectsList(),
                  )
                ],
              ),
            ),
          ),
          const Expanded(flex: 5, child: RequestTestBody()),
        ],
      ),
    );
  }
}

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
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: appState.makeRequest,
                  child: const Text('Test'),
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
                        ),
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
