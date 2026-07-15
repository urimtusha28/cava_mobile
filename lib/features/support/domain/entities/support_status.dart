enum SupportStatus {
  open,
  pending,
  resolved,
  closed;

  static SupportStatus fromString(String? raw) {
    return switch ((raw ?? '').trim().toLowerCase()) {
      'open' => SupportStatus.open,
      'pending' => SupportStatus.pending,
      'resolved' => SupportStatus.resolved,
      'closed' => SupportStatus.closed,
      _ => SupportStatus.open,
    };
  }

  String get firestoreValue => name;

  String get labelSq => switch (this) {
        SupportStatus.open => 'Hapur',
        SupportStatus.pending => 'Në pritje',
        SupportStatus.resolved => 'Zgjidhur',
        SupportStatus.closed => 'Mbyllur',
      };
}
