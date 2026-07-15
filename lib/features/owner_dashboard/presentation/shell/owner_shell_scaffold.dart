import 'package:flutter/material.dart';

import 'owner_bottom_navigation.dart';

class OwnerShellScaffold extends StatelessWidget {
  const OwnerShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: const EdgeInsets.only(bottom: 96),
        child: child,
      ),
      bottomNavigationBar: OwnerBottomNavigation(
        currentIndex: ownerNavIndexForLocation(location),
      ),
    );
  }
}
