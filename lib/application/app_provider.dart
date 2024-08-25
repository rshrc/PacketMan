// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:drift/drift.dart';
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

// Project imports:
import 'package:packet_man/db/database.dart';
import 'package:packet_man/utils/colors.dart';
import 'package:packet_man/utils/logger.dart';

enum EditableOptions {
  params,
  authorization,
  headers,
}

@injectable
class AppProvider extends ChangeNotifier {
  final AppDatabase _database;

  AppProvider(this._database);

  final Map<int, Project> projects = {};

  final Map<int, List<Collection>> collections = {};

  final Map<int, List<Request>> requests = {};

  Request? selectedRequest;

  EditableOptions selectedEditableOption = EditableOptions.params;

  Map<String, String> queryParams = {};

  void setSelectedEditableOption(EditableOptions option) {
    selectedEditableOption = option;
    notifyListeners();
  }

  initApp() async {
    await loadProjects();
  }

  void selectRequest(Request request) {
    selectedRequest = request;

    print("Line 52 : ${request}");

    dropdownValue = request.requestType ?? 'GET';
    urlController = TextEditingController(text: request.baseUrl);
    bodyController = TextEditingController(text: request.body);

    queryParams =
        Map<String, String>.from(jsonDecode(request.queryParams ?? '{}'));
    _initializeControllers();
    notifyListeners();
  }

  void _initializeControllers() {
    keyControllers.clear();
    valueControllers.clear();

    queryParams.forEach((key, value) {
      keyControllers[key] = TextEditingController(text: key);
      valueControllers[key] = TextEditingController(text: value);
    });

    logger.w("Line 74 : ${queryParams.length}");
    // log the keycontrollers and value controllers
    logger.w("Key Controllers : $keyControllers");
    logger.w("Value Controllers : $valueControllers");

    for (int i = queryParams.length; i < 4; i++) {
      keyControllers['key_$i'] = TextEditingController();
      valueControllers['value_$i'] = TextEditingController();
    }

    notifyListeners();
  }

  Future<void> saveQueryParams() async {
    keyControllers.forEach((key, controller) {
      final valueController = valueControllers[key];
      if (controller.text.isNotEmpty &&
          valueController?.text.isNotEmpty == true) {
        queryParams[controller.text] = valueController!.text;
      }
    });

    logger.w("Query Params : $queryParams");

    if (selectedRequest != null) {
      print("Hello!");
      await updateRequest(
          request: selectedRequest!.copyWith(
        queryParams: Value(jsonEncode(queryParams)),
      ));
      notifyListeners();
    }
  }

  String dropdownValue = 'GET';
  TextEditingController urlController = TextEditingController();
  TextEditingController bodyController = TextEditingController();
  String? status;

  Map<String, TextEditingController> keyControllers = {};
  Map<String, TextEditingController> valueControllers = {};

  void setStatus(String? status) {
    this.status = status;
    notifyListeners();
  }

  String responseText = '';

  void makeRequest() async {
    String url = urlController.text;
    if (url.isEmpty) {
      // todo: need to make this better, this sucks
      responseText = jsonEncode('{\'error\': \'Please enter a URL\'}');
      notifyListeners();
      return;
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
            body: bodyController.text,
          );
          setStatus(statusMessageColor(response.statusCode));
          break;
        case 'PUT':
          response = await http.put(
            Uri.parse(url),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(bodyController.text),
          );
          setStatus(statusMessageColor(response.statusCode));
          break;
        // Add other cases as needed
        default:
          response = await http.get(Uri.parse(url));
          setStatus(statusMessageColor(response.statusCode));
          break;
      }

      try {
        responseText = jsonEncode(jsonDecode(response.body),
            toEncodable: (e) => e.toString());
      } catch (e) {
        responseText = response.body;
      } finally {
        notifyListeners();
      }
    } catch (e) {
      responseText = 'Error: $e';
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadProjects() async {
    final projects = await _database.getAllProjects();
    for (final project in projects) {
      this.projects[project.id] = project;
      final collections = await _database.getCollectionsForProject(project.id);
      this.collections[project.id] = collections;
      for (final collection in collections) {
        final requests =
            await _database.getRequestsForCollection(collection.id);
        this.requests[collection.id] = requests;
      }
    }

    print("Line 34 : ${this.projects}");

    notifyListeners();
  }

  Future<void> loadCollections(int projectId) async {
    final collections = await _database.getCollectionsForProject(projectId);
    this.collections[projectId] = collections;
    for (final collection in collections) {
      final requests = await _database.getRequestsForCollection(collection.id);
      this.requests[collection.id] = requests;
    }
    notifyListeners();
  }

  Future<void> loadRequests(int collectionId) async {
    final requests = await _database.getRequestsForCollection(collectionId);
    this.requests[collectionId] = requests;
    notifyListeners();
  }

  Future<void> createProject(String name, String description) async {
    await _database.createProject(name, description);
    await loadProjects();
  }

  Future<void> createCollection(
      int projectId, String name, String description) async {
    await _database.createCollection(projectId, name, description);
    await loadProjects();
  }

  Future<void> createRequest(int collectionId, String name) async {
    await _database.createRequest(collectionId, name);
    await loadProjects();
  }

  Future<void> updateRequest({
    required Request request,
  }) async {
    final update = await _database.updateRequest(
      selectedRequest!.id,
      selectedRequest!.name,
      baseUrl: request.baseUrl,
      endpoint: request.endpoint,
      requestType: request.requestType,
      environment: request.environment,
      headers: request.headers,
      body: request.body,
      queryParams: request.queryParams,
    );

    if (request.requestType != null) {
      dropdownValue = request.requestType!;
    }

    if (request.baseUrl != null) {
      urlController.text = request.baseUrl!;
    }

    if (request.body != null) {
      bodyController.text = request.body!;
    }

    // update the request object in requests
    final latestRequest = await _database.getRequest(selectedRequest!.id);
    requests[selectedRequest!.collectionId] =
        requests[selectedRequest!.collectionId]!
            .map((r) => r.id == selectedRequest!.id ? latestRequest : r)
            .toList();

    notifyListeners();
  }

  void updateQueryParamKey(int index, String key) {
    String? currentValue = queryParams.remove(_getKeyForIndex(index));
    if (key.isNotEmpty) {
      queryParams[key] = currentValue ?? '';
    }

    notifyListeners();

    saveQueryParams();
  }

  void updateQueryParamValue(int index, String value) {
    String? currentKey = _getKeyForIndex(index);
    if (currentKey != null) {
      queryParams[currentKey] = value;
    }
    notifyListeners();

    saveQueryParams();
  }

  String? _getKeyForIndex(int index) {
    if (index >= queryParams.length) return null;
    return queryParams.keys.elementAt(index);
  }

  Future<void> purgeAllData() async {
    projects.clear();
    collections.clear();
    requests.clear();
    selectedRequest = null;
    // delete from database as well

    await _database.deleteAllRequests();
    await _database.deleteAllCollections();
    await _database.deleteAllProjects();

    notifyListeners();
  }
}
