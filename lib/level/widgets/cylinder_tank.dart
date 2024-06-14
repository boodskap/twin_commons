import 'package:flutter/material.dart';

class CylinderTank extends StatelessWidget {
  final String label;
  final double height;
  final double width;
  final double liquidLevel;
  final Color liquidColor;
  final Color bottleColor;
  final bool shouldAnimate;
  final double fontSize;
  final Color fontColor;
  final FontWeight fontWeight;
  const CylinderTank(
      {super.key,
      this.height = 150,
      this.width = 150,
      required this.liquidLevel,
      this.liquidColor = Colors.lightBlueAccent,
      this.bottleColor = Colors.black,
      this.shouldAnimate = false,
      this.fontSize = 12,
      this.fontColor = Colors.black,
      required this.label,
      this.fontWeight = FontWeight.bold});

  @override
  Widget build(BuildContext context) {
    var top = EyeShapeContainer.opened;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyle(
              color: fontColor, fontSize: fontSize, fontWeight: fontWeight),
        ),
        const SizedBox(
          height: 8,
        ),
        SizedBox(
          height: height,
          width: width,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                  bottom: height - (top + top / 2),
                  child: EyeShapeContainer(
                    width: width,
                    topColor: bottleColor,
                  )),
              TankBody(
                color: bottleColor,
                height: height - top,
                width: width,
              ),
              liquidLevel >= 15
                  ? Stack(children: [
                      TankLiq(
                        liquidColor: liquidColor,
                        width: width,
                        liquidLevel: (liqlvl() / 100) * (height - top),
                        lq: liquidLevel,
                      ),
                      Positioned(
                          top: 5,
                          child: EyeShapeContainer(
                            width: width,
                            fillColor: Colors.lightBlue.shade100,
                          ))
                    ])
                  : Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      height: liquidLevel >= 10
                          ? 5
                          : liquidLevel <= 0
                              ? 0
                              : 3,
                      color: Colors.lightBlue.shade100,
                      width: width / 2,
                    ),
              Positioned(
                bottom: height / 2 - top,
                child: Text(
                  '${liqlvl()}%',
                  style: TextStyle(color: fontColor, fontSize: fontSize),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  double liqlvl() {
    double lq = liquidLevel >= 100
        ? 100
        : liquidLevel <= 0
            ? 0
            : liquidLevel;
    return lq;
  }
}

//=============================================
// Top Open

class EyeShapeContainer extends StatelessWidget {
  static double opened = 12;
  final double width;
  final Color topColor;
  final Color fillColor;
  const EyeShapeContainer(
      {super.key,
      required this.width,
      this.topColor = Colors.transparent,
      this.fillColor = Colors.transparent});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: EyeShapeBorderPainter(topColor, fillColor),
      child: ClipPath(
        clipper: EyeShapeClipper(),
        child: SizedBox(
          height: opened,
          width: width,
        ),
      ),
    );
  }
}

class EyeShapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

class EyeShapeBorderPainter extends CustomPainter {
  final Color topColor;
  final Color fillColor;
  EyeShapeBorderPainter(this.topColor, this.fillColor);
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = topColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    var fillPaint = Paint()
      ..color = fillColor // Choose the color for filling the shape
      ..style = PaintingStyle.fill;

    var path = Path();
    path.addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, paint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

//========================================
// Liquid widget

class TankLiq extends StatelessWidget {
  final double width;
  final double liquidLevel;
  final double lq;
  final Color liquidColor;

  const TankLiq({
    super.key,
    required this.width,
    required this.liquidLevel,
    required this.liquidColor,
    required this.lq,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: liquidLevel <= 10 ? 3 : 0),
      width: width,
      height: liquidLevel,
      child: CustomPaint(
        painter: CurvedBorderPainter(liquidLevel, lq, liquidColor),
      ),
    );
  }
}

class CurvedBorderPainter extends CustomPainter {
  final double liqlvl;
  final double lq;
  final Color liquidColor;

  CurvedBorderPainter(this.liqlvl, this.lq, this.liquidColor);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = liquidColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 10)
      ..quadraticBezierTo(size.width / 2, 0, size.width, 10)
      ..lineTo(size.width, size.height - 10)
      ..quadraticBezierTo(size.width / 2, size.height, 0, size.height - 10)
      ..close();
    if (lq >= 13) {
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

//========================================
// Tank Body widget

class TankBody extends StatelessWidget {
  final double height;
  final double width;
  final Color color;

  const TankBody(
      {super.key,
      required this.height,
      required this.width,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: CurvedBorderPainters(color),
      ),
    );
  }
}

class CurvedBorderPainters extends CustomPainter {
  final Color color;

  CurvedBorderPainters(this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    final path = Path()
      ..lineTo(0, size.height - 10)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 10)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0);

    canvas.drawPath(path, paint);

    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final borderPath = Path()
      ..moveTo(0, size.height - 10)
      ..quadraticBezierTo(
          size.width / 2, size.height, size.width, size.height - 10)
      ..lineTo(size.width, size.height - 10)
      ..lineTo(size.width, 0)
      ..moveTo(0, 0)
      ..lineTo(0, size.height - 10);

    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    throw UnimplementedError();
  }
}