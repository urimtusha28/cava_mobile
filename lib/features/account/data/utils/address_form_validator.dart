abstract final class AddressFormValidator {
  static String? validateFullName(String value) {
    if (value.trim().isEmpty) {
      return 'Emri është i detyrueshëm.';
    }
    return null;
  }

  static String? validatePhone(String value) {
    if (value.trim().isEmpty) {
      return 'Telefoni është i detyrueshëm.';
    }
    return null;
  }

  static String? validateStreet(String value) {
    if (value.trim().isEmpty) {
      return 'Rruga është e detyrueshme.';
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
}
