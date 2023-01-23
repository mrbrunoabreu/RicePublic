import 'dart:ui';
import 'package:flutter/material.dart';
import 'wave_slider.dart';

class WavePainter extends CustomPainter {
  final double? sliderPosition;
  final double dragPercentage;
  final SliderState sliderState;
  final double animationProgress;
  final Color color;

  WavePainter({
    required this.sliderPosition,
    required this.dragPercentage,
    required this.sliderState,
    required this.animationProgress,
    required this.color,
  }) : wavePainter = Paint()
          ..color = color
          ..style = PaintingStyle.fill;

  final Map<RangeValues, String> emojiMap = {
    RangeValues(0.0, 1.0): '😭',
    RangeValues(1.1, 2.0): '🙁',
    RangeValues(2.1, 3.0): '😐',
    RangeValues(3.1, 3.5): '🙂',
    RangeValues(3.6, 4.0): '😋',
    RangeValues(4.1, 4.9): '😍',
    RangeValues(5.0, 5.0): '❤',
  };
  final double bendWidth = 40;
  final double bezierWidth = 20;
  final double borderRadius = 5;
  final Paint wavePainter;

  //region Super ---------------------------------------------------------------
  @override
  void paint(Canvas canvas, Size size) {
    _paintAnchors(canvas, size);
    _paintBaseLine(canvas, size);

    switch (sliderState) {
      case SliderState.starting:
        _paintStartupWave(canvas, size);
        break;
      case SliderState.resting:
        _paintRestingWave(canvas, size);
        break;
      case SliderState.sliding:
        _paintSlidingWave(canvas, size);
        break;
      case SliderState.stopping:
        _paintStoppingWave(canvas, size);
        break;
      default:
        _paintSlidingWave(canvas, size);
        break;
    }
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) {
    return true;
  }
  //endregion

  //region Private -------------------------------------------------------------
  _paintAnchors(Canvas canvas, Size size) {
    canvas.drawCircle(Offset(borderRadius, size.height - borderRadius),
        borderRadius, wavePainter);
    canvas.drawCircle(
        Offset(size.width - borderRadius, size.height - borderRadius),
        borderRadius,
        wavePainter);
  }

