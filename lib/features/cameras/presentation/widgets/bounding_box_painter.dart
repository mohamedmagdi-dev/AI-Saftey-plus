import 'package:flutter/material.dart';
import '../../domain/entities/bounding_box.dart';

class BoundingBoxPainter extends CustomPainter {
  final List<BoundingBox> boundingBoxes;
  final Size imageSize;

  BoundingBoxPainter({
    required this.boundingBoxes,
    required this.imageSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (final box in boundingBoxes) {
      final rect = Rect.fromLTWH(
        box.x * scaleX,
        box.y * scaleY,
        box.width * scaleX,
        box.height * scaleY,
      );

      // Draw bounding box
      final paint = Paint()
        ..color = _getColorForLabel(box.label)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawRect(rect, paint);

      // Draw label background
      final textSpan = TextSpan(
        text: '${box.label} ${(box.confidence * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      final labelRect = Rect.fromLTWH(
        rect.left,
        rect.top - textPainter.height - 4,
        textPainter.width + 8,
        textPainter.height + 4,
      );

      final labelPaint = Paint()
        ..color = _getColorForLabel(box.label).withValues(alpha: 0.8);

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect, const Radius.circular(4)),
        labelPaint,
      );

      textPainter.paint(
        canvas,
        Offset(rect.left + 4, rect.top - textPainter.height),
      );
    }
  }

  Color _getColorForLabel(String label) {
    switch (label.toLowerCase()) {
      case 'person':
        return Colors.blue;
      case 'vehicle':
        return Colors.green;
      case 'weapon':
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }

  @override
  bool shouldRepaint(BoundingBoxPainter oldDelegate) {
    return oldDelegate.boundingBoxes != boundingBoxes ||
        oldDelegate.imageSize != imageSize;
  }
}
