import 'package:flutter/material.dart';
import 'package:p001/services/auth/auth_service.dart';
import 'package:p001/services/crud/database.dart';

import '../../constants/router.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class NewInvatoryView extends StatefulWidget {
  const NewInvatoryView({super.key});

  @override
  State<NewInvatoryView> createState() => _NewInvatoryViewState();
}

class _NewInvatoryViewState extends State<NewInvatoryView> {
  DepartmentModel? _department;
  late final DbService _dbService;
  final TextEditingController _departmentNameController =
      TextEditingController();
  final TextEditingController _departmentIDController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbService = DbService(); // Instantiate  DbService
    // Set up listener for department name text field

    _departmentNameController.addListener(_textControllerListener);
  }

  Future<DepartmentModel> createDepartment() async {
    final depName = _departmentNameController.text;
    final depID = _departmentIDController.text;

    final createdDepartment =
        await _dbService.createDepartment(depName: depName, depID: depID);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Department created successfully.'),
    ));

    return createdDepartment;
  }

  Future<DepartmentModel> createNewDepartment() async {
    //capture user input from text fields
    final depName = _departmentNameController.text;
    final depID = _departmentIDController.text;

    final existinDepartment = _department;
    if (existinDepartment != null) {
      return existinDepartment;
    }
    final currentUser = AuthService.firebase().currentUser!;
    return _dbService.createDepartment(depName: depName, depID: depID);
  }

  void _deletDepartmentIfTextIsEmpty() {
    final department = _department;
    if (_departmentNameController.text.isEmpty && department != null) {
      _dbService.deletDepartment(depName: department.departementName);
    }
  }

  @override
  void dispose() {
    _deletDepartmentIfTextIsEmpty();
    _departmentNameController.dispose();
    // Clean up listeners
    _departmentNameController.removeListener(_onDepartmentNameChanged);

    // Dispose text controllers
    _departmentNameController.dispose();
    super.dispose();
  }

  void _textControllerListener() async {
    final department = _department;
    final depName = _department!.departementName;
    if (department == null) {
      return;
    }
    final text = _departmentNameController.text;
    await _dbService.updateDepartment(department: department, depName: depName);
  }

  void _onDepartmentNameChanged() {
    // Handle changes in department name
    print("Department Name Changed: ${_departmentNameController.text}");
  }

  void _onDepartmentAddressChanged() {
    // Handle changes in department address
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _departmentNameController,
              decoration: const InputDecoration(labelText: 'Department Name'),
            ),
            TextField(
              controller: _departmentIDController,
              decoration: const InputDecoration(labelText: 'Department ID'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                final createdDepartment = await createNewDepartment();
                Navigator.of(context).pop(createdDepartment);
                setState(() {
                  _department = createdDepartment;
                });
                // Do something with the created department, e.g., show a message
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Department created successfully.'),
                ));
              },
              child: const Text('Create Department'),
            ),
          ],
        ),
      ),
    );
  }
}

//---------------------------------------------------------------------//
