

// File: view/screens/login/login_wrapper.dart
import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/models/user_models.dart' as app_models;
import 'package:attendance_app/services/auth_services.dart';
import 'package:attendance_app/view/screens/admin/home_admin.dart';
import 'package:attendance_app/view/screens/employee/home.dart';
import 'package:attendance_app/view/screens/supervisor/home_supervisor.dart';
import 'package:attendance_app/view/screens/login/login.dart';
import 'package:flutter/material.dart';
import 'package:get/Get.dart';

class LoginWrapper extends StatelessWidget {
  LoginWrapper({super.key});

  final AuthService _authService = Get.find<AuthService>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(), // Check if user is logged in
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading indicator while checking login status
          return const Scaffold(
            backgroundColor: kWhite,
            body: Center(child: CircularProgressIndicator(color: kPrimaryColor,)),
          );
        }

        if (snapshot.data == true) {
          return FutureBuilder<app_models.User?>(
            future: _authService.getCurrentUser(), 
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.data != null) {
                final role = userSnapshot.data!.role;

                if (role == 'employee') {
                  return HomeScreen();
                } else if (role == 'supervisor') {
                  return SupervisorHomeScreen();
                } else if (role == 'admin') {
                  return AdminHomeScreen();
                } else {
                  return const Scaffold(
                    body: Center(child: Text('Role not recognized')),
                  );
                }
              } else {
                return LoginScreen();
              }
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}