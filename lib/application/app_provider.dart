import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:packet_man/db/database.dart';

@injectable
class AppProvider extends ChangeNotifier {
  final AppDatabase _database;

  AppProvider(this._database);

  final Map<int, Project> projects = {};

  final Map<int, List<Collection>> collections = {};

  final Map<int, List<Request>> requests = {};

  initApp() async {
    await loadProjects();
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
}
