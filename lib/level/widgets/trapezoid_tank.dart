import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class TrapezoidTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;
  final bool tiny;

  TrapezoidTank({
    super.key,
    required String label,
    required double liquidLevel,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.breakpoint = 1.2,
    required this.tiny,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  TrapezoidTankState createState() => TrapezoidTankState();
}

class TrapezoidTankState extends State<TrapezoidTank>
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
    if (percent > 100) {
      percent = 100;
    } else if (percent < 0) {
      percent = 0;
    }

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
                  painter: FillableTrapezoid(
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

class FillableTrapezoid extends WaterBottlePainter {
  final double breakpoint;
  FillableTrapezoid({
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
    Paint paint = Paint()
      ..color = bottleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    Path outerPath = Path();
    outerPath.moveTo(size.width * 0.2, 0); // Move to top left corner
    outerPath.lineTo(size.width * 0.8, 0); // Draw line to top right corner
    outerPath.lineTo(
        size.width, size.height); // Draw line to bottom right corner
    outerPath.lineTo(0, size.height); // Draw line to bottom left corner
    outerPath.close(); // Close the path to form a closed shape

    canvas.drawPath(outerPath, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path innerPath = Path();

    innerPath.moveTo(size.width * 0.23, 7); // Move to top left corner
    innerPath.lineTo(size.width * 0.77, 7); // Draw line to top right corner
    innerPath.lineTo(
        size.width - 7, size.height - 7); // Draw line to bottom right corner
    innerPath.lineTo(7, size.height - 7); // Draw line to bottom left corner

    innerPath.close(); // Close the path to form a closed shape

    canvas.drawPath(innerPath, paint);
  }
}
