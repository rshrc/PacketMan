import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:packet_man/application/providers.dart';
import 'package:packet_man/db/database.dart';
import 'dart:convert';

import 'package:packet_man/json_viewer.dart';
import 'package:packet_man/utils/colors.dart';
import 'package:provider/provider.dart';

void main() {
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
              padding: const EdgeInsets.only(left: 16.0),
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
                                        final projectId =
                                            await database.createProject(
                                          nameController.text,
                                          descriptionController.text,
                                        );

                                        final projects =
                                            await database.getAllProjects();
                                        for (final project in projects) {
                                          print(
                                              'Project: ${project.name}, Description: ${project.description}');
                                        }

                                        Navigator.pop(context);
                                      },
                                      child: const Text("Create"),
                                    ),
                                  ],
                                );
                              });
                        },
                        child: const Text("Create Project")),
                    const ProjectsList()
                  ]),
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

final database = AppDatabase();

class ProjectsList extends StatelessWidget {
  const ProjectsList({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: database.getAllProjects(),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final project = snapshot.data?[index];
                    return Column(
                      children: [
                        ListTile(
                          title: Text(project!.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.orange,
                              )),
                          onTap: () {
                            // show dialog to create collection
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return CreateCollectionDialog(
                                    projectID: project.id,
                                  );
                                });
                          },
                        ),
                        CollectionList(projectID: project.id),
                      ],
                    );
                  },
                )
              : const Text("No Projects Yet!");
        });
  }
}

class CollectionList extends StatelessWidget {
  final int projectID;
  const CollectionList({super.key, required this.projectID});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: database.getCollectionsForProject(projectID),
      builder: (context, snapshot) {
        return snapshot.hasData
            ? Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data?.length ?? 0,
                      itemBuilder: (context, index) {
                        final collection = snapshot.data?[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                // show dialog to create request
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return CreateRequestDialog(
                                        collectionID: collection.id,
                                      );
                                    });
                              },
                              child: Text(
                                collection!.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: RequestsList(collectionId: collection.id),
                            )
                          ],
                        );
                      },
                    ),
                  ],
                ),
              )
            : const Text("No Collections Yet!");
      },
    );
  }
}

class RequestsList extends StatelessWidget {
  final int collectionId;
  const RequestsList({super.key, required this.collectionId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: database.getRequestsForCollection(collectionId),
        builder: (context, snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data?.length ?? 0,
                  itemBuilder: (context, index) {
                    final request = snapshot.data?[index];
                    return Row(
                      children: [
                        Text(
                          request!.requestType.toString(),
                          style: TextStyle(
                            color: getColorForRequestType(request.requestType!),
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          request.name,
                        ),
                      ],
                    );
                  },
                )
              : const Text("No Requests Yet!");
        });
  }
}

class CreateRequestDialog extends StatefulWidget {
  final int collectionID;

  const CreateRequestDialog({super.key, required this.collectionID});

  @override
  State<CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<CreateRequestDialog> {
  final nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
          Radius.circular(10.0),
        )),
        title: const Text("Create Request"),
        content: SizedBox(
          height: 200,
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Name",
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
              // create request
              // final database = AppDatabase();
              await database.createRequest(
                widget.collectionID,
                nameController.text,
              );

              final requests =
                  await database.getRequestsForCollection(widget.collectionID);

              for (final request in requests) {
                print('Request: ${request.name}');
              }

              Navigator.pop(context);
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }
}

Color getColorForRequestType(String requestType) {
  switch (requestType) {
    case 'GET':
      return Colors.orange;
    case 'POST':
      return Colors.green;
    case 'PUT':
      return Colors.blue;
    case 'DELETE':
      return Colors.red;
    case 'PATCH':
      return Colors.purple;
    default:
      return Colors.black;
  }
}

class CreateCollectionDialog extends StatefulWidget {
  final int projectID;
  const CreateCollectionDialog({super.key, required this.projectID});

  @override
  State<CreateCollectionDialog> createState() => _CreateCollectionDialogState();
}

class _CreateCollectionDialogState extends State<CreateCollectionDialog> {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Collection"),
      content: SizedBox(
        height: 400,
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
            final collectionId = await database.createCollection(
              widget.projectID,
              nameController.text,
              descriptionController.text,
            );

            final collections =
                await database.getCollectionsForProject(widget.projectID);

            for (final collection in collections) {
              print(
                  'Collection: ${collection.name}, Description: ${collection.description}');
            }

            Navigator.pop(context);
          },
          child: const Text("Create"),
        ),
      ],
    );
  }
}
