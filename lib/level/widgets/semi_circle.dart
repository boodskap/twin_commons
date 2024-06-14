import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class SemiCircleTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;
  final bool tiny;

  SemiCircleTank({
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
  SemiCircleTankState createState() => SemiCircleTankState();
}

class SemiCircleTankState extends State<SemiCircleTank>
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
          height: 20,
        ),
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              AspectRatio(
                aspectRatio: 1 / 1,
                child: CustomPaint(
                  painter: FillableSemiCircle(
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

class FillableSemiCircle extends WaterBottlePainter {
  final double breakpoint;
  FillableSemiCircle({
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
    Paint tankPaint = Paint()
      ..color = bottleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    double tankWidth = size.width;
    double tankHeight = size.height;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(
            (size.width - tankWidth) / 2, 2, tankWidth, tankHeight - 4),
        topLeft: Radius.circular(tankWidth / 2),
        topRight: Radius.circular(tankWidth / 2),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ),
      tankPaint,
    );

    // canvas.drawRRect(
    //   RRect.fromRectAndCorners(
    //     Rect.fromCenter(
    //       center: Offset(size.width / 2, -8),
    //       width: size.width / 6,
    //       height: 20,
    //     ),
    //     bottomLeft: const Radius.circular(2),
    //     bottomRight: const Radius.circular(2),
    //     topLeft: const Radius.circular(10),
    //     topRight: const Radius.circular(10),
    //   ),
    //   tankPaint,
    // );
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    Paint tankPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double tankWidth = size.width;
    double tankHeight = size.height;

    canvas.drawRRect(
      RRect.fromRectAndCorners(
        Rect.fromLTWH(7, 10, tankWidth - 15, tankHeight - 20),
        topLeft: Radius.circular(tankWidth / 2),
        topRight: Radius.circular(tankWidth / 2),
        bottomLeft: Radius.zero,
        bottomRight: Radius.zero,
      ),
      tankPaint,
    );
  }
}
