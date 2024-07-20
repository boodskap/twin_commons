import 'package:flutter/material.dart';

enum RectType {
  plain,
  waterTankBottomVoidSquare,
  waterTankBottomVoidArc,
  waterTank55Gallons
}

class FillableRectangle extends StatelessWidget {
  final Map<String, dynamic> attributes;
  final Map<String, dynamic> data;
  final RectType type;
  const FillableRectangle(
      {super.key,
      required this.attributes,
      required this.data,
      this.type = RectType.plain});

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
          painter: _FillableRectanglePainter(
              type: type,
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

class _FillableRectanglePainter extends CustomPainter {
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;
  final double fillPercentage;
  final RectType type;

  _FillableRectanglePainter(
      {required this.type,
      required this.borderWidth,
      required this.borderColor,
      required this.fillColor,
      required this.fillPercentage});

  @override
  void paint(Canvas canvas, Size size) {
    switch (type) {
      case RectType.plain:
        paintPlain(canvas, size);
        break;
      case RectType.waterTankBottomVoidSquare:
        paintBottomVoidSquare(canvas, size);
        break;
      case RectType.waterTankBottomVoidArc:
        paintBottomVoidArc(canvas, size);
        break;
      case RectType.waterTank55Gallons:
        // TODO: Handle this case.
        break;
    }
  }

  void paintPlain(Canvas canvas, Size size) {
    Paint fill = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    var segment = size.height / 100.0;
    var start = segment * fillPercentage;
    double y = size.height - start;

    canvas.drawRect(Rect.fromLTRB(0, y, size.width, size.height), fill);

    Paint border = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), border);
  }

  void paintBottomVoidArc(Canvas canvas, Size size) {
    Paint paintFill0 = Paint()
      ..color = const Color.fromARGB(255, 7, 7, 7)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.3554306, size.height * 0.7984054);
    path_0.lineTo(size.width * 0.6372571, size.height * 0.8013800);
    path_0.lineTo(size.width * 0.6411449, size.height * 0.9984054);
    path_0.quadraticBezierTo(size.width * 0.5041429, size.height * 0.6506800,
        size.width * 0.3554306, size.height * 0.9984054);
    path_0.quadraticBezierTo(size.width * 0.3554306, size.height * 0.9484054,
        size.width * 0.3554306, size.height * 0.7984054);
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Square

    Paint paintStroke0 = Paint()
      ..color = const Color.fromARGB(255, 33, 150, 243)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paintStroke0);

    // Layer 1

    Paint paintFill1 = Paint()
      ..color = const Color.fromARGB(0, 7, 7, 7)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(0, 0);
    path_1.lineTo(size.width * 1.0028571, size.height * 0.0020000);
    path_1.lineTo(size.width, size.height * 0.9980000);
    path_1.lineTo(size.width * 0.6457143, size.height * 0.9980000);
    path_1.lineTo(size.width * 0.6428571, size.height * 0.8020000);
    path_1.lineTo(size.width * 0.3542857, size.height * 0.8000000);
    path_1.lineTo(size.width * 0.3600000, size.height);
    path_1.lineTo(size.width * 0.0028571, size.height * 0.9980000);
    path_1.lineTo(0, 0);
    path_1.close();

    canvas.drawPath(path_1, paintFill1);

    // Layer 1

    Paint paintStroke1 = Paint()
      ..color = const Color.fromARGB(255, 5, 5, 5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_1, paintStroke1);

    // Layer 1

    Paint paintFill2 = Paint()
      ..color = const Color.fromARGB(0, 7, 7, 7)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_2 = Path();
    path_2.moveTo(size.width * 0.4285714, size.height * 0.0140000);
    path_2.lineTo(size.width * 0.5771429, size.height * 0.0160000);

    canvas.drawPath(path_2, paintFill2);

    // Layer 1

    Paint paintStroke2 = Paint()
      ..color = const Color.fromARGB(255, 5, 5, 5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_2, paintStroke2);
  }

  void paintBottomVoidSquare(Canvas canvas, Size size) {
    // Layer 1

    Paint paintFill0 = Paint()
      ..color = const Color.fromARGB(0, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_0 = Path();
    path_0.moveTo(size.width * 0.3714286, size.height * 0.8571429);
    path_0.lineTo(size.width * 0.6571429, size.height * 0.8571429);
    path_0.lineTo(size.width * 0.6571429, size.height);
    path_0.lineTo(size.width, size.height);
    path_0.lineTo(size.width, 0);
    path_0.lineTo(0, 0);
    path_0.lineTo(0, size.height);
    path_0.lineTo(size.width * 0.3714286, size.height);
    path_0.lineTo(size.width * 0.3714286, size.height * 0.8571429);
    path_0.close();

    canvas.drawPath(path_0, paintFill0);

    // Layer 1

    Paint paintStroke0 = Paint()
      ..color = const Color.fromARGB(255, 5, 5, 5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_0, paintStroke0);

    // Layer 1

    Paint paintFill1 = Paint()
      ..color = const Color.fromARGB(0, 255, 255, 255)
      ..style = PaintingStyle.fill
      ..strokeWidth = size.width * 0.00
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    Path path_1 = Path();
    path_1.moveTo(size.width * 0.4285714, size.height * 0.0285714);
    path_1.lineTo(size.width * 0.5714286, size.height * 0.0285714);

    canvas.drawPath(path_1, paintFill1);

    // Layer 1

    Paint paintStroke1 = Paint()
      ..color = const Color.fromARGB(255, 5, 5, 5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    canvas.drawPath(path_1, paintStroke1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
