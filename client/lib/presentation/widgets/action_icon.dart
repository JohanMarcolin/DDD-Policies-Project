import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool isCrossedOut;
  final VoidCallback onPressed;

  const ActionIcon({
    super.key,
    required this.icon,
    required this.isCrossedOut,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        IconButton(
          icon: Icon(icon),
          color: isCrossedOut ? Colors.grey : null,
          onPressed: onPressed,
        ),
        if (isCrossedOut)
          IgnorePointer(
            child: CustomPaint(
              size: const Size(20, 20),
              painter: _CrossPainter(),
            ),
          ),
      ],
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(0, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
