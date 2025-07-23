// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:

import 'package:get/get.dart';
import 'package:lms_flutter_app/Config/app_config.dart';

// Project imports:
import 'package:lms_flutter_app/Controller/dashboard_controller.dart';
import 'package:lms_flutter_app/Views/Account/widgets/auth_textfield.dart';
import 'package:lms_flutter_app/utils/translation_helper.dart';

class RegisterPage extends GetView<DashboardController> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CupertinoActivityIndicator());
        } else {
          return ListView(
            physics: BouncingScrollPhysics(),
            children: [
              Container(
                height: 70,
                width: 70,
                child: Image.asset('images/signin_img.png'),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  child: Text(
                    TranslationHelper.tr("Register"),
                    style: Get.textTheme.titleMedium?.copyWith(fontSize: 24),
                  ),
                ),
              ),
              AuthTextField(
                controller: controller.registerFullName,
                hintText: TranslationHelper.tr("Name"),
                suffixIcon: Icons.person,
              ),
              AuthTextField(
                controller: controller.registerEmail,
                hintText: TranslationHelper.tr("Email"),
                suffixIcon: Icons.email,
              ),
              AuthTextField(
                controller: controller.registerStudentPhone,
                hintText: TranslationHelper.tr("Student phone number"),
                suffixIcon: Icons.phone,
              ),
              AuthTextField(
                controller: controller.registerStudentWhatsApp,
                hintText: TranslationHelper.tr("student_whatsapp_number"),
                suffixIcon: Icons.phone,
              ),
              AuthTextField(
                controller: controller.registerGuardianNumber,
                hintText: TranslationHelper.tr("guardian_number"),
                suffixIcon: Icons.phone,
              ),
              AuthTextField(
                controller: controller.registerPassword,
                hintText: TranslationHelper.tr("Password"),
                obscureText: controller.obscureNewPass.value,
                suffixIcon: controller.obscureNewPass.value
                    ? Icons.lock_rounded
                    : Icons.lock_open,
                onSuffixIconTap: () {
                  controller.obscureNewPass.value =
                      !controller.obscureNewPass.value;
                },
              ),
              AuthTextField(
                controller: controller.registerConfirmPassword,
                hintText: TranslationHelper.tr("Confirm Password"),
                obscureText: controller.obscureConfirmPass.value,
                suffixIcon: controller.obscureConfirmPass.value
                    ? Icons.lock_rounded
                    : Icons.lock_open,
                onSuffixIconTap: () {
                  controller.obscureConfirmPass.value =
                      !controller.obscureConfirmPass.value;
                },
              ),
              Container(
                height: 70,
                margin: EdgeInsets.symmetric(horizontal: 100),
                alignment: Alignment.center,
                child: GestureDetector(
                  child: Container(
                    alignment: Alignment.center,
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Get.theme.primaryColor,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(TranslationHelper.tr("Register")),
                  ),
                  onTap: () async {
                    await controller.fetchUserRegister();
                  },
                ),
              ),
              Center(
                child: InkWell(
                  onTap: () {
                    controller.showRegisterScreen();
                  },
                  child: Container(
                    margin: EdgeInsets.only(top: 15),
                    child: Text(
                      TranslationHelper.tr(
                          "Already have an account? Login now"),
                      style: Get.textTheme.titleMedium?.copyWith(fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100),
            ],
          );
        }
      }),
    );
  }
}
