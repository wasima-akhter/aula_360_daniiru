import 'package:shimmer/shimmer.dart';

import '../../export/screen_export.dart';

class ShimmerWrapper extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const ShimmerWrapper({super.key, required this.child, required this.enabled});

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: child,
    );
  }
}
