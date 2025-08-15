import 'package:flutter/material.dart';

class SimpleRoundedButton extends StatelessWidget {
  final String label;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback onTap;
  final bool fullWidth;

  final double? width;
  final double? height;
  final double iconSize;
  final double fontSize;
  final Color? backgroundColor;
  final Color? shadowColor;
  final Offset? shadowOffset;

  const SimpleRoundedButton({
    required this.label,
    required this.onTap,
    this.subtitle,
    this.icon,
    this.fullWidth = false,
    this.iconSize = 24,
    this.fontSize = 16,
    this.width,
    this.height,
    this.backgroundColor,
    this.shadowColor,
    this.shadowOffset,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: fullWidth ? double.infinity : width,
        height: height,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? Colors.black12,
              blurRadius: 8,
              offset: shadowOffset ?? Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show icon + label inline if icon is passed, else just label
            if (icon != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.deepPurple, size: iconSize),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
                  ),
                ],
              )
            else
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600),
              ),

            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
