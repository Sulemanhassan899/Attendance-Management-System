// File: view/screens/admin/admin_employees.dart
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/controllers/admin_employees_controller.dart';
import 'package:attendance_app/view/widgets/custom_dropdown.dart'; // Assume this exists
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';

class AdminEmployeesScreen extends StatefulWidget {
  final String supervisorEmpCode;
  const AdminEmployeesScreen({super.key, required this.supervisorEmpCode});

  @override
  State<AdminEmployeesScreen> createState() => _AdminEmployeesScreenState();
}

class _AdminEmployeesScreenState extends State<AdminEmployeesScreen> {
  final AdminEmployeesController controller = Get.put(AdminEmployeesController());

  @override
  void initState() {
    super.initState();
    controller.supervisorEmpCode = widget.supervisorEmpCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAllSupervisors();
      controller.fetchEmployeesUnderSupervisor();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: TextWidget(
          text: "Employees".tr,
          color: kWhite,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.employees.isEmpty) {
          return Center(child: Text('No employees found'.tr));
        }
        return ListView.builder(
          padding: EdgeInsets.all(8),
          itemCount: controller.employees.length,
          itemBuilder: (context, index) {
            final emp = controller.employees[index];
            return EmployeeCard(employee: emp, controller: controller);
          },
        );
      }),
    );
  }
}

class EmployeeCard extends StatelessWidget {
  final Map<String, dynamic> employee;
  final AdminEmployeesController controller;

  const EmployeeCard({super.key, required this.employee, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Bounce(
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
                  text: employee['name'] ?? 'Unknown',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: "Code:".tr),
                TextWidget(
                  text: employee['emp_code'] ?? 'N/A',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: "Role:".tr),
                TextWidget(
                  text: employee['role'] ?? 'N/A',
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextWidget(text: "department:".tr),
                TextWidget(
                  text: employee['department']?['name'] ?? 'N/A',
                ),
              ],
            ),
            // Reassign Supervisor
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: CustomDropDown(
                    hint: 'Reassign Supervisor'.tr,
                    items: controller.allSupervisors.map((sup) => sup['name'] as String).toList(),
                    selectedValue: null,
                    onChanged: (value) {
                      final supId = controller.allSupervisors.firstWhere((sup) => sup['name'] == value)['id'];
                      controller.assignEmployeeToSupervisor(employee['id'], supId);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}