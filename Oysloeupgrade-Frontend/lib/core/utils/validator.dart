import 'package:flutter/material.dart';

class CustomValidator {
  static final _emailRegex = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  static String? isNotEmpty(String value) {
    if (value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? validateEmail(String email) {
    if (!_emailRegex.hasMatch(email.trim())) {
      return 'Invalid email address';
    }
    return null;
  }

  static bool validateForm(GlobalKey<FormState> formKey) {
    final isFormValid = formKey.currentState?.validate();

    if (isFormValid != true) {
      return false;
    }
    formKey.currentState!.save();
    return true;
  }

  static String? validateName(String name) {
    if (name.trim().isEmpty || name.split(' ').length < 2) {
      return 'Full name is required';
    }
    return null;
  }

  static String? validatePassword(String password) {
    if (password.trim().isEmpty || password.trim().length < 10) {
      return 'Password length should be greater than 9 characters';
    }

    if (!password.trim().contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain letters';
    }

    if (!password.trim().contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain special characters';
    }
    return null;
  }

  static String? validatePasswordFields(String? password1, String? password2) {
    if (password1 != password2) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhoneNumber(String? phone) {
    if (phone == null || phone.trim().isEmpty) {
      return 'Phone number is required';
    }

    final normalized = getCleanPhoneNumber(phone);

    // Local Ghana number: 0 + 9 digits
    if (!RegExp(r'^0\d{9}$').hasMatch(normalized)) {
      return 'Invalid phone number';
    }
    return null; // valid
  }

  static String getCleanPhoneNumber(String phone) {
    // Accept formats like: 0XXXXXXXXX, +233XXXXXXXXX, 233XXXXXXXXX, with spaces/dashes
    String digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('233')) {
      final rest = digits.substring(3);
      if (rest.length >= 9) {
        digits =
            '0${rest.substring(0, 9)}'; 
      }
    }

    // If user omitted the leading 0 and only provided 9 digits, prepend it
    if (digits.length == 9) {
      digits = '0$digits';
    }

    // If still longer than 10 digits (e.g., copied with extra), try last 10 starting with 0
    if (digits.length > 10) {
      final last10 = digits.substring(digits.length - 10);
      if (RegExp(r'^0\d{9}$').hasMatch(last10)) {
        digits = last10;
      }
    }

    return digits;
  }
}
