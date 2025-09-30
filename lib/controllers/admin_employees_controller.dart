// File: controllers/admin_employees_controller.dart
import 'package:attendance_app/services/superbase_services.dart';
import 'package:get/Get.dart';

class AdminEmployeesController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<Map<String, dynamic>> employees = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allSupervisors = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = true.obs;
  late String supervisorEmpCode;

  Future<void> fetchEmployeesUnderSupervisor() async {
    try {
      isLoading.value = true;
      final empList = await _supabaseService.getEmployeesBySupervisor(supervisorEmpCode);
      employees.assignAll(empList);
    } catch (e) {
      print('Error fetching employees under supervisor: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllSupervisors() async {
    try {
      final supList = await _supabaseService.getSupervisors();
      allSupervisors.assignAll(supList);
    } catch (e) {
      print('Error fetching all supervisors: $e');
    }
  }

  Future<void> assignEmployeeToSupervisor(String empId, String supId) async {
    try {
      await _supabaseService.assignEmployeeToSupervisor(empId, supId);
      Get.snackbar('Success', 'Employee assigned successfully');
      fetchEmployeesUnderSupervisor();
    } catch (e) {
      Get.snackbar('Error', 'Failed to assign employee: $e');
    }
  }
}