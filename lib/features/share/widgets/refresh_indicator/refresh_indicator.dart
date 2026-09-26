import 'package:flutter/material.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onRefresh;
  final Color color;

  const CustomRefreshIndicator({
    super.key,
    required this.child,
    required this.onRefresh,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(color: color, onRefresh: onRefresh, child: child);
  }
}
