import 'package:drift/drift.dart';

class Projects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
}

class Collections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get projectId =>
      integer().customConstraint('REFERENCES projects(id) ON DELETE CASCADE')();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
}

class Requests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get collectionId => integer()
      .customConstraint('REFERENCES collections(id) ON DELETE CASCADE')();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get baseUrl => text().nullable()();
  TextColumn get endpoint => text().nullable()();
  TextColumn get requestType => text().nullable()(); // GET, POST, etc.
  TextColumn get environment => text().nullable()();
  TextColumn get headers => text().nullable()(); // Store as JSON string
  TextColumn get body => text().nullable()(); // Sto
  TextColumn get response => text().nullable()(); // re as JSON string
}
