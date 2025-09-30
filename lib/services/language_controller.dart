import 'package:attendance_app/languages/en.dart';
import 'package:attendance_app/languages/ur.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class LanguageController extends GetxController {
  var currentLanguage = 'English'.obs;
  var isUrdu = false.obs;

  void toggleLanguage() {
    if (isUrdu.value) {
      currentLanguage.value = 'English';
      isUrdu.value = false;
      Get.updateLocale(const Locale('en', 'US'));
    } else {
      currentLanguage.value = 'اردو';
      isUrdu.value = true;
      Get.updateLocale(const Locale('ur', 'PK'));
    }
  }

  String get currentLanguageCode => isUrdu.value ? 'ur' : 'en';
}


class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'ur_PK': urPK,
      };
}