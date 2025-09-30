

// import 'package:attendance_app/constants/app_colors.dart';
// import 'package:attendance_app/controllers/supervisor_home_controller.dart';
// import 'package:attendance_app/generated/assets.dart';
// import 'package:attendance_app/view/screens/supervisor/supervisor_employees.dart';
// import 'package:attendance_app/view/screens/login/login.dart';
// import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
// import 'package:attendance_app/view/widgets/my_button.dart';
// import 'package:attendance_app/view/widgets/text_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../history/history.dart';

// class SupervisorHomeScreen extends StatefulWidget {
//   const SupervisorHomeScreen({super.key});

//   @override
//   State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
// }

// class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
//   final SupervisorHomeController controller = Get.put(SupervisorHomeController());

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhite,
//       appBar: AppBar(
//         backgroundColor: kPrimaryColor,
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: kWhite),
//             onPressed: () async {
//               await controller.authService.logout();
//               Get.offAll(() =>  LoginScreen());
//             },
//           ),
//         ],
//       ),
//       body: Obx(
//         () => controller.isLoading.value
//             ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
//             : SingleChildScrollView(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           Obx(
//                             () => TextWidget(
//                               onTap: () {
//                                 controller.languageController.toggleLanguage();
//                               },
//                               text: controller.languageController.currentLanguage.value,
//                               size: 14,
//                               paddingRight: 1,
//                               textAlign: TextAlign.center,
//                               color: kPrimaryColor,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             padding: const EdgeInsets.all(10),
//                             child: CommonImageView(
//                               imagePath: Assets.imagesLogoNew,
//                               height: 150,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Obx(
//                         () => TextWidget(
//                           text: '${'welcome'.tr} ${controller.authService.currentUser.value?.name ?? "User"}',
//                           size: 24,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       const SizedBox(height: 16),
//                       // Display individual user info fields
//                       Obx(
//                         () => Column(
//                           children: [
//                             TextWidget(
//                               text: controller.empCode.value,
//                               paddingBottom: 8,
//                               paddingTop: 16,
//                             ),
//                             TextWidget(
//                               text: controller.name.value,
//                               paddingBottom: 8,
//                             ),
//                             TextWidget(
//                               text: controller.role.value,
//                               paddingBottom: 8,
//                             ),
//                             TextWidget(
//                               text: controller.department.value,
//                               paddingBottom: 16,
//                             ),
//                           ],
//                         ),
//                       ),
                     
//                       Obx(
//                         () =>controller.geofenceService.geofenceMessage.value.isNotEmpty
//                             ? TextWidget(
//                                    text: controller.geofenceService.geofenceMessage.value,
//                           color: kredColor,
//                                 paddingBottom: 16,
//                                 paddingLeft: 16,
//                                 paddingRight: 16,
//                               )
//                             : const SizedBox.shrink(),
//                       ),
                        
//                       Obx(
//                         () => controller.message.value.isNotEmpty
//                             ? TextWidget(
//                                 text: controller.message.value,
//                                 color: controller.messageColor.value,
//                                 paddingBottom: 16,
//                                 paddingLeft: 16,
//                                 paddingRight: 16,
//                               )
//                             : const SizedBox.shrink(),
//                       ),
//                       ButtonWidget(
//                         onTap: controller.clockIn,
//                         fontColor: kWhite,
//                         buttonText: "clock_in".tr,
//                         backgroundColor: kPrimaryColor,
//                       ),
//                       const SizedBox(height: 20),
//                       ButtonWidget(
//                         onTap: controller.clockOut,
//                         fontColor: kWhite,
//                         buttonText: "clock_out".tr,
//                         backgroundColor: kPrimaryColor,
//                       ),
//                       const SizedBox(height: 20),
//                       ButtonWidget(
//                         onTap: () {
//                           Get.to(() => const HistoryScreen());
//                         },
//                         fontColor: kWhite,
//                         buttonText: "view_history".tr,
//                         backgroundColor: kPrimaryColor,
//                       ),
//                       const SizedBox(height: 20),
//                       ButtonWidget(
//                         onTap: () {
//                           Get.to(() => const SupervisorEmployeesScreen());
//                         },
//                         fontColor: kWhite,
//                         buttonText: "View Employees".tr,
//                         backgroundColor: kPrimaryColor,
//                       ),
//                            const SizedBox(height: 20),
//                     ],
//                   ),
//                 ),
//               ),
//       ),
//     );
//   }
// }

