class BoundingBox {
  final double x;
  final double y;
  final double width;
  final double height;
  final String label;
  final double confidence;

  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.label,
    required this.confidence,
  });
}
