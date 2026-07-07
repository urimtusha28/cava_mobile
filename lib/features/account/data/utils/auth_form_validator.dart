/// Client-side validation for auth forms.
abstract final class AuthFormValidator {
  static final RegExp _emailPattern = RegExp(
    r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
  );

  static String? validateEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) {
      return 'Email është i detyrueshëm.';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Email nuk është valid.';
    }
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Fjalëkalimi është i detyrueshëm.';
    }
    if (value.length < 6) {
      return 'Fjalëkalimi duhet të ketë të paktën 6 karaktere.';
    }
    return null;
  }

  static String? validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Emri është i detyrueshëm.';
    }
    return null;
  }

  static String? validateConfirmPassword(String password, String confirm) {
    if (confirm.isEmpty) {
      return 'Konfirmo fjalëkalimin.';
    }
    if (password != confirm) {
      return 'Fjalëkalimet nuk përputhen.';
    }
    return null;
  }
}
