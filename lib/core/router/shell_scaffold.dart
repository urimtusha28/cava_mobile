import 'package:flutter/material.dart';

import '../state/bottom_nav_scroll_notifier.dart';
import '../widgets/bottom_navigation.dart';
import 'app_routes.dart';

/// Shell scaffold that listens for scroll and shrinks the bottom nav subtly.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  late String _lastLocation;

  @override
  void initState() {
    super.initState();
    _lastLocation = widget.location;
  }

  @override
  void didUpdateWidget(ShellScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.location != widget.location &&
        _lastLocation != widget.location) {
      _lastLocation = widget.location;
      BottomNavScrollNotifier.expand();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCart = widget.location == AppRoutes.cart;

    return Scaffold(
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(bottom: isCart ? 0 : 88),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification &&
                notification.depth == 0) {
              final delta = notification.scrollDelta;
              if (delta != null) {
                BottomNavScrollNotifier.reportScrollDelta(delta);
              }
            }
            return false;
          },
          child: widget.child,
        ),
      ),
      bottomNavigationBar: isCart
          ? null
          : BottomNavigation(
              currentIndex: bottomNavIndexForLocation(widget.location),
              onTap: (i) {
                BottomNavScrollNotifier.expand();
                navigateToBottomNavTab(context, i);
              },
            ),
    );
  }
}
