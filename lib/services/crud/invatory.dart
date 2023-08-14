// import 'dart:async';
// import 'dart:js_interop';

// import 'package:flutter/material.dart';
// import 'package:p001/services/crud/database.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:path_provider/path_provider.dart'
//     show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
// import 'package:path/path.dart' show join;
// import 'package:p001/services/crud/crud_exception.dart';

// class DbService {
//   Database? _db;
//   StreamController<List<DataBaseDepartement>> _departement =
//     StreamController<List<DataBaseDepartement>>();

//   Stream<List<DataBaseDepartement>> get departement => _departement.stream;

  
  
  
  
//   //Future<Iterable<DatabaseStuff>> getAllUsers() async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final machines = await db.query(StuffTalbe);

//     return machines.map((stuffRow) => DatabaseStuff.fromRow(stuffRow));
//   }

//   //Future<Iterable<DatabaseMachine>> getAllMachine() async {
//     //await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final machines = await db.query(MachinesTable);

//     return machines.map((machineRow) => DatabaseMachine.fromRow(machineRow));
//   }

//   //Future<void> deleteUser({required String name}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletedCount = await db.delete(
//       userTable,
//       where: 'name = ?',
//       whereArgs: [name.toLowerCase()],
//     );
//     if (deletedCount != 1) {
//       throw CouldNotDeleteUser();
//     }
//   }

//  // Future<DatabaseStuff> creatUser(
//       {required int ID,
//       required String stuff_Name,
//       required String stuff_Adress,
//       required int stuff_phone}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(
//       StuffTalbe,
//       limit: 1,
//       where: 'Name = ? ',
//       whereArgs: [stuff_Name.toString()],
//     );
//     if (result.isNotEmpty) {
//       throw UserAlreadyExists();
//     } else {
//       final User = db.insert(StuffTalbe, {stuffNameColumn: stuff_Name});
//       return DatabaseStuff(
//           stuffID: ID,
//           stuffName: stuff_Name,
//           stuffAdress: stuff_Adress,
//           stuffPhone: stuff_phone);
//     }
//   }

//   Future<DatabaseMachine> getMachine({required String machiName}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(MachinesTable,
//         limit: 1, where: 'Name = ?', whereArgs: [depName.toLowerCase()]);
//     if (result.isEmpty) {
//       throw CouldNotFindDepartement();
//     } else {
//       return DatabaseMachine.fromRow(result.first);
//     }
//   }

//   Future<void> removeMachine({required String machineName}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.delete(MachinesTable,
//         where: 'Name = ?', whereArgs: [machineName.toLowerCase()]);
//     if (result == 0) {
//       throw MachineDoesNotExist();
//     }
//   }

//   Future<DatabaseMachine> createMachine(
//       {required String machineName, required String machineCategory}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(MachinesTable,
//         limit: 1, where: 'Name = ?', whereArgs: [machineName.toLowerCase()]);
//     if (result.isNotEmpty) {
//       throw MachineAlreadyExist();
//     } else {
//       final machineID = await db.insert(MachinesTable, {
//         machineNameColumn: machineName,
//         machineCategoryColumn: machineCategory,
//         machineStateColumn: 1
//       });
//       return DatabaseMachine(
//           machineId: machineID,
//           machineName: machineName,
//           machineCategory: machineCategory,
//           machineState: true);
//     }
//   }

//   Future<DataBaseDepartement> getDepartement({required String depName}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(DepartmentTable,
//         limit: 1, where: 'Name = ?', whereArgs: [depName.toLowerCase()]);
//     if (result.isEmpty) {
//       throw CouldNotFindDepartement();
//     } else {
//       return DataBaseDepartement.fromRow(result.first);
//     }
//   }

//   Future<void> deletDepartement({required String depName}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final deletDepartement = await db.delete(DepartmentTable,
//         where: 'department Name = ?', whereArgs: [depName.toLowerCase()]);

//     if (deletDepartement == 0) {
//       throw CouldNotDeleteDepartement();
//     }
//   }

//   Future<DataBaseDepartement> createDepartement(
//       {required String depName}) async {
//     await _ensureDbIsOpen();
//     final db = _getDatabaseOrThrow();
//     final result = await db.query(StuffTalbe,
//         limit: 1, where: 'name = ?', whereArgs: [depName.toLowerCase()]);
//     if (result.isNotEmpty) {
//       throw UserAlreadyExists();
//     }
//     //insert into data base
//     final depID = await db.insert(DepartmentTable, {depNameColumn: depName});
//     //return new object
//     return DataBaseDepartement(departementID: depID, departementName: depName);
//   }

//   Database _getDatabaseOrThrow() {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       return db;
//     }
//   }

//   //Future<void> _ensureDbIsOpen() async {
//     try {
//       await open();
//     } on DatabaseAlreadyOpenException {
//       // empty
//     }
//   }

//   Future<void> close() async {
//     final db = _db;
//     if (db == null) {
//       throw DatabaseIsNotOpen();
//     } else {
//       await db.close();
//       _db = null;
//     }
//   }

