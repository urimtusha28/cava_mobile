abstract final class ProfileFormValidator {
  static String? validateFirstName(String value) {
    if (value.trim().isEmpty) {
      return 'Emri është i detyrueshëm.';
    }
    return null;
  }

  static String? validatePhone(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final digits = trimmed.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8 || digits.length > 15) {
      return 'Numri i telefonit nuk është i vlefshëm.';
    }

    if (!RegExp(r'^[\d\s+\-()]+$').hasMatch(trimmed)) {
      return 'Numri i telefonit nuk është i vlefshëm.';
    }

    return null;
  }
}
