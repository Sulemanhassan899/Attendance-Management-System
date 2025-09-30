// import 'package:attendance_app/constants/app_colors.dart';
// import 'package:attendance_app/controllers/assigned_supervisors_controller.dart';
// import 'package:attendance_app/view/widgets/custom_dropdown.dart';
// import 'package:attendance_app/view/widgets/my_button.dart';
// import 'package:attendance_app/view/widgets/text_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class AssignedSupervisorsScreen extends StatefulWidget {
//   const AssignedSupervisorsScreen({super.key});

//   @override
//   State<AssignedSupervisorsScreen> createState() => _AssignedSupervisorsScreenState();
// }

// class _AssignedSupervisorsScreenState extends State<AssignedSupervisorsScreen> {
//   @override
//   Widget build(BuildContext context) {
//     final AssignedSupervisorsController controller = Get.put(AssignedSupervisorsController());

//     return Scaffold(
//       appBar: AppBar(
//         title: TextWidget(text: 'Assigned Supervisors'.tr, color: kWhite),
//         backgroundColor: kPrimaryColor,
//          leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Get.back(),
//         ),
//       ),
//       body: Obx(
//         () => controller.isLoading.value
//             ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
//             : Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                 CustomDropDown(
//                       hint: 'Select Department'.tr,
//                       items: controller.departments.map((dep) => dep['id'] as String).toList(),
//                       selectedValue: controller.selectedDepartmentId.value.isEmpty ? null : controller.selectedDepartmentId.value,
//                       onChanged: controller.onDepartmentChanged,
//                       bgColor: kWhite,
//                       labelText: 'Department'.tr,
//                       itemsDisplay: controller.departments.map((dep) => dep['name'] as String).toList(),
//                     ),
//                     const SizedBox(height: 20),
//                     if (controller.selectedDepartmentId.value.isNotEmpty) ...[
//                       TextWidget(text: 'Supervisors:'.tr, size: 18, weight: FontWeight.w600),
//                       const SizedBox(height: 10),
//                       Wrap(
//                         spacing: 8.0,
//                         runSpacing: 8.0,
//                         children: controller.departmentSupervisors.map((sup) {
//                           return Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                             decoration: BoxDecoration(
//                               color: kPrimaryColor,
//                               borderRadius: BorderRadius.circular(20),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 TextWidget(text:  sup['name'], color: kWhite,),
//                                 IconButton(
//                                   icon: const Icon(Icons.close, size: 18, color: kWhite,),
//                                   onPressed: () => controller.unassignSupervisor(
//                                     sup['id'],

//                                     controller.selectedDepartmentId.value,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                       const SizedBox(height: 20),
//                       ButtonWidget(
//                         onTap: () {
//                           final availableSupervisors = controller.allSupervisors.where(
//                             (sup) => sup['department_id'] != controller.selectedDepartmentId.value,
//                           ).toList();

//                           Get.dialog(
//                             Dialog(
//                               backgroundColor: kWhite,
//                               shape: RoundedRectangleBorder(

//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Padding(
//                                 padding: const EdgeInsets.all(16.0),
//                                 child: Column(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     TextWidget(
//                                       text: 'Assign Supervisor'.tr,
//                                       size: 18,
//                                       weight: FontWeight.w600,
//                                     ),
//                                     const SizedBox(height: 16),
//                                    CustomDropDown(
//                                       hint: 'Select Supervisor'.tr,
//                                       items: availableSupervisors.map((sup) => sup['id'] as String).toList(),
//                                       itemsDisplay: availableSupervisors.map((sup) => sup['name'] as String).toList(),
//                                       selectedValue: null,
//                                       onChanged: (value) {
//                                         if (value != null) {
//                                           controller.assignSupervisor(value, controller.selectedDepartmentId.value);
//                                           Get.back();
//                                         }
//                                       },
//                                       bgColor: kWhite,
//                                       labelText: 'Supervisor'.tr,
//                                     ),
//                                     const SizedBox(height: 16),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.end,
//                                       children: [
//                                         TextButton(
//                                           onPressed: () => Get.back(),
//                                           child: TextWidget(text: 'Cancel'.tr, color: kPrimaryColor),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                         buttonText: 'Assign New Supervisor'.tr,
//                         backgroundColor: kPrimaryColor,
//                         fontColor: kWhite,
//                       ),
// Spacer(),                     ButtonWidget(
//                         onTap: () {
//                           Get.back();
//                         },
//                         mBottom: 20,
//                         buttonText: 'Save'.tr,
//                         backgroundColor: kPrimaryColor,
//                         fontColor: kWhite,
//                       ),
//                     ],
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/controllers/assigned_supervisors_controller.dart';
import 'package:attendance_app/view/widgets/custom_dropdown.dart';
import 'package:attendance_app/view/widgets/my_button.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssignedSupervisorsScreen extends StatefulWidget {
  const AssignedSupervisorsScreen({super.key});

  @override
  State<AssignedSupervisorsScreen> createState() =>
      _AssignedSupervisorsScreenState();
}

