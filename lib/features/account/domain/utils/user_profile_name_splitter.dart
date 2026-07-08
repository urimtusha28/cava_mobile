abstract final class UserProfileNameSplitter {
  /// Splits a full name into first + remaining last parts.
  static (String firstName, String lastName) split(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) {
      return ('', '');
    }

    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return (parts.first, '');
    }

    return (parts.first, parts.sublist(1).join(' '));
  }

  static String combine(String firstName, String lastName) {
    return '$firstName $lastName'.trim();
  }
}
