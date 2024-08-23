import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:packet_man/application/app_provider.dart';
import 'package:packet_man/application/providers.dart';
import 'package:packet_man/db/database.dart';
import 'package:packet_man/di/injection.dart';
import 'dart:convert';

import 'package:packet_man/json_viewer.dart';
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

  String dropdownValue = 'GET';
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _bodyController =
      TextEditingController(); // Controller for the JSON input
  String? status;

  void setStatus(String? status) {
    setState(() {
      this.status = status;
    });
  }

  String responseText = '';

  void _makeRequest() async {
    String url = _urlController.text;
    if (url.isEmpty) {
      setState(() {
        responseText = 'Please enter a URL';
        return;
      });
    }
    http.Response response;

    try {
      switch (dropdownValue) {
        case 'GET':
          response = await http.get(Uri.parse(url));
          setStatus(statusMessageColor(response.statusCode));
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: _bodyController.text,
          );
          setStatus(statusMessageColor(response.statusCode));
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(_bodyController.text),
          );
          setStatus(statusMessageColor(response.statusCode));
          break;
        // Add other cases as needed
        default:
          response = await http.get(Uri.parse(url));
          setStatus(statusMessageColor(response.statusCode));
          break;
      }

      setState(() {
        try {
          responseText = jsonEncode(jsonDecode(response.body),
              toEncodable: (e) => e.toString());
        } catch (e) {
          responseText = response.body;
        }
      });
    } catch (e) {
      setState(() {
        responseText = 'Error: $e';
      });
    }
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
                              return AlertDialog(
                                title: const Text("Create Project"),
                                content: SizedBox(
                                  height: 200,
                                  width: 500,
                                  child: Column(
                                    children: [
                                      TextField(
                                        controller: nameController,
                                        decoration: const InputDecoration(
                                          labelText: "Name",
                                        ),
                                      ),
                                      TextField(
                                        controller: descriptionController,
                                        decoration: const InputDecoration(
                                          labelText: "Description",
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      // create project
                                      // final database = AppDatabase();
                                      final projectId = await context
                                          .read<AppProvider>()
                                          .createProject(
                                            nameController.text,
                                            descriptionController.text,
                                          );

                                      // load projects
                                      final projects = await context
                                          .read<AppProvider>()
                                          .loadProjects();
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Create"),
                                  ),
                                ],
                              );
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
          Expanded(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: dropdownValue,
                        onChanged: (String? newValue) {
                          setState(() {
                            dropdownValue = newValue!;
                          });
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
                          controller: _urlController,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Enter URL',
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _makeRequest,
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
                          constraints: const BoxConstraints(
                              minWidth: 400, minHeight: 300),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Request Body:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              TextField(
                                controller: _bodyController,
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
                              jsonString: responseText.isEmpty
                                  ? '{"message": "Response will be shown here"}'
                                  : responseText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