//   //Future<void> open() async {
//     if (_db != null) {
//       throw DatabaseAlreadyOpenException();
//     }
//     try {
//       // get the path to the directory where the application can store its files
//       final docsPath = await getApplicationDocumentsDirectory();
//       //This gives us the complete path to the SQLite database file.
//       final dbPath = join(docsPath.path, dbName);
//       final db = await openDatabase(dbPath);
//       _db = db;
//       // Create tables
//       await db.execute(DepartmentTable);
//       await db.execute(MachinesTable);
//       await db.execute(StuffTalbe);
//     } on MissingPlatformDirectoryException {
//       throw UnableToGetDocumentsDirectory();
//     }
//   }
// }

// @immutable
// class DataBaseDepartement {
//   final int departementID;
//   final String departementName;

//   const DataBaseDepartement({
//     required this.departementID,
//     required this.departementName,
//   });
//   DataBaseDepartement.fromRow(Map<String, dynamic> row)
//       : departementID = row[depID] as int,
//         departementName = row[depName] as String;
//   @override
//   String toString() =>
//       'Departement : Name = $departementName, ID =$departementID';
//   @override
//   bool operator ==(covariant DataBaseDepartement other) =>
//       departementID == other.departementID;
//   @override
//   int get hashCode => departementID.hashCode;
// }

// @immutable
// class DatabaseStuff {
//   final int stuffID;
//   final String stuffName;
//   final String stuffAdress;
//   final int stuffPhone;

//   const DatabaseStuff({
//     required this.stuffID,
//     required this.stuffName,
//     required this.stuffAdress,
//     required this.stuffPhone,
//   });
//   DatabaseStuff.fromRow(Map<String, dynamic> row)
//       : stuffID = row[stuffIdColumn] as int,
//         stuffName = row[stuffNameColumn] as String,
//         stuffPhone = row[stuffPhoneColumn] as int,
//         stuffAdress = row[stuffAdressColumn] as String;

//   @override
//   String toString() =>
//       'Person , Name = $stuffName ,ID = $stuffID    , Phone = $stuffPhone , Adress = $stuffAdress';
//   @override
//   bool operator ==(covariant DatabaseStuff other) => stuffID == other.stuffID;
//   @override
//   int get hashCode => stuffID.hashCode;
// }

// @immutable
// class DatabaseMachine {
//   final int machineId;
//   final String machineName;
//   final String machineCategory;
//   final bool machineState;

//   const DatabaseMachine({
//     required this.machineId,
//     required this.machineName,
//     required this.machineCategory,
//     required this.machineState,
//   });
//   DatabaseMachine.fromRow(Map<String, dynamic> row)
//       : machineId = row[machineIdColumn] as int,
//         machineName = row[machineNameColumn] as String,
//         machineCategory = row[machineCategoryColumn] as String,
//         machineState = (row[machineStateColumn] as int) == 1 ? true : false;

//   @override
//   String toString() =>
//       'Machine , Name = $machineName ,ID = $machineId    , Ctegory = $machineCategory , Status = $machineState';
//   @override
//   bool operator ==(covariant DatabaseMachine other) =>
//       machineId == other.machineId;
//   @override
//   int get hashCode => machineId.hashCode;
// }


// // this class is responsible for managing the caching data


// const depNameColumn = 'dep_name';
// const depIdColumn = 'dept_id';

// const stuffIdColumn = 'stuff_id';
// const stuffNameColumn = 'stuff_name';
// const stuffPhoneColumn = 'stuff_phone';
// const stuffAdressColumn = 'stuff_adress';

// const machineIdColumn = 'machine_id';
// const machineNameColumn = 'machine_name';
// const machineCategoryColumn = 'machine_category';
// const machineStateColumn = 'machine_state';

// const MachinesTable = ''' CREAT TABLE IF NOT EXIST "Machine" (
// 	"machine_id"	INTEGER NOT NULL UNIQUE,
// 	"machine_name"	TEXT NOT NULL UNIQUE,
// 	"machine_category"	TEXT NOT NULL,
// 	"machine_state"	INTEGER NOT NULL DEFAULT 1,
// 	PRIMARY KEY("machine_id" AUTOINCREMENT)
// ); ''';

// const StuffTalbe = ''' CREATE TABLE IF NOT EXIST "Stuff" (
// 	"stuff_id"	INTEGER NOT NULL UNIQUE,
// 	"stuff_name"	TEXT NOT NULL,
// 	"stuff_phone"	TEXT NOT NULL UNIQUE,
// 	"stuff_adress"	TEXT,
// 	PRIMARY KEY("stuff_id" AUTOINCREMENT)
// );''';

// const DepartmentTable = '''CREATE TABLE IF NOT EXIST "department" (
// 	"dept_id"	INTEGER NOT NULL UNIQUE,
// 	"dep_name"	TEXT UNIQUE,
// 	"machine_name"	TEXT NOT NULL UNIQUE,
// 	"dep_stuff_name"	TEXT NOT NULL,
// 	"machine_id"	INTEGER,
// 	PRIMARY KEY("dept_id" AUTOINCREMENT),
// 	FOREIGN KEY("machine_id") REFERENCES "Machine"("machine_id"),
// 	FOREIGN KEY("machine_name") REFERENCES "Machine"("machine_name")
// ); ''';
