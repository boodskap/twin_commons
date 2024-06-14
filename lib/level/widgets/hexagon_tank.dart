import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class HexagonTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;
  final bool tiny;

  HexagonTank({
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
  HexagonTankState createState() => HexagonTankState();
}

class HexagonTankState extends State<HexagonTank>
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
          height: 14,
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: CustomPaint(
                  painter: FillableHexagon(
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

class FillableHexagon extends WaterBottlePainter {
  final double breakpoint;
  FillableHexagon({
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

    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = math.min(size.width / 1.53, size.height / 1.53);

    const double angleStep = 2 * math.pi / 6;
    var outerPath = Path();

    for (int i = 0; i < 6; i++) {
      double x = centerX + radius * math.cos(angleStep * i);
      double y = centerY + radius * math.sin(angleStep * i);
      if (i == 0) {
        outerPath.moveTo(x, y);
      } else {
        outerPath.lineTo(x, y);
      }
    }
    outerPath.close();
    canvas.drawPath(outerPath, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 1.0;

    double centerX1 = size.width / 1.995;
    double centerY1 = size.height / 1.995;
    double innerRadius = math.min(size.width / 1.45, size.height / 1.63);

    const double angleStep1 = 2 * math.pi / 6;
    var innerPath = Path();

    for (int i = 0; i < 6; i++) {
      double x = centerX1 + innerRadius * math.cos(angleStep1 * i);
      double y = centerY1 + innerRadius * math.sin(angleStep1 * i);
      if (i == 0) {
        innerPath.moveTo(x, y);
      } else {
        innerPath.lineTo(x, y);
      }
    }
    innerPath.close();
    canvas.drawPath(innerPath, paint);
  }
}
