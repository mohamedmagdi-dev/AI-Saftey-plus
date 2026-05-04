import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double borderWidth;
  final Color? borderColor;
  final Color? backgroundColor;
  final List<BoxShadow>? shadows;
  final bool useBackdropFilter;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.borderWidth = 1.21,
    this.borderColor,
    this.backgroundColor,
    this.shadows,
    this.useBackdropFilter = true,
  });

  @override
  Widget build(BuildContext context) {
    final container = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: ShapeDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: AppTheme.glassOpacity),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: borderWidth,
            color: borderColor ?? Colors.white.withValues(alpha: AppTheme.glassBorderOpacity),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        shadows: shadows ??
            [
              BoxShadow(
                color: const Color(0x5E000000),
                blurRadius: 32,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              )
            ],
      ),
      child: child,
    );

    if (useBackdropFilter) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: AppTheme.glassBlur, sigmaY: AppTheme.glassBlur),
          child: container,
        ),
      );
    }

    return container;
  }
}
