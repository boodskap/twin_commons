import 'package:flutter/material.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'dart:math' as math;
import '/level/liquid_container.dart';

class CorkedBottle extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final Color capColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;

  CorkedBottle({
    super.key,
    required String label,
    required double liquidLevel,
    this.liquidColor = Colors.blue,
    this.bottleColor = Colors.black,
    this.capColor = Colors.grey,
    this.shouldAnimate = false,
    this.fontSize = 12,
    this.fontWeight = FontWeight.bold,
  })  : liquidLevel = liquidLevel / 100,
        label = TwinUtils.getStrippedLabel(label);

  @override
  CorkedBottleState createState() => CorkedBottleState();
}

class CorkedBottleState extends State<CorkedBottle>
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
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          widget.label,
          style: TextStyle(
              fontSize: widget.fontSize, fontWeight: widget.fontWeight),
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
                  painter: WaterBottlePainter(
                    waterLevel: liquidLevel,
                    bottleColor: widget.bottleColor,
                    capColor: widget.capColor,
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

class WaterBottlePainter extends CustomPainter {
  /// Holds all wave object instances

  /// Water level, 0 = no water, 1 = full water
  final waterLevel;

  /// Bottle color
  final bottleColor;

  /// Bottle cap color
  final capColor;

  final liquidColor;

  WaterBottlePainter(
      {Listenable? repaint,
      required this.waterLevel,
      required this.bottleColor,
      required this.capColor,
      required this.liquidColor})
      : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    {
      final paint = Paint();
      paint.color = bottleColor;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 3;
      paintEmptyBottle(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.color = Colors.white;
      paint.style = PaintingStyle.fill;
      final rect = Rect.fromLTRB(0, 0, size.width, size.height);
      canvas.saveLayer(rect, paint);
      paintBottleMask(canvas, size, paint);
    }
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcIn;
      paint.style = PaintingStyle.fill;
      paintWaves(canvas, size, paint);
    }
    canvas.restore();
    {
      final paint = Paint();
      paint.blendMode = BlendMode.srcATop;
      paint.style = PaintingStyle.fill;
      paint.color = capColor;
      paintCap(canvas, size, paint);
    }
  }

  void paintEmptyBottle(Canvas canvas, Size size, Paint paint) {
    final neckTop = size.width * 0.1;
    final neckBottom = size.height;
    const neckRingOuter = 0.0;
    final neckRingOuterR = size.width - neckRingOuter;
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    final path = Path();
    path.moveTo(neckRingOuter, neckTop);
    path.lineTo(neckRingInner, neckTop);
    path.lineTo(neckRingInner, neckBottom);
    path.lineTo(neckRingInnerR, neckBottom);
    path.lineTo(neckRingInnerR, neckTop);
    path.lineTo(neckRingOuterR, neckTop);
    canvas.drawPath(path, paint);
  }

  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    final neckRingInner = size.width * 0.1;
    final neckRingInnerR = size.width - neckRingInner;
    canvas.drawRect(
        Rect.fromLTRB(
            neckRingInner + 5, 0, neckRingInnerR - 5, size.height - 5),
        paint);
  }

  void paintWaves(Canvas canvas, Size size, Paint paint) {
    paint.color = liquidColor;
    final desiredH = 0.1 * size.height;
    final waterRange = size.height +
        desiredH; // 0 = no water = size.height; 1 = full water = -size.width
    final translateY = (1.0 - waterLevel) * waterRange - desiredH;
    canvas.drawRect(
        Rect.fromLTRB(0, desiredH + translateY, size.width, size.height),
        paint);
  }

  void paintCap(Canvas canvas, Size size, Paint paint) {
    const capTop = 0.0;
    final capBottom = size.width * 0.2;
    final capMid = (capBottom - capTop) / 2;
    final capL = size.width * 0.08 + 5;
    final capR = size.width - capL;
    final neckRingInner = size.width * 0.1 + 5;
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

  @override
  bool shouldRepaint(WaterBottlePainter oldDelegate) => true;
}
