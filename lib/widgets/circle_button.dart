import 'package:flutter/material.dart';

/// A circular button. The content (child) and the action (onPressed)
/// are both supplied by whoever uses it.
class CircleButton extends StatelessWidget {
  /// Anything: Icon, Text, Image, Column, etc.
  final Widget child;

  /// What happens on tap. Null makes the button look and act disabled.
  final VoidCallback? onPressed;

  /// Diameter of the circle.
  final double size;

  /// Background color of the circle.
  final Color? color;

  /// Shadow depth. 0 means flat.
  final double elevation;

  const CircleButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.size = 64,
    this.color,
    this.elevation = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color ?? Theme.of(context).colorScheme.primary,
        elevation: elevation,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias, // keeps the ripple inside the circle
        child: InkWell(
          onTap: onPressed,
          child: Center(child: child),
        ),
      ),
    );
  }
}