import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class TriangleTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;
  final bool tiny;

  TriangleTank({
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
  TriangleTankState createState() => TriangleTankState();
}

class TriangleTankState extends State<TriangleTank>
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
                  painter: FillableTriangle(
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

class FillableTriangle extends WaterBottlePainter {
  final double breakpoint;
  FillableTriangle({
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
    final Paint paint = Paint()
      ..color = bottleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final double halfWidth = size.width / 2;
    final double height = size.height;

    final Path path = Path();
    path.moveTo(0, height);
    path.lineTo(size.width, height);
    path.lineTo(halfWidth, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final double halfWidth = size.width / 2;
    final double height = size.height;

    final Path path = Path();
    path.moveTo(7, height - 5);
    path.lineTo(size.width - 7, height - 5);
    path.lineTo(halfWidth, 7);
    path.close();

    canvas.drawPath(path, paint);
  }
}
