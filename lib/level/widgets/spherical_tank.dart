import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class SphericalTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;

  SphericalTank({
    super.key,
    required String label,
    required double liquidLevel,
    this.bottleColor = Colors.black,
    this.liquidColor = Colors.blue,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    this.breakpoint = 3,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  SphericalTankState createState() => SphericalTankState();
}

class SphericalTankState extends State<SphericalTank>
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
                  painter: CircleTankPainter(
                      waterLevel: liquidLevel,
                      bottleColor: widget.bottleColor,
                      capColor: Colors.transparent,
                      breakpoint: widget.breakpoint,
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

class CircleTankPainter extends WaterBottlePainter {
  // At which point should we cut off the neck of the bottle
  final double breakpoint;
  CircleTankPainter({
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
    required this.breakpoint,
    required Color liquidColor,
  }) : super(
            waterLevel: waterLevel,
            bottleColor: bottleColor,
            capColor: capColor,
            liquidColor: liquidColor);

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    if (size.height / size.width < breakpoint) {
      canvas.drawCircle(
          Offset(size.width / 2, size.height - r / 2), r / 2, paint);
      return;
    }
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingOuter = size.width * 0.28;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.moveTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    // canvas.drawPath(path, paint);
    canvas.drawArc(Rect.fromLTRB(0, size.height - r, size.width, size.height),
        math.pi * 1.59, math.pi * 1.82, true, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    canvas.drawCircle(
        Offset(size.width / 2, size.height - r / 2), r / 2 - 5, paint);
    if (size.height / size.width < breakpoint) {
      return;
    }
    final neckTop = size.width * 0.1;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(neckRingInner + 5, neckTop, neckRingInnerR - 5,
            size.height - r / 2),
        paint);
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < breakpoint) {
      return;
    }
    const capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.33 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(capL, capTop);
    path.lineTo(neckRingInner, capMid);
    path.lineTo(neckRingInner, capBottom);
    path.lineTo(neckRingInnerR, capBottom);
    path.lineTo(neckRingInnerR, capMid);
    path.lineTo(capR, capTop);
    path.close();
    canvas.drawPath(path, paint);
  }
}
