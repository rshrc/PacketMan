import 'package:drift/drift.dart';
import 'package:drift_sqflite/drift_sqflite.dart';
import 'package:injectable/injectable.dart';
import 'package:packet_man/db/tables.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'dart:io';
part 'database.g.dart';

@injectable
@DriftDatabase(tables: [Projects, Collections, Requests])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

// Insert, update, delete, and query methods here
  Future<int> createProject(String name, String description) {
    return into(projects).insert(ProjectsCompanion(
      name: Value(name),
      description: Value(description),
    ));
  }

  Future<List<Project>> getAllProjects() {
    return select(projects).get();
  }

  Future<int> createCollection(int projectId, String name, String description) {
    return into(collections).insert(CollectionsCompanion(
      projectId: Value(projectId),
      name: Value(name),
      description: Value(description),
    ));
  }

  Future<List<Collection>> getCollectionsForProject(int projectId) {
    return (select(collections)
          ..where((tbl) => tbl.projectId.equals(projectId)))
        .get();
  }

  Future<int> createRequest(
    int collectionId,
    String name, {
    String? baseUrl,
    String? endpoint,
    String? requestType,
    String? environment,
    String? headers,
    String? body,
  }) {
    return into(requests).insert(RequestsCompanion(
      collectionId: Value(collectionId),
      name: Value(name),
      baseUrl: Value(baseUrl),
      endpoint: Value(endpoint),
      requestType: Value(requestType ?? "GET"),
      environment: Value(environment),
      headers: Value(headers),
      body: Value(body),
    ));
  }

  // update request
  Future<int> updateRequest(
    int requestId,
    String name, {
    String? baseUrl,
    String? endpoint,
    String? requestType,
    String? environment,
    String? headers,
    String? body,
  }) {
    return (update(requests)..where((tbl) => tbl.id.equals(requestId)))
        .write(RequestsCompanion(
      name: Value(name),
      baseUrl: Value(baseUrl),
      endpoint: Value(endpoint),
      requestType: Value(requestType ?? "GET"),
      environment: Value(environment),
      headers: Value(headers),
      body: Value(body),
    ));
  }

  Future<List<Request>> getRequestsForCollection(int collectionId) {
    return (select(requests)
          ..where((tbl) => tbl.collectionId.equals(collectionId)))
        .get();
  }

  Future<Request> getRequest(int requestId) {
    return (select(requests)..where((tbl) => tbl.id.equals(requestId)))
        .getSingle();
  }

  Future deleteRequest(int requestId) {
    return (delete(requests)..where((tbl) => tbl.id.equals(requestId))).go();
  }

  Future deleteCollection(int collectionId) {
    return (delete(collections)..where((tbl) => tbl.id.equals(collectionId)))
        .go();
  }

  Future deleteProject(int projectId) {
    return (delete(projects)..where((tbl) => tbl.id.equals(projectId))).go();
  }

  Future deleteAllProjects() {
    return delete(projects).go();
  }

  Future deleteAllCollections() {
    return delete(collections).go();
  }

  Future deleteAllRequests() {
    return delete(requests).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'packetman.sqlite'));
    return SqfliteQueryExecutor(logStatements: true, path: file.path);
  });
}
