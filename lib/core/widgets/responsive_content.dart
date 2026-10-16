import 'package:flutter/material.dart';

/// Keeps page typography predictable on narrow phones while still respecting
/// moderate accessibility scaling on larger screens.
class ResponsiveTextScope extends StatelessWidget {
  const ResponsiveTextScope({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final requestedScale = mediaQuery.textScaler.scale(1);
    final maxScale = mediaQuery.size.width < 360 ? 1.0 : 1.2;

    return MediaQuery(
      data: mediaQuery.copyWith(
        textScaler: TextScaler.linear(requestedScale.clamp(0.8, maxScale)),
      ),
      child: child,
    );
  }
}

class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = 720,
  });
  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: SizedBox(width: double.infinity, child: child),
    ),
  );
}
