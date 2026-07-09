import '../entities/guest_checkout_customer.dart';

/// Lightweight validation for guest checkout form fields.
abstract final class GuestCheckoutFormValidator {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static String? validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return 'Emri është i detyrueshëm.';
    }
    return null;
  }

  static String? validateLastName(String value) {
    if (value.trim().isEmpty) {
      return 'Mbiemri është i detyrueshëm.';
    }
    return null;
  }

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

  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return 'Telefoni është i detyrueshëm.';
    }
    return null;
  }

  static String? validateAddress(String value) {
    if (value.trim().isEmpty) {
      return 'Adresa është e detyrueshme.';
    }
    return null;
  }

  static String? validateCity(String value) {
    if (value.trim().isEmpty) {
      return 'Qyteti është i detyrueshëm.';
    }
    return null;
  }

  static String? validateCountry(String value) {
    if (value.trim().isEmpty) {
      return 'Shteti është i detyrueshëm.';
    }
    return null;
  }

  static String? validateCustomer(GuestCheckoutCustomer? customer) {
    if (customer == null || !customer.isComplete) {
      return 'Plotëso të dhënat për dorëzim.';
    }
    return null;
  }
}
