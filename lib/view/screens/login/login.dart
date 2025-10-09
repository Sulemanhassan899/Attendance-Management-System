

import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/generated/assets.dart';
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/services/notification_service.dart';
import 'package:attendance_app/services/permission_service.dart';
import 'package:attendance_app/view/screens/login/form_validator.dart';
import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
import 'package:attendance_app/view/widgets/my_button.dart';
import 'package:attendance_app/view/widgets/my_textfeild.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:bounce/bounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FocusNode _focusNodeEmail = FocusNode();
  final FocusNode _focusNodePassword = FocusNode();
  final _formKey = GlobalKey<FormState>();
  final _authService = Get.find<AuthService>();
  final _empCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxString empCodeError = ''.obs;
  final RxString passwordError = ''.obs;
  final RxString networkError = ''.obs; // New observable for network errors
  bool _isPasswordObscured = true;

  Future<void> _login() async {
    // Clear previous errors
    empCodeError.value = '';
    passwordError.value = '';
    networkError.value = '';

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate internet connectivity
    final internetError = await FormValidator().validateInternet();
    if (internetError != null) {
      networkError.value = internetError;
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: internetError,
      );
      return;
    }

    // Validate location permission
    final hasLocation = await PermissionService.checkLocationPermission();
    if (!hasLocation) {
      networkError.value = 'Location permission required. Please enable it.';
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'Location permission required. Please enable it.',
      );
      return;
    }

    isLoading.value = true;
    try {
      final empCode = _empCodeController.text.trim();
      final password = _passwordController.text.trim();
      final success = await _authService.login(empCode, password);
      if (!success) {
        passwordError.value = 'Invalid employee code or password';
      }
    } catch (e) {
      networkError.value = 'Login failed. Please try again: $e';
      await NotificationService.showNotification(
        title: 'Login Failed',
        body: 'Login failed. Please try again: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void dispose() {
    _focusNodeEmail.dispose();
    _focusNodePassword.dispose();
    _empCodeController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TextWidget(
            text: "copyright of Top Matics".tr,
            size: 12,
            textAlign: TextAlign.center,
            paddingBottom: 30,
            paddingTop: 100,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          const SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImageView(
                imagePath: Assets.imagesLogoNew,
                height: 150,
              ),
            ],
          ),
          const SizedBox(height: 46),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyTextField(
                  hint: "emp001",
                  marginBottom: 12,
                  controller: _empCodeController,
                  focusNode: _focusNodeEmail,
                  validator: FormValidator().validateEmpCode,
                ),
                Obx(
                  () => empCodeError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: TextWidget(
                            text: empCodeError.value,
                            color: Colors.red,
                            size: 14,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                MyTextField(
                  hint: "Password",
                  marginBottom: 12,
                  controller: _passwordController,
                  focusNode: _focusNodePassword,
                  isObSecure: _isPasswordObscured,
                  suffix: Bounce(
                    onTap: () {
                      setState(() {
                        _isPasswordObscured = !_isPasswordObscured;
                      });
                    },
                                 child:Icon(
                      _isPasswordObscured
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: kGreyColor,
                    ),
                  
                  ),
                  validator: FormValidator().validatePassword,
                ),
                Obx(
                  () => passwordError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: TextWidget(
                            text: passwordError.value,
                            color: Colors.red,
                            size: 14,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                Obx(
                  () => networkError.value.isNotEmpty
                      ? Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: TextWidget(
                            text: networkError.value,
                            color: Colors.red,
                            size: 14,
                          ),
                        )
                      : SizedBox.shrink(),
                ),
                Obx(
                  () => ButtonWidget(
                    radius: 12,
                    mTop: 20,
                    onTap: () {
                      if (!isLoading.value) _login();
                    },
                    fontColor: kWhite,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    buttonText: isLoading.value ? "Loading...".tr : "Login".tr,
                    backgroundColor: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}