import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class CylindricalTank2 extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final bool tiny;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;

  CylindricalTank2({
    super.key,
    required String label,
    required double liquidLevel,
    required this.tiny,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.breakpoint = 1.2,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  State<CylindricalTank2> createState() => _CylindricalTank2State();
}

class _CylindricalTank2State extends State<CylindricalTank2> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!widget.tiny)
          Text(
            widget.label,
            style: TextStyle(
                fontSize: widget.fontSize, fontWeight: widget.fontWeight),
          ),
        Expanded(
          child: CustomPaint(
              painter: FillableCylinder(
                  borderWidth: 2.0,
                  borderColor: widget.bottleColor,
                  fillColor: widget.liquidColor,
                  fillPercentage: widget.liquidLevel),
              child: Center(
                child: Text(
                  '${(widget.liquidLevel * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: widget.fontSize,
                    fontWeight: widget.fontWeight,
                  ),
                ),
              )),
        )
      ],
    );
  }
}

class FillableCylinder extends CustomPainter {
  final double borderWidth;
  final Color borderColor;
  final Color fillColor;
  double fillPercentage;

  FillableCylinder({
    required this.fillPercentage,
    required this.borderWidth,
    required this.borderColor,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = borderColor
      ..strokeWidth = borderWidth
      ..style = PaintingStyle.stroke;

    Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    Paint thirdRectPaint = Paint()..color = Colors.transparent;

    double startX = size.width / 4; // 1/4 of the width
    double endX = size.width * 3 / 4; // 3/4 of the width
    double lineY1 = size.height / 4; // 1/4 of the height
    double lineY2 = size.height * 3 / 4; // 3/4 of the height

    double ovalWidth = size.width / 2; // Half of the width
    double ovalHeight = size.height / 20; // 1/20 of the height

    double rectWidth = endX - startX - 10; // Width between the lines
    double rectHeight = size.height / 2.3; // Height of the rectangle

    if (fillPercentage > 1.0) {
      fillPercentage = 1.0;
    } else if (fillPercentage < 0.0) {
      fillPercentage = 0.0;
    }

    // Draw the first line
    canvas.drawLine(Offset(startX, lineY1), Offset(startX, lineY2), paint);

    // Draw the second vertical line
    canvas.drawLine(Offset(endX, lineY1), Offset(endX, lineY2), paint);

    // Draw the first oval
    final oval1 = Rect.fromLTWH((endX - (ovalWidth / 2)) / 2,
        lineY1 - (ovalHeight / 2), ovalWidth, ovalHeight);
    canvas.drawOval(oval1, paint);

    // Draw the second oval
    final oval2 = Rect.fromLTWH((endX - (ovalWidth / 2)) / 2,
        lineY2 - (ovalHeight / 2), ovalWidth, ovalHeight);
    canvas.drawOval(oval2, paint);

    final rect = Rect.fromLTWH(startX + 5,
        (lineY1 + (lineY2 - lineY1 - rectHeight) / 2), rectWidth, rectHeight);
    canvas.drawRect(rect, thirdRectPaint);

    // Draw the third rectangle filled with a certain percentage
    double filledHeight = rectHeight * fillPercentage;
    Rect filledRect3 = Rect.fromLTRB(
        rect.left, rect.bottom - filledHeight, rect.right, rect.bottom);
    canvas.drawRect(filledRect3, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
