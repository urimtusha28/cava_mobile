import 'package:flutter/material.dart';

import 'order_exchange/animated_order_exchange_illustration.dart';

class OrderReceivedIllustration extends StatefulWidget {
  const OrderReceivedIllustration({
    super.key,
    required this.isActive,
    required this.pageOffset,
  });

  final bool isActive;
  final double pageOffset;

  @override
  State<OrderReceivedIllustration> createState() =>
      _OrderReceivedIllustrationState();
}

class _OrderReceivedIllustrationState extends State<OrderReceivedIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    if (widget.isActive) _entranceController.forward();
  }

  @override
  void didUpdateWidget(covariant OrderReceivedIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _entranceController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Transform.translate(
          offset: Offset(widget.pageOffset * -10, 0),
          child: AnimatedOrderExchangeIllustration(
            isActive: widget.isActive,
          ),
        ),
      ),
    );
  }
}
