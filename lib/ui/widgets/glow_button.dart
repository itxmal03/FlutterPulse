import 'package:flutter/material.dart';

class GlowButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color? bgColor;
  final VoidCallback? onPressed;

  const GlowButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.bgColor,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: bgColor ?? color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: color.withOpacity(0.4)),
              borderRadius: BorderRadius.circular(8),
              boxShadow: isDisabled
                  ? null
                  : [
                      BoxShadow(
                        color: color.withOpacity(0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

