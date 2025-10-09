
// import 'package:attendance_app/constants/app_colors.dart';
// import 'package:attendance_app/services/superbase_services.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AssignedSupervisorsController extends GetxController {
//   final SupabaseService _supabaseService = Get.find<SupabaseService>();

//   final RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> allSupervisors = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> departmentSupervisors = <Map<String, dynamic>>[].obs;
//   final RxString selectedDepartmentId = ''.obs;
//   final RxBool isLoading = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchDepartments();
//     fetchAllSupervisors();
//     isLoading.value = false;
//   }

//   Future<void> fetchDepartments() async {
//     try {
//       final deps = await _supabaseService.getAllDepartments();
//       departments.assignAll(deps);
//     } catch (e) {
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Error',
//         'Failed to fetch departments: $e',
//       );
//     }
//   }

//   Future<void> fetchAllSupervisors() async {
//     try {
//       final sups = await _supabaseService.getSupervisors();
//       allSupervisors.assignAll(sups);
//     } catch (e) {
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Error',
//         'Failed to fetch supervisors: $e',
//       );
//     }
//   }

//   Future<void> fetchDepartmentSupervisors(String depId) async {
//     try {
//       final sups = await _supabaseService.getSupervisors(departmentId: depId);
//       departmentSupervisors.assignAll(sups);
//     } catch (e) {
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Error',
//         'Failed to fetch department supervisors: $e',
//       );
//     }
//   }

//   void onDepartmentChanged(String? value) {
//     if (value != null) {
//       selectedDepartmentId.value = value;
//       fetchDepartmentSupervisors(value);
//     }
//   }

