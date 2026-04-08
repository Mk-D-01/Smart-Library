import 'package:flutter/material.dart';
import '../config/theme_config.dart';

class LoadingSkeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const LoadingSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            baseColor ?? AppTheme.background,
            highlightColor ?? AppTheme.cardBackground,
            baseColor ?? AppTheme.background,
          ],
          stops: const [0.0, 0.5, 1.0],
          begin: Alignment(-1.0, -0.3),
          end: Alignment(1.0, 0.3),
        ),
      ),
    );
  }
}

class SkeletonText extends StatelessWidget {
  final double width;
  final double? height;
  final TextStyle? style;

  const SkeletonText({
    super.key,
    required this.width,
    this.height,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = style ?? const TextStyle(fontSize: 14);
    final textHeight = height ?? textStyle.fontSize! * 1.2;

    return LoadingSkeleton(
      width: width,
      height: textHeight,
      borderRadius: BorderRadius.circular(4),
    );
  }
}

class SkeletonContainer extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final Widget? placeholder;

  const SkeletonContainer({
    super.key,
    required this.child,
    required this.isLoading,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return placeholder ?? _buildDefaultPlaceholder();
    }
    return child;
  }

  Widget _buildDefaultPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoadingSkeleton(
          width: double.infinity,
          height: 120,
          borderRadius: BorderRadius.circular(12),
        ),
        const SizedBox(height: 12),
        SkeletonText(width: 150, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SkeletonText(width: double.infinity, style: const TextStyle(fontSize: 14)),
        const SizedBox(height: 4),
        SkeletonText(width: 200, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
