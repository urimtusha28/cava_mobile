class StoreContact {
  const StoreContact({
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  static const fallback = StoreContact(
    email: 'info@cava-premium.com',
    phone: '+383 48 443 222',
  );
}
