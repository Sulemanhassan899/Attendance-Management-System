// File: view/screens/admin/admin_supervisors.dart
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/controllers/admin_home_controller_supervisor.dart';
import 'package:attendance_app/view/screens/admin/admin_employees.dart';
import 'package:attendance_app/view/widgets/custom_dropdown.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminSupervisorsScreen extends StatefulWidget {
  const AdminSupervisorsScreen({super.key});

  @override
  State<AdminSupervisorsScreen> createState() => _AdminSupervisorsScreenState();
}

class _AdminSupervisorsScreenState extends State<AdminSupervisorsScreen> {
  final AdminSupervisorsController controller = Get.put(AdminSupervisorsController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDepartments();
      controller.fetchOfficeLocations();
      controller.fetchSupervisors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: TextWidget(
          text: "Supervisors".tr,
          color: kWhite,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Department
                Expanded(
                  child: Obx(() => CustomDropDown(
                        hint: 'Select Department'.tr,
                        labelText: 'Department'.tr,
                        items: controller.departments.map((dep) => dep['name'] as String).toList(),
                        selectedValue: controller.selectedDepartment.value,
                        onChanged: controller.onDepartmentChanged,
                        width: double.infinity,
                        marginBottom: 0,
                      )),
                ),
                const SizedBox(width: 10),
                // Office Location (Geofence)
                Expanded(
                  child: Obx(() => CustomDropDown(
                        hint: 'Select Geofence'.tr,
                        labelText: 'Geofence'.tr,
                        items: controller.officeLocations.map((loc) => loc['name'] as String).toList(),
                        selectedValue: controller.selectedLocation.value,
                        onChanged: controller.onLocationChanged,
                        width: double.infinity,
                        marginBottom: 0,
                      )),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.supervisors.isEmpty) {
                return Center(child: Text('No supervisors found'.tr));
              }
              return ListView.builder(
                padding: EdgeInsets.all(8),
                itemCount: controller.supervisors.length,
                itemBuilder: (context, index) {
                  final sup = controller.supervisors[index];
                  return SupervisorCard(supervisor: sup, controller: controller);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class SupervisorCard extends StatelessWidget {
  final Map<String, dynamic> supervisor;
  final AdminSupervisorsController controller;

  const SupervisorCard({super.key, required this.supervisor, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Bounce(
      child: GestureDetector(
        onTap: () {
          Get.to(() => AdminEmployeesScreen(supervisorEmpCode: supervisor['emp_code']));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: kWhite,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(text: "Name:".tr),
                  TextWidget(
                    text: supervisor['name'] ?? 'Unknown',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(text: "Code:".tr),
                  TextWidget(
                    text: supervisor['emp_code'] ?? 'N/A',
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextWidget(text: "Department:".tr),
                  TextWidget(
                    text: supervisor['department']?['name'] ?? 'N/A',
                  ),
                ],
              ),
          ],
          ),
        ),
      ),
    );
  }
}