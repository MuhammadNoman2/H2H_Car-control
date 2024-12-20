import 'package:flutter/material.dart';
class CustomButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback onReleased;

  const CustomButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    required this.onReleased,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onPressed(),
      onTapUp: (_) => onReleased(),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Icon(icon, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}