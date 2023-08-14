import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart'
    show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:p001/services/crud/crud_exception.dart';

class DbService {
  Database? _db;

  List<DepartmentModel> _department = [];
//------ singleton-------------///
  static final DbService _shared = DbService._sharedInstance();
  DbService._sharedInstance() {
    // fl streamcontroller when ever a new listener com'ss in he will not be able to recive the current data
    _departementStreamController =
        StreamController<List<DepartmentModel>>.broadcast(
      onListen: () {
        _departementStreamController.sink.add(_department);
      },
    );
  }
  factory DbService() => _shared;
  //---------------------//

  late final StreamController<List<DepartmentModel>>
      _departementStreamController;
//----------------------------------------------------------------///////////////////////////////////////////////////////////////////////////////
  List<MachineModel> _machine = [];

  final _machineStreamController =
      StreamController<List<MachineModel>>.broadcast();
//retrive all the departments from the streamcontroller
  Stream<List<DepartmentModel>> get allDepartments =>
      _departementStreamController.stream;

  Future<StuffModel> getOrCreatUser({
    required String name,
    required String id,
    required String adress,
  }) async {
    try {
      final user = await getUser(id: id);
      return user;
    } on CouldNotFindUser {
      final creatuser =
          await creatUser(id: id, stuffName: name, stuffAdress: adress);
      return creatuser;
    } catch (e) {
      rethrow;
    }
  }

  //cache purpose is to read from the data base and place it in both streamcontroller and dep[] list

  Future<void> _cacheData() async {
    await _cacheMachines();
    await _cacheDepartments();
  }

  Future<void> _cacheMachines() async {
    final allMachines = await getAllMachine();
    _machine = allMachines.toList();
    _machineStreamController.add(_machine);
  }

  Future<void> _cacheDepartments() async {
    final alldepartements = await getAllDepartement();
    _department = alldepartements.toList();
    _departementStreamController.add(_department);
  }

  Future<Iterable<StuffModel>> getAllUsers() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final machines = await db.query(stuffTable);