//   Future<void> assignSupervisor(String supId, String depId) async {
//     try {
//       // Check if supervisor is already assigned to another department
//       final supervisor = allSupervisors.firstWhere((sup) => sup['id'] == supId);
//       if (supervisor['department_id'] != null && supervisor['department_id'] != depId) {
//         final currentDepId = supervisor['department_id'];
//         final currentDep = departments.firstWhere((dep) => dep['id'] == currentDepId, orElse: () => {'name': 'Unknown'});
//         Get.dialog(
//           Dialog(
//             backgroundColor: kWhite,
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),),
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     'Supervisor Already Assigned',
//                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Supervisor ${supervisor['name']} is already assigned to ${currentDep['name']}. '
//                     'Do you want to remove them from ${currentDep['name']} and assign to the new department?',
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 16),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       TextButton(
//                         onPressed: () => Get.back(),
//                         child: Text('Cancel', style: TextStyle(color: kPrimaryColor)),
//                       ),
//                       TextButton(
//                         onPressed: () async {
//                           await _supabaseService.unassignSupervisorFromDepartment(supId);
//                           await _supabaseService.assignSupervisorToDepartment(supId, depId);
//                           fetchDepartmentSupervisors(depId);
//                           fetchAllSupervisors();
//                           Get.back();
//                           Get.snackbar(
//                             backgroundColor: kWhite,
//                             'Success',
//                             'Supervisor assigned successfully',
//                           );
//                         },
//                         child: Text('Confirm', style: TextStyle(color: kPrimaryColor)),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       } else {
//         await _supabaseService.assignSupervisorToDepartment(supId, depId);
//         fetchDepartmentSupervisors(depId);
//         fetchAllSupervisors();
//         Get.snackbar(
//           backgroundColor: kWhite,
//           'Success',
//           'Supervisor assigned successfully',
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Error',
//         'Failed to assign supervisor: $e',
//       );
//     }
//   }

//   Future<void> unassignSupervisor(String supId, String depId) async {
//     try {
//       await _supabaseService.unassignSupervisorFromDepartment(supId);
//       fetchDepartmentSupervisors(depId);
//       fetchAllSupervisors();
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Success',
//         'Supervisor unassigned successfully',
//       );
//     } catch (e) {
//       Get.snackbar(
//         backgroundColor: kWhite,
//         'Error',
//         'Failed to unassign supervisor: $e',
//       );
//     }
//   }
// }
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/services/superbase_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignedSupervisorsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allSupervisors = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> departmentSupervisors = <Map<String, dynamic>>[].obs;
  final RxMap<String, List<Map<String, dynamic>>> allDepartmentSupervisors =
      <String, List<Map<String, dynamic>>>{}.obs;
  final RxString selectedDepartmentId = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    isLoading.value = true;
    await fetchDepartments();
    await fetchAllSupervisors();
    await fetchAllDepartmentSupervisors();
    isLoading.value = false;
  }

  Future<void> fetchDepartments() async {
    try {
      final deps = await _supabaseService.getAllDepartments();
      departments.assignAll(deps);
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to fetch departments: $e',
      );
    }
  }

  Future<void> fetchAllSupervisors() async {
    try {
      final sups = await _supabaseService.getSupervisors();
      allSupervisors.assignAll(sups);
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to fetch supervisors: $e',
      );
    }
  }

  Future<void> fetchDepartmentSupervisors(String depId) async {
    try {
      final sups = await _supabaseService.getSupervisors(departmentId: depId);
      departmentSupervisors.assignAll(sups);
      allDepartmentSupervisors[depId] = sups;
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to fetch department supervisors: $e',
      );
    }
  }

  Future<void> fetchAllDepartmentSupervisors() async {
    try {
      for (var dep in departments) {
        final sups = await _supabaseService.getSupervisors(departmentId: dep['id']);
        allDepartmentSupervisors[dep['id']] = sups;
      }
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to fetch all department supervisors: $e',
      );
    }
  }

  void onDepartmentChanged(String? value) {
    if (value != null) {
      selectedDepartmentId.value = value;
      fetchDepartmentSupervisors(value);
    } else {
      selectedDepartmentId.value = '';
      departmentSupervisors.clear();
    }
  }

  Future<void> assignSupervisor(String supId, String depId) async {
    try {
      final supervisor = allSupervisors.firstWhere((sup) => sup['id'] == supId);
      if (supervisor['department_id'] != null && supervisor['department_id'] != depId) {
        final currentDepId = supervisor['department_id'];
        final currentDep = departments.firstWhere(
          (dep) => dep['id'] == currentDepId,
          orElse: () => {'name': 'Unknown'},
        );
        Get.dialog(
          Dialog(
            backgroundColor: kWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Supervisor Already Assigned',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Supervisor ${supervisor['name']} is already assigned to ${currentDep['name']}. '
                    'Do you want to remove them from ${currentDep['name']} and assign to the new department?',
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text('Cancel', style: TextStyle(color: kPrimaryColor)),
                      ),
                      TextButton(
                        onPressed: () async {
                          await _supabaseService.unassignSupervisorFromDepartment(supId);
                          await _supabaseService.assignSupervisorToDepartment(supId, depId);
                          await fetchDepartmentSupervisors(depId);
                          await fetchAllSupervisors();
                          await fetchAllDepartmentSupervisors();
                          Get.back();
                          Get.snackbar(
                            backgroundColor: kWhite,
                            'Success',
                            'Supervisor assigned successfully',
                          );
                        },
                        child: Text('Confirm', style: TextStyle(color: kPrimaryColor)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        await _supabaseService.assignSupervisorToDepartment(supId, depId);
        await fetchDepartmentSupervisors(depId);
        await fetchAllSupervisors();
        await fetchAllDepartmentSupervisors();
        Get.snackbar(
          backgroundColor: kWhite,
          'Success',
          'Supervisor assigned successfully',
        );
      }
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to assign supervisor: $e',
      );
    }
  }

  Future<void> unassignSupervisor(String supId, String depId) async {
    try {
      await _supabaseService.unassignSupervisorFromDepartment(supId);
      await fetchDepartmentSupervisors(depId);
      await fetchAllSupervisors();
      await fetchAllDepartmentSupervisors();
      Get.snackbar(
        backgroundColor: kWhite,
        'Success',
        'Supervisor unassigned successfully',
      );
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to unassign supervisor: $e',
      );
    }
  }
}