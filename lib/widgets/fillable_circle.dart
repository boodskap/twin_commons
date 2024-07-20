import 'package:flutter/material.dart';

class FillableCircle extends StatelessWidget {
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> data;
  const FillableCircle(
      {super.key, required this.attributes, required this.data});

  @override
  Widget build(BuildContext context) {
    double borderWidth = attributes['borderWidth'] ?? 4.0;
    Color borderColor = Color(attributes['borderColor'] ?? Colors.black.value);
    Color fillColor = Color(attributes['fillColor'] ?? Colors.blue.value);
    double fillPercentage = 0;
    String field = attributes['field'] ?? '';
    if (field.isNotEmpty) {
      fillPercentage = data[field] ?? 0.0;
    }
    if (fillPercentage < 0) fillPercentage = 0;
    if (fillPercentage > 100) fillPercentage = 100;

    return Stack(
      children: [
        CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _FillableCirclePainter(
              borderWidth: borderWidth,
              borderColor: borderColor,
              fillColor: fillColor,
              fillPercentage: fillPercentage),
        ),
        Center(
          child: Text(
            '$fillPercentage %',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
      ],
    );
  }
}

class _FillableCirclePainter extends CustomPainter {
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;
  final double fillPercentage;

  _FillableCirclePainter(
      {required this.borderWidth,
      required this.borderColor,
      required this.fillColor,
      required this.fillPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    Paint fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawCircle(
        Offset(size.width / 2, size.width / 2), size.width / 2, fill);

    var segment = size.width / 100.0;
    var end = size.width - (segment * fillPercentage);

    Paint cut = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, end), cut);

    Paint border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawCircle(
        Offset(size.width / 2, size.width / 2), size.width / 2, border);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
