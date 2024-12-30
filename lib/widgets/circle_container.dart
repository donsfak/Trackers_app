import 'package:flutter/material.dart';

class CircleContainer extends StatelessWidget {
  const CircleContainer({super.key, this.child, required this.color});
  final Color color;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // ignore: deprecated_member_use
        color: color,
        // ignore: deprecated_member_use
        border: Border.all(
          width: 2,
          color: color,
        ),
      ),
      child: Center(
        child: child,
      ),
    );
  }
}
