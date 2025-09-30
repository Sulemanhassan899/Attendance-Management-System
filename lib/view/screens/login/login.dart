
// // File: view/screens/login/login.dart
// import 'package:attendance_app/constants/app_colors.dart';
// import 'package:attendance_app/generated/assets.dart';
// import 'package:attendance_app/services/permission_service.dart';
// import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
// import 'package:attendance_app/view/widgets/my_button.dart';
// import 'package:attendance_app/view/widgets/my_textfeild.dart';
// import 'package:attendance_app/view/widgets/text_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:get/Get.dart';
// import '../../../services/auth_services.dart';

// class LoginScreen extends StatefulWidget {
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _authService = Get.find<AuthService>();

//   final _empCodeController = TextEditingController();

//   final _passwordController = TextEditingController();

//   final RxString errorMessage = ''.obs;

//   final RxBool isLoading = false.obs;


// Future<void> _login() async {
//   final hasNetwork = await PermissionService.checkNetwork();
//   if (!hasNetwork) {
//     errorMessage.value =
//         'No internet connection. Please connect to WiFi or Mobile Data.'.tr;
//     return;
//   }

//   final hasLocation = await PermissionService.checkLocationPermission();
//   if (!hasLocation) {
//     errorMessage.value = 'Location permission required. Please enable it.'.tr;
//     return;
//   }
//   final empCode = _empCodeController.text.trim();
//   final password = _passwordController.text.trim();

//   print('Login button pressed with: "$empCode" / "$password"');

//   errorMessage.value = '';

//   if (empCode.isEmpty || password.isEmpty) {
//     errorMessage.value = 'Please enter both employee code and password'.tr;
//     return;
//   }

//   isLoading.value = true;

//   try {
//     final success = await _authService.login(empCode, password);

//     if (success) {
//       // Login successful, navigation is handled in AuthService
//     } else {
//       errorMessage.value = 'Invalid employee code or password'.tr;
//     }
//   } catch (e) {
//     print('Login screen error: $e');
//     errorMessage.value = 'Login failed. Please try again.'.tr;
//   } finally {
//     isLoading.value = false;
//   }
// }


 

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kWhite,
     
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [

//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.all(16),
//               children: [
//                         SizedBox(height: 50,),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Container(
//                       padding: EdgeInsets.all(10),
//                       child: CommonImageView(imagePath: Assets.imagesLogo2, height: 150,)),
//                   ],
//                 ),
            
            
//                 TextWidget(
//                   text:
//                    "Attendance System".tr,
//                   size: 24,
//                   textAlign: TextAlign.center,
//                   paddingBottom: 30,
//                   paddingTop: 10,
//                 ),
              
//                 MyTextField(
//                   controller: _empCodeController,
//                   label: 'Employee Code'.tr,
//                   bordercolor: kBorderColor,
//                   prefix: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Icon(Icons.person),
//                   ),
//                   hint: 'EMP001',
//                 ),
            
//                 MyTextField(
//                   controller: _passwordController,
//                   label: 'Password'.tr,
//                   bordercolor: kBorderColor,
//                   prefix: Padding(
//                     padding: const EdgeInsets.symmetric(horizontal: 10),
//                     child: Icon(Icons.lock),
//                   ),
//                   hint: 'pass123',
//                 ),
//                 SizedBox(height: 16),
//                 Center(
//                   child: Obx(
//                     () => errorMessage.value.isNotEmpty
//                         ? TextWidget(
//                             text: errorMessage.value,
//                             color: kredColor,
//                             size: 14,
//                           )
//                         : SizedBox.shrink(),
//                   ),
//                 ),
//                 SizedBox(height: 20),
//                 Obx(
//                   () => ButtonWidget(
//                     radius: 12,
//                     onTap: () {
//                       isLoading.value ? null : _login();
//                     },
//                     fontColor: kWhite,
//                     buttonText: isLoading.value ? "Loading...".tr : "Login".tr,
//                     backgroundColor: kPrimaryColor,
//                   ),
//                 ),
            
         
//               ],
//             ),
//           ),
//         TextWidget(
//                   text: "copyright of Top Matics".tr,
//                   size: 12 ,
//                   textAlign: TextAlign.center,
//                   paddingBottom: 30,
//                   paddingTop: 10,
//                 ),
//         ],
//       ),
//     );
//   }
// }

import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/generated/assets.dart';
import 'package:attendance_app/services/notification_service.dart';
import 'package:attendance_app/services/permission_service.dart';
import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
import 'package:attendance_app/view/widgets/my_button.dart';
import 'package:attendance_app/view/widgets/my_textfeild.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';
import '../../../services/auth_services.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = Get.find<AuthService>();
  final RxString errorMessage = ''.obs;
  final RxBool isLoading = false.obs;
  final _empCodeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    NotificationService.initialize();
  }

  Future<void> _login() async {
    final hasNetwork = await PermissionService.checkNetwork();
    if (!hasNetwork) {
      errorMessage.value =
          'No internet connection. Please connect to WiFi or Mobile Data.'.tr;
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'No internet connection. Please connect to WiFi or Mobile Data.',
      );
      return;
    }

    final hasLocation = await PermissionService.checkLocationPermission();
    if (!hasLocation) {
      errorMessage.value = 'Location permission required. Please enable it.'.tr;
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'Location permission required. Please enable it.',
      );
      return;
    }
    final empCode = _empCodeController.text.trim();
    final password = _passwordController.text.trim();

    print('Login button pressed with: "$empCode" / "$password"');

    errorMessage.value = '';

    if (empCode.isEmpty || password.isEmpty) {
      errorMessage.value = 'Please enter both employee code and password'.tr;
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'Please enter both employee code and password.',
      );
      return;
    }

    isLoading.value = true;

    try {
      final success = await _authService.login(empCode, password);

      if (!success) {
        errorMessage.value = 'Invalid employee code or password'.tr;
      }
    } catch (e) {
      print('Login screen error: $e');
      errorMessage.value = 'Login failed. Please try again.'.tr;
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'Login failed. Please try again: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                SizedBox(height: 50),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: CommonImageView(
                        imagePath: Assets.imagesLogo2,
                        height: 150,
                      ),
                    ),
                  ],
                ),
                TextWidget(
                  text: "Attendance System".tr,
                  size: 24,
                  textAlign: TextAlign.center,
                  paddingBottom: 30,
                  paddingTop: 10,
                ),
                MyTextField(
                  controller: _empCodeController,
                  label: 'Employee Code'.tr,
                  bordercolor: kBorderColor,
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.person),
                  ),
                  hint: 'EMP001',
                ),
                MyTextField(
                  controller: _passwordController,
                  label: 'Password'.tr,
                  bordercolor: kBorderColor,
                  prefix: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Icon(Icons.lock),
                  ),
                  hint: 'pass123',
                ),
                SizedBox(height: 16),
                Center(
                  child: Obx(
                    () => errorMessage.value.isNotEmpty
                        ? TextWidget(
                            text: errorMessage.value,
                            color: kredColor,
                            size: 14,
                          )
                        : SizedBox.shrink(),
                  ),
                ),
                SizedBox(height: 20),
                Obx(
                  () => ButtonWidget(
                    radius: 12,
                    onTap: () {
                      isLoading.value ? null : _login();
                    },
                    fontColor: kWhite,
                    buttonText: isLoading.value ? "Loading...".tr : "Login".tr,
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
          TextWidget(
            text: "copyright of Top Matics".tr,
            size: 12,
            textAlign: TextAlign.center,
            paddingBottom: 30,
            paddingTop: 10,
          ),
        ],
      ),
    );
  }
}