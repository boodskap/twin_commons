import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import '/level/liquid_container.dart';
import '/level/widgets/corked_bottle.dart';

class ConicalTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final bool smoothCorner;
  final double breakpoint;
  final double fontSize;
  final FontWeight fontWeight;

  ConicalTank({
    super.key,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.shouldAnimate = false,
    this.smoothCorner = true,
    this.breakpoint = 1.2,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
    required String label,
    required double liquidLevel,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  ConicalTankState createState() => ConicalTankState();
}

class ConicalTankState extends State<ConicalTank>
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
                  painter: TriangularBottleStatePainter(
                      waterLevel: liquidLevel,
                      bottleColor: widget.bottleColor,
                      capColor: Colors.transparent,
                      smoothCorner: widget.smoothCorner,
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

class TriangularBottleStatePainter extends WaterBottlePainter {
  final bool smoothCorner;
  final double breakpoint;
  TriangularBottleStatePainter({
    Listenable? repaint,
    required double waterLevel,
    required Color bottleColor,
    required Color capColor,
    required Color liquidColor,
    required this.smoothCorner,
    required this.breakpoint,
  }) : super(
            repaint: repaint,
            waterLevel: waterLevel,
            bottleColor: bottleColor,
            capColor: capColor,
            liquidColor: liquidColor);

  @override
  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingOuter = size.width * 0.28;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.35;
    final neckRingInnerR = size.width - neckRingInner;
    final bodyBottom = size.height;
    const bodyL = 0.0;
    final bodyR = size.width;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    if (smoothCorner) {
      final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
      final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
      final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
      final bodyLBY = bodyBottom;
      final bodyRAX = size.width - bodyLAX;
      final bodyRAY = bodyLAY;
      final bodyRBX = size.width - bodyLBX;
      final bodyRBY = bodyLBY;
      path.lineTo(bodyLAX, bodyLAY);
      path.conicTo(bodyL, bodyBottom, bodyLBX, bodyLBY, 1);
      path.lineTo(bodyRBX, bodyRBY);
      path.conicTo(bodyR, bodyBottom, bodyRAX, bodyRAY, 1);
    } else {
      path.lineTo(bodyL, bodyBottom);
      path.lineTo(bodyR, bodyBottom);
    }
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, paint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final r = math.min(size.width, size.height);
    final neckTop = size.width * 0.1;
    final neckBottom = size.height - r + 3;
    final neckRingInner = size.width * 0.35 + 5;
    final neckRingInnerR = size.width - neckRingInner;
    final bodyBottom = size.height - 5;
    const bodyL = 5.0;
    final bodyR = size.width - 5;
    final path = Path();
    path.moveTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    if (smoothCorner) {
      final bodyLAX = (neckRingInner - bodyL) * 0.1 + bodyL;
      final bodyLAY = (bodyBottom - neckBottom) * 0.9 + neckBottom;
      final bodyLBX = (bodyR - bodyL) * 0.1 + bodyL;
      final bodyLBY = bodyBottom;
      final bodyRAX = size.width - bodyLAX;
      final bodyRAY = bodyLAY;
      final bodyRBX = size.width - bodyLBX;
      final bodyRBY = bodyLBY;
      path.lineTo(bodyLAX, bodyLAY);
      path.conicTo(bodyL, bodyBottom, bodyLBX, bodyLBY, 1);
      path.lineTo(bodyRBX, bodyRBY);
      path.conicTo(bodyR, bodyBottom, bodyRAX, bodyRAY, 1);
    } else {
      path.lineTo(bodyL, bodyBottom);
      path.lineTo(bodyR, bodyBottom);
    }
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paintCap(Canvas canvas, Size size, Paint paint) {
    if (size.height / size.width < breakpoint) {
      return;
    }
    const capTop = 0.5;
    final capBottom = size.width * 0.52;
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
