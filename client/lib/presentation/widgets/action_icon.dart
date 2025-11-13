import 'package:flutter/material.dart';

class ActionIcon extends StatelessWidget {
  final IconData icon;
  final bool isGreyedOut;
  final VoidCallback onPressed;

  const ActionIcon({super.key, required this.icon, required this.isGreyedOut, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        IconButton(icon: Icon(icon), color: isGreyedOut ? Colors.grey : null, onPressed: onPressed),
        if (isGreyedOut)
          Positioned(top: 4, right: 4, child: Icon(Icons.info_outline, size: 16, color: Colors.blueAccent)),
      ],
    );
  }
}
