

import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/generated/assets.dart';
import 'package:attendance_app/view/screens/login/login.dart';
import 'package:attendance_app/view/screens/notification/notification.dart';
import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
import 'package:attendance_app/view/widgets/my_button.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/home_controller.dart';
import '../history/history.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: kWhite),
            onPressed: () => Get.to(() => const NotificationsScreen()),
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
            ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Obx(
                        () => TextWidget(
                          onTap: () => controller.languageController.toggleLanguage(),
                          text: controller.languageController.currentLanguage.value,
                          size: 14,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: CommonImageView(
                        imagePath: Assets.imagesLogoNew,
                        height: 150,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(
                      () => TextWidget(
                        text:
                            '${'welcome'.tr} ${controller.authService.currentUser.value?.name ?? "User"}',
                        size: 24,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(
                      () => Column(
                        children: [
                          TextWidget(text: controller.empCode.value),
                          TextWidget(text: controller.name.value),
                          TextWidget(text: controller.role.value),
                          TextWidget(text: controller.department.value),
                          TextWidget(text: controller.supervisor.value),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(
                      () => controller.message.value.isNotEmpty
                          ? TextWidget(
                              text: controller.message.value.tr,
                              color: controller.messageColor.value,
                              paddingTop: 10,
                              textAlign: TextAlign.center,
                            )
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),

                    // Clock In Button
                    Obx(() => ButtonWidget(       fontWeight: FontWeight.bold,
                      fontSize: 16,
                          onTap: controller.isClockedIn.value
                              ? null
                              : () async => await controller.clockIn(),
                          fontColor: kWhite,
                          buttonText: controller.clockInButtonText.value,
                          backgroundColor: controller.isClockedIn.value
                              ? kGreyColor
                              : kgreenColor,
                        )),
                    const SizedBox(height: 20),

                    // Clock Out Button
                    Obx(() => ButtonWidget(       fontWeight: FontWeight.bold,
                      fontSize: 16,
                          onTap: controller.isClockedIn.value
                              ? () async => await controller.clockOut()
                              : null,
                          fontColor: kWhite,
                          buttonText: controller.clockOutButtonText.value,
                          backgroundColor: controller.isClockedIn.value
                              ? Colors.red
                              : kGreyColor,
                        )),

                    // Live Duration Display
                 
                    const SizedBox(height: 20),

                    // View History
                    ButtonWidget(       fontWeight: FontWeight.bold,
                      fontSize: 16,
                      onTap: () => Get.to(() => const HistoryScreen()),
                      fontColor: kWhite,
                      buttonText: "view_history".tr,
                      backgroundColor: kPrimaryColor,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