    return machines.map((stuffRow) => StuffModel.fromRow(stuffRow));
  }

  Future<Iterable<DepartmentModel>> getAllDepartement() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final departments = await db.query(departmentTable);
    return departments.map((stuffRow) => DepartmentModel.fromRow(stuffRow));
  }

  Future<Iterable<MachineModel>> getAllMachine() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final machines = await db.query(machinesTable);

    return machines.map((machineRow) => MachineModel.fromRow(machineRow));
  }

  Future<StuffModel> getUser({required String id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db
        .query(stuffTable, limit: 1, where: 'Name = ?', whereArgs: [id]);
    if (result.isEmpty) {
      throw CouldNotFindDepartement();
    } else {
      return StuffModel.fromRow(result.first);
    }
  }

  Future<void> deleteUser({required String name}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      stuffTable,
      where: 'name = ?',
      whereArgs: [name.toLowerCase()],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  Future<StuffModel> creatUser({
    required String id,
    required String stuffName,
    required String stuffAdress,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      stuffTable,
      limit: 1,
      where: 'Name = ? ',
      whereArgs: [stuffName.toString()],
    );
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      db.insert(stuffTable, {stuffNameColumn: stuffName});
      return StuffModel(
        stuffID: id,
        stuffName: stuffName,
        stuffAdress: stuffAdress,
      );
    }
  }

  Future<MachineModel> getMachine({required String name}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(machinesTable,
        limit: 1, where: 'Name = ?', whereArgs: [name.toLowerCase()]);
    if (result.isEmpty) {
      throw CouldNotFindDepartement();
    } else {
      // keep the cache updated
      final machine = MachineModel.fromRow(result.first);
      _machine.removeWhere((machine) => machine.machineName == name);
      _machine.add(machine);
      _machineStreamController.add(_machine);
      return machine;
    }
  }

  Future<void> removeMachine({required String name}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.delete(machinesTable,
        where: 'Name = ?', whereArgs: [name.toLowerCase()]);
    if (result == 0) {
      throw MachineDoesNotExist();
    } else {
      _machine.removeWhere((machine) => machine.machineName == name);
      _machineStreamController.add(_machine);
    }
  }

  Future<MachineModel> createMachine(
      {required String machineName, required String machineCategory}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(machinesTable,
        limit: 1, where: 'Name = ?', whereArgs: [machineName.toLowerCase()]);
    if (result.isNotEmpty) {
      throw MachineAlreadyExist();
    } else {
      final machineID = await db.insert(machinesTable, {
        machineNameColumn: machineName,
        machineCategoryColumn: machineCategory,
        machineStateColumn: 1
      });

      final machine = MachineModel(
          machineId: machineID,
          machineName: machineName,
          machineCategory: machineCategory,
          machineState: true);

      _machine.add(machine);
      _machineStreamController.add(_machine);

      return machine;
    }
  }

  Future<DepartmentModel> updateDepartment({
    required DepartmentModel department,
    required String depName,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final result = await db.update(
        departmentTable,
        {
          depNameColumn: depName,
        },
        where: 'departmentID = ?',
        whereArgs: [department.departementID]);

    if (result == 0) {
      throw CouldNotUpdateDepartment();
    } else {
      final upDateDepartment = await getDepartment(depName: depName);
      _department
          .removeWhere((department) => department.departementName == depName);
      _department.add(upDateDepartment);
      _department.add(department);
      return upDateDepartment;
    }
  }

  Future<DepartmentModel> getDepartment({required String depName}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(departmentTable,
        limit: 1, where: 'Name = ?', whereArgs: [depName.toLowerCase()]);
    if (result.isEmpty) {
      throw CouldNotFindDepartement();
    } else {
      final departement = DepartmentModel.fromRow(result.first);
      _department
          .removeWhere((machine) => departement.departementName == depName);
      _department.add(departement);

      return departement;
    }
  }

  Future<void> deletDepartment({required String depName}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletDepartement = await db.delete(departmentTable,
        where: 'department Name = ?', whereArgs: [depName.toLowerCase()]);

    if (deletDepartement == 0) {
      throw CouldNotDeleteDepartement();
    }
  }

  Future<DepartmentModel> createDepartment(
      {required String depName, required depID}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(stuffTable,
        limit: 1, where: 'name = ?', whereArgs: [depName.toLowerCase()]);
    if (result.isNotEmpty) {
      throw UserAlreadyExists();
    } else {
      //insert into data base
      final depID = await db.insert(departmentTable, {depNameColumn: depName});

      //return new object
      final departement = DepartmentModel(
        departementID: depID,
        departementName: depName,
      );
      _department.add(departement);
      _departementStreamController.add(_department);
      return departement;
    }
  }

  Database _getDatabaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      return db;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {
      // empty
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseIsNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    try {
      // get the path to the directory where the application can store its files
      final docsPath = await getApplicationDocumentsDirectory();
      //This gives us the complete path to the SQLite database file.
      final dbPath = join(docsPath.path, 'dbName');
      final db = await openDatabase(
        dbPath,
        version: 1,
        onCreate: _createTables,
      );
      _db = db;
      // Create tables

      await _cacheData();
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute(machinesTable);
    await db.execute(stuffTable);
    await db.execute(departmentTable);
  }
}

@immutable
class DepartmentModel {
  final int departementID;
  final String departementName;

  const DepartmentModel({
    required this.departementID,
    required this.departementName,
  });
  DepartmentModel.fromRow(Map<String, dynamic> row)
      : departementID = row[depIdColumn] as int,
        departementName = row[depIdColumn] as String;
  @override
  String toString() =>
      'Departement : Name = $departementName, ID =$departementID';
  @override
  bool operator ==(covariant DepartmentModel other) =>
      departementID == other.departementID;
  @override
  int get hashCode => departementID.hashCode;
}

@immutable
class StuffModel {
  final String stuffID;
  final String stuffName;
  final String stuffAdress;

  const StuffModel({
    required this.stuffID,
    required this.stuffName,
    required this.stuffAdress,
  });
  StuffModel.fromRow(Map<String, dynamic> row)
      : stuffID = row[stuffIdColumn] as String,
        stuffName = row[stuffNameColumn] as String,
        stuffAdress = row[stuffAdressColumn] as String;

  @override
  String toString() =>
      'Person , Name = $stuffName ,ID = $stuffID    , Adress = $stuffAdress';
  @override
  bool operator ==(covariant StuffModel other) => stuffID == other.stuffID;
  @override
  int get hashCode => stuffID.hashCode;
}

@immutable
class MachineModel {
  final int machineId;
  final String machineName;
  final String machineCategory;
  final bool machineState;

  const MachineModel({
    required this.machineId,
    required this.machineName,
    required this.machineCategory,
    required this.machineState,
  });
  MachineModel.fromRow(Map<String, dynamic> row)
      : machineId = row[machineIdColumn] as int,
        machineName = row[machineNameColumn] as String,
        machineCategory = row[machineCategoryColumn] as String,
        machineState = (row[machineStateColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Machine , Name = $machineName ,ID = $machineId    , Ctegory = $machineCategory , Status = $machineState';
  @override
  bool operator ==(covariant MachineModel other) =>
      machineId == other.machineId;
  @override
  int get hashCode => machineId.hashCode;
}

const depNameColumn = 'dep_name';
const depIdColumn = 'dept_id';

const stuffIdColumn = 'stuff_id';
const stuffNameColumn = 'stuff_name';
const stuffPhoneColumn = 'stuff_phone';
const stuffAdressColumn = 'stuff_adress';

const machineIdColumn = 'machine_id';
const machineNameColumn = 'machine_name';
const machineCategoryColumn = 'machine_category';
const machineStateColumn = 'machine_state';

const machinesTable = ''' CREATE TABLE IF NOT EXISTS "Machine" (
	"machine_id"	INTEGER NOT NULL UNIQUE,
	"machine_name"	TEXT NOT NULL UNIQUE,
	"machine_category"	TEXT NOT NULL,
	"machine_state"	INTEGER NOT NULL DEFAULT 1,
	PRIMARY KEY("machine_id" AUTOINCREMENT)
); ''';

const stuffTable = ''' CREATE TABLE IF NOT EXISTS "Stuff" (
	"stuff_id"	INTEGER NOT NULL UNIQUE,
	"stuff_name"	TEXT NOT NULL,
	"stuff_phone"	TEXT NOT NULL UNIQUE,
	"stuff_adress"	TEXT,
	PRIMARY KEY("stuff_id" AUTOINCREMENT)
);''';

const departmentTable = '''CREATE TABLE IF NOT EXISTS "department" (
	"dept_id"	INTEGER NOT NULL UNIQUE,
	"dep_name"	TEXT UNIQUE,
	"machine_name"	TEXT NOT NULL UNIQUE,
	"dep_stuff_name"	TEXT NOT NULL,
	"machine_id"	INTEGER,
	PRIMARY KEY("dept_id" AUTOINCREMENT),
	FOREIGN KEY("machine_id") REFERENCES "Machine"("machine_id"),
	FOREIGN KEY("machine_name") REFERENCES "Machine"("machine_name")
); ''';
