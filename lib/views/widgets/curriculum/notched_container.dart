import 'package:flutter/material.dart';

class NotchedContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Widget? topRightIcon;
  final Color? iconBackgroundColor;
  final double? width;
  final double? height;

  const NotchedContainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
    this.backgroundColor,
    this.topRightIcon,
    this.iconBackgroundColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipPath(
            clipper: ContainerClipper(),
            child: Container(
              width: width,
              height: height,
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: child,
            ),
          ),
          if (topRightIcon != null)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Container(
                  alignment: Alignment.center,
                  height: 54,
                  width: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: iconBackgroundColor,
                  ),
                  child: topRightIcon,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ContainerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final double width = size.width;
    final double height = size.height;

    final double cutSize = 70;
    final double radius = 20;

    final Path path = Path();

    // Top-left corner
    path.moveTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);

    // Line to start of outer notch corner
    path.lineTo(width - cutSize - radius, 0);

    // Outer top-right notch corner (curve into notch)
    path.quadraticBezierTo(width - cutSize, 0, width - cutSize, radius);

    // Inner notch corner (bottom left of notch)
    path.lineTo(width - cutSize, cutSize - radius);
    path.quadraticBezierTo(
      width - cutSize,
      cutSize,
      width - cutSize + radius,
      cutSize,
    );

    // Outer edge of notch — THIS was sharp, now curve it
    path.lineTo(width - radius, cutSize);
    path.quadraticBezierTo(width, cutSize, width, cutSize + radius);

    // Continue down
    path.lineTo(width, height);

    // Bottom-right corner
    path.quadraticBezierTo(width, height, width - radius, height);

    // Bottom edge to bottom-left
    path.lineTo(radius, height);
    path.quadraticBezierTo(0, height, 0, height - radius);

    // Back to top-left
    path.lineTo(0, radius);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
