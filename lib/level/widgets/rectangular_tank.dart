import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class RectangularTank extends StatefulWidget {
  final Color liquidColor;
  final Color bottleColor;
  final String label;
  final double liquidLevel;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;

  RectangularTank({
    super.key,
    required String label,
    required double liquidLevel,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  RectangularTankState createState() => RectangularTankState();
}

class RectangularTankState extends State<RectangularTank>
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
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: CustomPaint(
                  painter: RectangleBottleStatePainter(
                      liquidLevel: liquidLevel,
                      bottleColor: widget.bottleColor,
                      capColor: Colors.transparent,
                      liquidColor: widget.liquidColor),
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

class RectangleBottleStatePainter extends WaterBottlePainter {
  // static const BREAK_POINT = 1.2;
  RectangleBottleStatePainter({
    Listenable? repaint,
    required double liquidLevel,
    required Color bottleColor,
    required Color capColor,
    required Color liquidColor,
  }) : super(
          repaint: repaint,
          waterLevel: liquidLevel,
          bottleColor: bottleColor,
          capColor: capColor,
          liquidColor: liquidColor,
        );

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final double outerWidth = size.width;
    final double outerHeight = size.height;

    final double outerLeft = (size.width - outerWidth) / 2;
    final double outerTop = (size.height - outerHeight) / 2;

    final outerRect =
        Rect.fromLTWH(outerLeft, outerTop, outerWidth, outerHeight);

    final outerPaint = Paint()
      ..color = bottleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawRect(outerRect, outerPaint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final double innerWidth = size.width * 0.96; // Adjust as needed
    final double innerHeight = size.height * 0.96; // Adjust as needed

    final double innerLeft = (size.width - innerWidth) / 2;
    final double innerTop = (size.height - innerHeight) / 2;

    final innerRect =
        Rect.fromLTWH(innerLeft, innerTop, innerWidth, innerHeight);

    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    canvas.drawRect(innerRect, innerPaint);
  }
}
