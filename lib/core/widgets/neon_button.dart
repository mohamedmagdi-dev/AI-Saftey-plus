import 'package:flutter/material.dart';

class NeonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? neonColor;
  final List<Color>? gradientColors;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;

  const NeonButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.neonColor,
    this.gradientColors,
    this.width,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final color = neonColor ?? const Color(0xFFF0B000);
    final colors = gradientColors ?? [color, color];
    final shadowColor = gradientColors != null 
        ? gradientColors!.first 
        : color;
    
    return Container(
      width: width,
      height: height ?? 56,
      padding: padding,
      decoration: ShapeDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: colors,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        shadows: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: 30,
            offset: Offset.zero,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(50),
          child: Container(
            alignment: Alignment.center,
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Arimo',
                      fontWeight: FontWeight.w400,
                      height: 1.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
