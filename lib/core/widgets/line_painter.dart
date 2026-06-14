import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<int>
  linePoints; // Contains 3 indices [0-8] representing the macro boards
  final double progress;
  final Color color;

  LinePainter({
    required this.linePoints,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress == 0) return;

    // Based on crossAxisSpacing and mainAxisSpacing set to 8
    const double spacing = 8.0;
    double cellWidth = (size.width - 2 * spacing) / 3;
    double cellHeight = (size.height - 2 * spacing) / 3;

    // Helper to find the exact pixel center of a specific macro grid (0-8)
    Offset getCenter(int index) {
      int row = index ~/ 3;
      int col = index % 3;
      double x = col * (cellWidth + spacing) + cellWidth / 2;
      double y = row * (cellHeight + spacing) + cellHeight / 2;
      return Offset(x, y);
    }

    Offset start = getCenter(linePoints.first);
    Offset end = getCenter(linePoints.last);

    // Extend the line slightly past the center of the edge cells for a better look
    Offset direction = (end - start);
    direction = direction / direction.distance;
    start = start - direction * (cellWidth * 0.3);
    end = end + direction * (cellWidth * 0.3);

    Offset currentEnd = Offset.lerp(start, end, progress)!;

    Paint paint = Paint()
      ..color = color.withAlpha(230)
      ..strokeWidth = 16.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.solid,
        4.0,
      ); // Add a slight glow

    canvas.drawLine(start, currentEnd, paint);
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
