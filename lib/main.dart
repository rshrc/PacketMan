import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:packet_man/json_viewer.dart';

void main() {
  runApp(const PacketMan());
}

class PacketMan extends StatelessWidget {
  const PacketMan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PacketMan',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: const MyHomePage(),
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

  String getStatusMessage(int statusCode) {
    switch (statusCode) {
      case 200:
        return 'Success';
      case 201:
        return 'Created';
      case 204:
        return 'No Content';
      case 400:
        return 'Bad Request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 405:
        return 'Method Not Allowed';
      case 500:
        return 'Internal Server Error';
      default:
        return 'Unknown';
    }
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
          setStatus(getStatusMessage(response.statusCode));
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: _bodyController.text,
          );
          setStatus(getStatusMessage(response.statusCode));
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(_bodyController.text),
          );
          setStatus(getStatusMessage(response.statusCode));
          break;
        // Add other cases as needed
        default:
          response = await http.get(Uri.parse(url));
          setStatus(getStatusMessage(response.statusCode));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PacketMan',
            style: TextStyle(
              color: Colors.orange,
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                const SizedBox(width: 8),
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
                    constraints:
                        const BoxConstraints(minWidth: 400, minHeight: 300),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Request Body:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _bodyController,
                          maxLines: 10,
                          decoration: const InputDecoration(
                            hintText: '{ "key": "value" }',
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
                      constraints:
                          const BoxConstraints(minWidth: 400, minHeight: 300),
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
    );
  }
}
