import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:twin_commons/level/liquid_container.dart';
import 'package:twin_commons/level/widgets/corked_bottle.dart';
import 'package:twin_commons/util/nocode_utils.dart';

class PrismTank extends StatefulWidget {
  final String label;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final FontWeight fontWeight;
  final double breakpoint;
  final bool tiny;

  PrismTank({
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
  PrismTankState createState() => PrismTankState();
}

class PrismTankState extends State<PrismTank>
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
                  painter: FillablePrism(
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

class FillablePrism extends WaterBottlePainter {
  final double breakpoint;
  FillablePrism({
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
    Paint outerPaint = Paint()
      ..color = bottleColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1; // Adjust the border width as needed

// Calculate the dimensions and positions of the rectangles based on the size of the SizedBox
    double rect1Width = size.width;
    double rect1Height = size.height;
    double rect2Width = size.width * 0.9;
    double rect2Height = size.height * 0.9;

    double rect1X = (size.width - rect1Width) / 4;
    double rect1Y = (size.height - rect1Height) / 4;
    double rect2X = (size.width - rect2Width) / 2;
    double rect2Y = (size.height - rect2Height) / 2;

// Define a path to encompass the outer boundaries of both rectangles and the connecting lines
    Path path = Path();

// Add the outer boundaries of the rectangles
    path.moveTo(rect1X, rect1Y);
    path.lineTo(rect1X + rect1Width, rect1Y);
    path.lineTo(rect1X + rect1Width, rect1Y + rect1Height);
    path.lineTo(rect1X, rect1Y + rect1Height);
    path.close();

    path.moveTo(rect2X, rect2Y);
    path.lineTo(rect2X + rect2Width, rect2Y);
    path.lineTo(rect2X + rect2Width, rect2Y + rect2Height);
    path.lineTo(rect2X, rect2Y + rect2Height);
    path.close();

// Add lines to connect the edges of the rectangles
    path.moveTo(rect1X, rect1Y);
    path.lineTo(rect2X, rect2Y);
    path.moveTo(rect1X + rect1Width, rect1Y);
    path.lineTo(rect2X + rect2Width, rect2Y);
    path.moveTo(rect1X, rect1Y + rect1Height);
    path.lineTo(rect2X, rect2Y + rect2Height);
    path.moveTo(rect1X + rect1Width, rect1Y + rect1Height);
    path.lineTo(rect2X + rect2Width, rect2Y + rect2Height);

// Draw the outer path
    canvas.drawPath(path, outerPaint);
  }

  @override
  void paintBottleMask(Canvas canvas, Size size, Paint paint) {
    Paint innerPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.fill;

// Calculate the dimensions and positions of the rectangles based on the size of the SizedBox
    double rect1Width = size.width;
    double rect1Height = size.height;
    double rect2Width = size.width;
    double rect2Height = size.height;

    double rect1X = (size.width - rect1Width) / 4;
    double rect1Y = (size.height - rect1Height) / 4;
    double rect2X = (size.width - rect2Width) / 2;
    double rect2Y = (size.height - rect2Height) / 2;

// Define a path for the inner area
    Path innerPath = Path();

// Calculate the dimensions and positions of the inner rectangles with a margin of 5 units
    double innerRect1X = rect1X + 5;
    double innerRect1Y = rect1Y + 5;
    double innerRect1Width = rect1Width - 10;
    double innerRect1Height = rect1Height - 10;

    double innerRect2X = rect2X + 5;
    double innerRect2Y = rect2Y + 5;
    double innerRect2Width = rect2Width - 10;
    double innerRect2Height = rect2Height - 10;

// Add the inner boundaries of the rectangles
    innerPath.moveTo(innerRect1X, innerRect1Y);
    innerPath.lineTo(innerRect1X + innerRect1Width, innerRect1Y);
    innerPath.lineTo(
        innerRect1X + innerRect1Width, innerRect1Y + innerRect1Height);
    innerPath.lineTo(innerRect1X, innerRect1Y + innerRect1Height);
    innerPath.close();

    innerPath.moveTo(innerRect2X, innerRect2Y);
    innerPath.lineTo(innerRect2X + innerRect2Width, innerRect2Y);
    innerPath.lineTo(
        innerRect2X + innerRect2Width, innerRect2Y + innerRect2Height);
    innerPath.lineTo(innerRect2X, innerRect2Y + innerRect2Height);
    innerPath.close();

// Draw the line connecting the two rects
    innerPath.moveTo(innerRect1X, innerRect1Y);
    innerPath.lineTo(innerRect2X, innerRect2Y);
    innerPath.moveTo(innerRect1X + innerRect1Width, innerRect1Y);
    innerPath.lineTo(innerRect2X + innerRect2Width, innerRect2Y);
    innerPath.moveTo(innerRect1X, innerRect1Y + innerRect1Height);
    innerPath.lineTo(innerRect2X, innerRect2Y + innerRect2Height);
    innerPath.moveTo(
        innerRect1X + innerRect1Width, innerRect1Y + innerRect1Height);
    innerPath.lineTo(
        innerRect2X + innerRect2Width, innerRect2Y + innerRect2Height);

// Draw the inner path
    canvas.drawPath(innerPath, innerPaint);
  }
}
