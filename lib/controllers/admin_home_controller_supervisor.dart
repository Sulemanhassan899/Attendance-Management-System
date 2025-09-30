// File: controllers/admin_supervisors_controller.dart
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/services/superbase_services.dart';
import 'package:get/get.dart';

class AdminSupervisorsController extends GetxController {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();

  final RxList<Map<String, dynamic>> supervisors = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> departments = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> officeLocations =
      <Map<String, dynamic>>[].obs;
  final RxString selectedDepartment = 'All'.obs;
  final RxString selectedLocation = 'All'.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize with 'All' options
    departments.add({'id': null, 'name': 'All'});
    officeLocations.add({'id': null, 'name': 'All'});
    // Fetch data on initialization
    fetchDepartments();
    fetchOfficeLocations();
    fetchSupervisors();
  }

  Future<void> fetchDepartments() async {
    try {
      print('Fetching departments...');
      final deps = await _supabaseService.getAllDepartments();
      departments.clear();
      departments.add({'id': null, 'name': 'All'});
      departments.addAll(deps);
      print('Departments fetched: $deps');
    } catch (e) {
      print('Error fetching departments: $e');
    }
  }

  Future<void> fetchOfficeLocations() async {
    try {
      print('Fetching office locations...');
      final locs = await _supabaseService.getAllOfficeLocations();
      officeLocations.clear();
      officeLocations.add({'id': null, 'name': 'All'});
      officeLocations.addAll(locs);
      print('Office locations fetched: $locs');
    } catch (e) {
      print('Error fetching office locations: $e');
    }
  }

  Future<void> fetchSupervisors() async {
    isLoading.value = true;
    try {
      String? depId = selectedDepartment.value != 'All'
          ? departments.firstWhere(
              (dep) => dep['name'] == selectedDepartment.value,
              orElse: () => {'id': null},
            )['id']
          : null;
      String? locId = selectedLocation.value != 'All'
          ? officeLocations.firstWhere(
              (loc) => loc['name'] == selectedLocation.value,
              orElse: () => {'id': null},
            )['id']
          : null;
      print('Fetching supervisors with depId: $depId, locId: $locId');
      final supList = await _supabaseService.getSupervisors(
        departmentId: depId,
        locationId: locId,
      );
      supervisors.assignAll(supList);
      print('Supervisors fetched: $supList');
    } catch (e) {
      print('Error fetching supervisors: $e');
      supervisors.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void onDepartmentChanged(String? value) {
    selectedDepartment.value = value ?? 'All';
    print('Department changed to: ${selectedDepartment.value}');
    fetchSupervisors();
  }

  void onLocationChanged(String? value) {
    selectedLocation.value = value ?? 'All';
    print('Location changed to: ${selectedLocation.value}');
    fetchSupervisors();
  }

  Future<void> assignSupervisorToDepartment(String supId, String depId) async {
    try {
      await _supabaseService.assignSupervisorToDepartment(supId, depId);
      fetchSupervisors();
    } catch (e) {
      Get.snackbar(
        backgroundColor: kWhite,
        'Error',
        'Failed to assign department: $e',
      );
    }
  }
}