  _paintRestingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);
    _paintCircle(canvas, size, line.centerPoint!, 5, 18);
    _paintContent(canvas, size, line.centerPoint! + 2, 20);
  }

  _paintStartupWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    double? waveHeight = lerpDouble(size.height, line.controlHeight,
        Curves.elasticOut.transform(animationProgress));
    double contentY =
        lerpDouble(17, 32, Curves.elasticOut.transform(animationProgress))!;

    line.controlHeight = waveHeight;
    _paintWaveLine(canvas, size, line, 10);
    _paintContent(canvas, size, line.centerPoint!, contentY);
  }

  _paintSlidingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions waveCurveDefinitions =
        _calculateWaveLineDefinitions(size);
    _paintWaveLine(canvas, size, waveCurveDefinitions, 10);
    _paintCircle(canvas, size, waveCurveDefinitions.centerPoint!, 18, 18);
    _paintContent(canvas, size, waveCurveDefinitions.centerPoint!, 34);
  }

  _paintStoppingWave(Canvas canvas, Size size) {
    WaveCurveDefinitions line = _calculateWaveLineDefinitions(size);

    double? waveHeight = lerpDouble(line.controlHeight, size.height,
        Curves.elasticOut.transform(animationProgress));

    double circleHeight =
        lerpDouble(18, 5, Curves.elasticOut.transform(animationProgress))!;

    double contentHeight =
        lerpDouble(32, 17, Curves.elasticOut.transform(animationProgress))!;

    line.controlHeight = waveHeight;

    _paintWaveLine(canvas, size, line, 10);
    _paintCircle(canvas, size, line.centerPoint!, circleHeight, 18);
    _paintContent(canvas, size, line.centerPoint!, contentHeight);
  }

  _paintCircle(Canvas canvas, Size size, double x, double y, double radius) {
    Path path = Path()
      ..addOval(
          Rect.fromCircle(center: Offset(x, size.height - y), radius: radius));
    canvas.drawPath(path, wavePainter);
  }

  _paintWaveLine(
      Canvas canvas, Size size, WaveCurveDefinitions waveCurve, double y) {
    Path path = Path();
    path.moveTo(waveCurve.startOfBezier, size.height - y);

    path.cubicTo(
        waveCurve.leftControlPoint1,
        size.height - y,
        waveCurve.leftControlPoint2,
        waveCurve.controlHeight!,
        waveCurve.centerPoint!,
        waveCurve.controlHeight!);

    path.cubicTo(
        waveCurve.rightControlPoint1,
        waveCurve.controlHeight!,
        waveCurve.rightControlPoint2,
        size.height - y,
        waveCurve.endOfBezier,
        size.height - y);
    path.close();

    canvas.drawPath(path, wavePainter);
  }

  _paintBaseLine(Canvas canvas, Size size) {
    Path path = Path();
    path.moveTo(borderRadius, size.height - 10);
    path.lineTo(size.width - borderRadius, size.height - 10);
    path.lineTo(size.width - borderRadius, size.height);
    path.lineTo(borderRadius, size.height);
    path.close();

    canvas.drawPath(path, wavePainter);
  }

  _paintContent(Canvas canvas, Size size, double x, double y) {
    double value =
        (sliderPosition! - (2 * borderRadius + bezierWidth + bendWidth) / 2) /
            (size.width - (2 * borderRadius + bezierWidth + bendWidth));
    if (value < 0)
      value = 0.0;
    else if (value > 1)
      value = 5.0;
    else
      value = (value * 50).round() / 10;

    final textSpan = TextSpan(
        text: emojiMap.entries
            .firstWhere((element) =>
                element.key.start <= value && element.key.end >= value)
            .value,
        style: TextStyle(fontSize: 20));

    final textPainter =
        TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    textPainter.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    final offset = Offset(x - 12.5, size.height - y);

    textPainter.paint(canvas, offset);
  }

  WaveCurveDefinitions _calculateWaveLineDefinitions(Size size) {
    double? centerPoint;
    if (sliderPosition! >=
        size.width - borderRadius - bendWidth / 2 - bezierWidth)
      centerPoint = size.width - borderRadius - bendWidth / 2 - bezierWidth;
    else if (sliderPosition! <= borderRadius + bendWidth / 2 + bezierWidth)
      centerPoint = borderRadius + bendWidth / 2 + bezierWidth;
    else
      centerPoint = sliderPosition;

    double startOfBend = centerPoint! - bendWidth / 2;
    double startOfBezier = centerPoint - bendWidth / 2 - bezierWidth;
    double endOfBend = centerPoint + bendWidth / 2;
    double endOfBezier = centerPoint + bendWidth / 2 + bezierWidth;

    double leftBendControlPoint1 = startOfBend;
    double leftBendControlPoint2 = startOfBend;
    double rightBendControlPoint1 = endOfBend;
    double rightBendControlPoint2 = endOfBend;

    WaveCurveDefinitions waveCurveDefinitions = WaveCurveDefinitions(
      controlHeight: size.height * .2,
      startOfBezier: startOfBezier,
      endOfBezier: endOfBezier,
      leftControlPoint1: leftBendControlPoint1,
      leftControlPoint2: leftBendControlPoint2,
      rightControlPoint1: rightBendControlPoint1,
      rightControlPoint2: rightBendControlPoint2,
      centerPoint: centerPoint,
    );
    return waveCurveDefinitions;
  }
  //endregion
}

class WaveCurveDefinitions {
  double startOfBezier;
  double endOfBezier;
  double leftControlPoint1;
  double leftControlPoint2;
  double rightControlPoint1;
  double rightControlPoint2;
  double? controlHeight;
  double? centerPoint;

  WaveCurveDefinitions({
    required this.startOfBezier,
    required this.endOfBezier,
    required this.leftControlPoint1,
    required this.leftControlPoint2,
    required this.rightControlPoint1,
    required this.rightControlPoint2,
    required this.controlHeight,
    required this.centerPoint,
  });
}