class _AssignedSupervisorsScreenState extends State<AssignedSupervisorsScreen> {
  @override
  Widget build(BuildContext context) {
    final AssignedSupervisorsController controller = Get.put(
      AssignedSupervisorsController(),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextWidget(text: 'Assigned Supervisors'.tr, color: kWhite),
        backgroundColor: kPrimaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(color: kPrimaryColor),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomDropDown(
                      hint: 'Select Department'.tr,
                      items: controller.departments
                          .map((dep) => dep['id'] as String)
                          .toList(),
                      selectedValue:
                          controller.selectedDepartmentId.value.isEmpty
                          ? null
                          : controller.selectedDepartmentId.value,
                      onChanged: controller.onDepartmentChanged,
                      bgColor: kWhite,
                      labelText: 'Department'.tr,
                      itemsDisplay: controller.departments
                          .map((dep) => dep['name'] as String)
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    if (controller.selectedDepartmentId.value.isNotEmpty) ...[
                      TextWidget(
                        text: 'Supervisors:'.tr,
                        size: 18,
                        weight: FontWeight.w600,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: controller.departmentSupervisors.map((sup) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextWidget(text: sup['name'], color: kWhite),
                                IconButton(
                                  icon: const Icon(
                                    Icons.close,
                                    size: 18,
                                    color: kWhite,
                                  ),
                                  onPressed: () =>
                                      controller.unassignSupervisor(
                                        sup['id'],
                                        controller.selectedDepartmentId.value,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        onTap: () {
                          final availableSupervisors = controller.allSupervisors
                              .where(
                                (sup) =>
                                    sup['department_id'] !=
                                    controller.selectedDepartmentId.value,
                              )
                              .toList();

                          if (availableSupervisors.isEmpty) {
                            Get.snackbar(
                              backgroundColor: kWhite,
                              'Info',
                              'No available supervisors to assign',
                            );
                            return;
                          }

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
                                    TextWidget(
                                      text: 'Assign Supervisor'.tr,
                                      size: 18,
                                      weight: FontWeight.w600,
                                    ),
                                    const SizedBox(height: 16),
                                    CustomDropDown(
                                      hint: 'Select Supervisor'.tr,
                                      items: availableSupervisors
                                          .map((sup) => sup['id'] as String)
                                          .toList(),
                                      itemsDisplay: availableSupervisors
                                          .map((sup) => sup['name'] as String)
                                          .toList(),
                                      selectedValue: null,
                                      onChanged: (value) {
                                        if (value != null) {
                                          controller.assignSupervisor(
                                            value,
                                            controller
                                                .selectedDepartmentId
                                                .value,
                                          );
                                        }
                                      },
                                      bgColor: kWhite,
                                      labelText: 'Supervisor'.tr,
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextWidget(
                                          onTap: () => Get.back(),
                                          text: 'Cancel'.tr,
                                          color: kPrimaryColor,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                        buttonText: 'Assign New Supervisor'.tr,
                        backgroundColor: kPrimaryColor,
                        fontColor: kWhite,
                      ),
                      const Spacer(),
                      ButtonWidget(
                        onTap: () {
                          Get.back();
                        },
                        mBottom: 20,
                        buttonText: 'Save'.tr,
                        backgroundColor: kPrimaryColor,
                        fontColor: kWhite,
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }
}
