import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../services/crud/database.dart';

class departmentController extends GetxController {
  Rx<List<DepartmentModel>> departments = Rx<List<DepartmentModel>>([]);
  final TextEditingController departmentNameControllerV1 =
      TextEditingController();
  final TextEditingController departmentIDControllerV1 =
      TextEditingController();
  late DepartmentModel departmentModel;
  var itemCount = 0.obs;

  addDepartment(String dpName, int depID) {
    departmentModel =
        DepartmentModel(departementID: depID, departementName: dpName);
    departments.value.add(departmentModel);
    itemCount.value = departments.value.length;
  }

  removeDepartment(int index) {
    departments.value.removeAt(index);
    itemCount.value = departments.value.length;
  }
}