import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/controllers/supervisor_home_controller.dart';
import 'package:attendance_app/generated/assets.dart';
import 'package:attendance_app/view/screens/notification/notification.dart';
import 'package:attendance_app/view/screens/supervisor/supervisor_employees.dart';
import 'package:attendance_app/view/screens/login/login.dart';
import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
import 'package:attendance_app/view/widgets/my_button.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../history/history.dart';

class SupervisorHomeScreen extends StatefulWidget {
  const SupervisorHomeScreen({super.key});

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  final SupervisorHomeController controller = Get.put(SupervisorHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
          actions: [
          IconButton(
            icon: const Icon(Icons.notifications  , color: kWhite),
            onPressed: () async {
                                     Get.to(() => const NotificationsScreen());

            },
          ),
           IconButton(
            icon: const Icon(Icons.logout, color: kWhite),
            onPressed: () async {
              await controller.authService.logout();
              Get.offAll(() => LoginScreen());
            },
          ),
        ],
      ),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Obx(
                            () => TextWidget(
                              onTap: () {
                                controller.languageController.toggleLanguage();
                              },
                              text: controller.languageController.currentLanguage.value,
                              size: 14,
                              paddingRight: 1,
                              textAlign: TextAlign.center,
                              color: kPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            child: CommonImageView(
                              imagePath: Assets.imagesLogoNew,
                              height: 150,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => TextWidget(
                          text: '${'welcome'.tr} ${controller.authService.currentUser.value?.name ?? "User"}',
                          size: 24,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Display individual user info fields
                      Obx(
                        () => Column(
                          children: [
                            TextWidget(
                              text: controller.empCode.value,
                              paddingBottom: 8,
                              paddingTop: 16,
                            ),
                            TextWidget(
                              text: controller.name.value,
                              paddingBottom: 8,
                            ),
                            TextWidget(
                              text: controller.role.value,
                              paddingBottom: 8,
                            ),
                            TextWidget(
                              text: controller.department.value,
                              paddingBottom: 16,
                            ),
                          ],
                        ),
                      ),
                      Obx(
                        () => controller.geofenceService.geofenceMessage.value.isNotEmpty
                            ? TextWidget(
                                text: controller.geofenceService.geofenceMessage.value,
                                color: kredColor,
                                paddingBottom: 16,
                                paddingLeft: 16,
                                paddingRight: 16,
                              )
                            : const SizedBox.shrink(),
                      ),
                      Obx(
                        () => controller.message.value.isNotEmpty
                            ? TextWidget(
                                text: controller.message.value,
                                color: controller.messageColor.value,
                                paddingBottom: 16,
                                paddingLeft: 16,
                                paddingRight: 16,
                              )
                            : const SizedBox.shrink(),
                      ),
                      ButtonWidget(
                        onTap: controller.clockIn,
                        fontColor: kWhite,
                        buttonText: "clock_in".tr,
                        backgroundColor: kPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        onTap: controller.clockOut,
                        fontColor: kWhite,
                        buttonText: "clock_out".tr,
                        backgroundColor: kPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        onTap: () {
                          Get.to(() => const HistoryScreen());
                        },
                        fontColor: kWhite,
                        buttonText: "view_history".tr,
                        backgroundColor: kPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                      ButtonWidget(
                        onTap: () {
                          Get.to(() => const SupervisorEmployeesScreen());
                        },
                        fontColor: kWhite,
                        buttonText: "View Employees".tr,
                        backgroundColor: kPrimaryColor,
                      ),
                      const SizedBox(height: 20),
                     
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}