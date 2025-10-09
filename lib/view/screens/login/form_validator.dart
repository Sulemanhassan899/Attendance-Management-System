import 'package:attendance_app/services/permission_service.dart';
import 'package:flutter/material.dart';

class FormValidator {
  // Validates employee code
  String? validateEmpCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Employee code is required';
    }

    final trimmedValue = value.trim();

    // Match prefixes: emp, sup, adm — followed by one or more digits
    final validPattern = RegExp(r'^(emp|sup|adm)\d+$');

    if (!validPattern.hasMatch(trimmedValue)) {
      return 'Employee code must start with "emp", "sup", or "adm" followed by numbers';
    }

    return null;
  }

  // Validates password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.trim().length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  // Validates internet connectivity
  Future<String?> validateInternet() async {
    final hasNetwork = await PermissionService.checkNetwork();
    if (!hasNetwork) {
      return 'No internet connection. Please connect to WiFi or Mobile Data.';
    }
    return null;
  }

  // Legacy email validator (redirects to empCode validation)
  String? emailValidator(String? value) => validateEmpCode(value);

  // Legacy password validator (redirects to password validation)
  String? passwordValidator(String? value) => validatePassword(value);
}
