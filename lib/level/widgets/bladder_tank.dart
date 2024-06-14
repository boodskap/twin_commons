import 'package:flutter/material.dart';
import 'dart:math';
class BladderTank extends StatefulWidget {
  final double height;
  final double width;
  final Color liquidColor;
  final Color bottleColor;
  final double liquidLevel;
  final bool shouldAnimate;
  final double fontSize;
  final Color fontColor;
  final String label;

  const BladderTank(
      {super.key,
      required this.liquidColor,
      required this.bottleColor,
      required this.liquidLevel,
      required this.shouldAnimate,
      required this.fontSize,
      required this.height,
      required this.width,
      required this.fontColor, required this.label});
  @override
  _BladderTankState createState() => _BladderTankState();
}

class _BladderTankState extends State<BladderTank>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  BoxDecoration dc() {
    var decoration = BoxDecoration(
      border: Border(
          top: BorderSide(color: widget.bottleColor),
          left: BorderSide(color: widget.bottleColor),
          right: BorderSide(color: widget.bottleColor)),
      color: Colors.white,
    );

    return decoration;
  }

  double liqlvl() {
    double lq = widget.liquidLevel >= 100
        ? 100
        : widget.liquidLevel <= 0
            ? 0
            : widget.liquidLevel;
    return lq;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
          Text(
          widget.label,
          style: TextStyle(
              color: widget.fontColor, fontSize: widget.fontSize),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(width: 5, height: 2, decoration: dc()),
        Container(
          width: 10,
          height: 5,
          decoration: dc().copyWith(
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10)),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.width,
              height: widget.height,
              decoration: BoxDecoration(
                border: Border.all(color: widget.bottleColor),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(45),
                  topRight: Radius.circular(45),
                ),
                color: Colors.white,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 2,
              right: 2,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  double shakeValue = 0.0;

                  if (widget.shouldAnimate && liqlvl() < 90 && liqlvl() > 0) {
                    shakeValue = sin(_controller.value * pi * 0.5) * 2;
                  }
                  return Container(
                    // width: widget.width,
                    height: (liqlvl() / 100) * widget.height + shakeValue,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(45),
                          topRight: Radius.circular(45)),
                      color: widget.liquidColor,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              child: Text(
                '${liqlvl()}%',
                style: TextStyle(
                    color: widget.fontColor, fontSize: widget.fontSize),
              ),
            )
          ],
        ),
        Container(
          width: widget.width,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10)),
            border: Border(
                bottom: BorderSide(color: widget.bottleColor),
                left: BorderSide(color: widget.bottleColor),
                right: BorderSide(color: widget.bottleColor)),
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}