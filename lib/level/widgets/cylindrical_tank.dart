import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import '/level/liquid_container.dart';
import '/level/widgets/corked_bottle.dart';

class CylindricalTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;

  CylindricalTank({
    super.key,
    required String label,
    required double liquidLevel,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.breakpoint = 1.2,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  CylindricalTankState createState() => CylindricalTankState();
}

class CylindricalTankState extends State<CylindricalTank>
    with TickerProviderStateMixin, LiquidContainer {
  @override
  void initState() {
    super.initState();
    liquidLevel = widget.liquidLevel;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int percent = (liquidLevel * 100).toInt();
    return Column(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Text(
            widget.label,
            style: TextStyle(
                fontSize: widget.fontSize, fontWeight: widget.fontWeight),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: CustomPaint(
                  painter: CylinderBottleStatePainter(
                    waterLevel: widget.liquidLevel,
                    bottleColor: widget.bottleColor,
                    capColor: Colors.transparent,
                    breakpoint: widget.breakpoint,
                    liquidColor: widget.liquidColor,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Text(
                  '$percent %',
                  style: TextStyle(
                      fontSize: widget.fontSize, fontWeight: widget.fontWeight),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CylinderBottleStatePainter extends WaterBottlePainter {
  final double breakpoint;
  CylinderBottleStatePainter({
    Listenable? repaint,
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
    required this.breakpoint,
    required Color liquidColor,
  }) : super(
          repaint: repaint,
          waterLevel: waterLevel,
          bottleColor: bottleColor,
          capColor: capColor,
          liquidColor: liquidColor,
        );

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final Paint borderPaint = Paint()
      ..color = bottleColor
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Paint outerFillPaint = Paint()..color = Colors.white;

    double startX = size.width / 4;
    double endX = size.width * 3 / 4;

    double lineY1 = size.height / 100;
    double lineY2 = size.height;
    double ovalWidth = size.width / 2;
    double ovalHeight = size.height / 20;
    drawOuterPath(
        canvas, startX, endX, lineY1, lineY2, outerFillPaint, borderPaint);

    Rect ovalRect1 =
        Rect.fromLTWH((endX - (ovalWidth / 2)) / 2, -2, ovalWidth, ovalHeight);
    canvas.drawOval(ovalRect1, borderPaint);
    Rect ovalRect2 = Rect.fromLTWH((endX - (ovalWidth / 2)) / 2,
        lineY2 - (ovalHeight / 2), ovalWidth, ovalHeight);
    canvas.drawOval(ovalRect2, borderPaint);
  }

  void drawOuterPath(Canvas canvas, double startX, double endX, double lineY1,
      double lineY2, Paint fillPaint, Paint borderPaint) {
    Path outerPath = Path();
    outerPath.moveTo(startX, lineY1);
    outerPath.lineTo(startX, lineY2);
    outerPath.lineTo(endX, lineY2);
    outerPath.lineTo(endX, lineY1);
    outerPath.close();
    canvas.drawPath(outerPath, fillPaint);
    canvas.drawPath(outerPath, borderPaint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final Paint innerFillPaint = Paint()..color = Colors.white;

    final neckRingInner = size.width / 4;
    final neckRingInnerR = size.width - neckRingInner;

    final double startX = neckRingInner + 3;
    const double startY = 0;
    final double endX = neckRingInnerR - 3;
    final double endY = size.height - 5;

    final Path outerPath = Path();
    outerPath.moveTo(startX, startY);
    outerPath.lineTo(startX, endY);
    outerPath.lineTo(endX, endY);
    outerPath.lineTo(endX, startY);
    outerPath.close();

    // Fixed width and height for the mask
    final double maskWidth = size.width / 2; // Set your desired width
    final double maskHeight = size.height; // Set your desired height

    // Calculate start and end coordinates for the rectangle
    final double adjustedStartX = startX + (endX - startX - maskWidth) / 2;
    final double adjustedStartY = startY + (endY - startY - maskHeight) / 2;
    final double adjustedEndX = adjustedStartX + maskWidth;
    final double adjustedEndY = adjustedStartY + maskHeight;

    canvas.drawRect(
      Rect.fromLTRB(
        adjustedStartX + 2,
        5,
        adjustedEndX - 2,
        adjustedEndY + 1.5,
      ),
      innerFillPaint,
    );
  }
}
