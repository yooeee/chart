import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../indicators/indicator_calculations.dart';
import '../models/market_data.dart';

enum IndicatorKind {
  trendRibbon,
  rsiPulse,
  macdMomentum,
  bollingerSqueeze,
  volumePressure,
  smartFlow,
}

extension IndicatorKindDetails on IndicatorKind {
  String get label {
    switch (this) {
      case IndicatorKind.trendRibbon:
        return 'Adaptive Trend Ribbon';
      case IndicatorKind.rsiPulse:
        return 'RSI Pulse';
      case IndicatorKind.macdMomentum:
        return 'MACD Momentum';
      case IndicatorKind.bollingerSqueeze:
        return 'Bollinger Squeeze';
      case IndicatorKind.volumePressure:
        return 'Volume Pressure';
      case IndicatorKind.smartFlow:
        return 'Smart Flow';
    }
  }

  String get shortLabel {
    switch (this) {
      case IndicatorKind.trendRibbon:
        return 'TREND';
      case IndicatorKind.rsiPulse:
        return 'RSI';
      case IndicatorKind.macdMomentum:
        return 'MACD';
      case IndicatorKind.bollingerSqueeze:
        return 'BOLL';
      case IndicatorKind.volumePressure:
        return 'V-PRESS';
      case IndicatorKind.smartFlow:
        return 'FLOW';
    }
  }

  String get summary {
    switch (this) {
      case IndicatorKind.trendRibbon:
        return 'EMA 21/55의 방향과 변동성을 한 줄로 읽습니다.';
      case IndicatorKind.rsiPulse:
        return '14기간 RSI와 5기간 신호선의 속도를 봅니다.';
      case IndicatorKind.macdMomentum:
        return '추세 방향과 모멘텀 변화를 히스토그램으로 표시합니다.';
      case IndicatorKind.bollingerSqueeze:
        return '밴드 폭의 수축·확장을 통해 변동성 국면을 추적합니다.';
      case IndicatorKind.volumePressure:
        return '가격 움직임에 실린 거래량의 매수·매도 압력을 계산합니다.';
      case IndicatorKind.smartFlow:
        return '거래량 방향성과 현재 거래량 이탈을 함께 읽습니다.';
    }
  }

  bool get isOverlay =>
      this == IndicatorKind.trendRibbon || this == IndicatorKind.bollingerSqueeze;
}

class MarketChart extends StatefulWidget {
  const MarketChart({
    super.key,
    required this.bars,
    required this.activeIndicators,
  });

  final List<MarketBar> bars;
  final Set<IndicatorKind> activeIndicators;

  @override
  State<MarketChart> createState() => _MarketChartState();
}

class _MarketChartState extends State<MarketChart> {
  double _zoom = 1;
  double _zoomAtGestureStart = 1;
  int? _hoverIndex;

  int? _indexAt(Offset position, double width) {
    const leftAxis = 52.0;
    const rightAxis = 14.0;
    final chartWidth = width - leftAxis - rightAxis;
    if (chartWidth <= 0 || position.dx < leftAxis || position.dx > width - rightAxis) {
      return null;
    }
    final visibleCount = math.max(32, (widget.bars.length / _zoom).round()).toInt();
    final start = math.max(0, widget.bars.length - visibleCount).toInt();
    final ratio = ((position.dx - leftAxis) / chartWidth).clamp(0.0, 1.0);
    return (start + ratio * (visibleCount - 1)).round().clamp(0, widget.bars.length - 1).toInt();
  }

  void _updateHover(Offset position, double width) {
    final index = _indexAt(position, width);
    if (index != _hoverIndex) setState(() => _hoverIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Listener(
          onPointerHover: (event) => _updateHover(event.localPosition, constraints.maxWidth),
          onPointerMove: (event) => _updateHover(event.localPosition, constraints.maxWidth),
          onPointerExit: (_) => setState(() => _hoverIndex = null),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: (_) => _zoomAtGestureStart = _zoom,
            onScaleUpdate: (details) {
              final next = (_zoomAtGestureStart * details.scale).clamp(1.0, 4.5).toDouble();
              if (next != _zoom) setState(() => _zoom = next);
            },
            onDoubleTap: () => setState(() => _zoom = 1),
            child: CustomPaint(
              painter: _MarketChartPainter(
                bars: widget.bars,
                activeIndicators: widget.activeIndicators,
                zoom: _zoom,
                hoverIndex: _hoverIndex,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  _MarketChartPainter({
    required this.bars,
    required this.activeIndicators,
    required this.zoom,
    required this.hoverIndex,
  });

  final List<MarketBar> bars;
  final Set<IndicatorKind> activeIndicators;
  final double zoom;
  final int? hoverIndex;

  static const ink = Color(0xff17191d);
  static const body = Color(0xff737881);
  static const muted = Color(0xff919191);
  static const grid = Color(0xffedf0f2);
  static const green = Color(0xff00de5a);
  static const red = Color(0xffe35d6a);
  static const violet = Color(0xff7457d6);
  static const blue = Color(0xff4285f4);

  late int _start;
  late int _visibleCount;
  late double _chartLeft;
  late double _chartWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty || size.width <= 10 || size.height <= 10) return;

    _visibleCount = math.min(bars.length, math.max(32, (bars.length / zoom).round())).toInt();
    _start = math.max(0, bars.length - _visibleCount).toInt();
    _chartLeft = 52;
    _chartWidth = math.max(1.0, size.width - _chartLeft - 14).toDouble();

    final panels = IndicatorKind.values
        .where((kind) => activeIndicators.contains(kind) && !kind.isOverlay)
        .toList(growable: false);
    const top = 22.0;
    final bottomPadding = 24.0;
    final available = math.max(180.0, size.height - top - bottomPadding).toDouble();
    final panelHeight = panels.isEmpty ? 0.0 : math.min(96.0, available * 0.13).toDouble();
    final priceHeight = math.max(
      170.0,
      available - panelHeight * panels.length - (panels.isEmpty ? 0 : 8),
    ).toDouble();
    final priceRect = Rect.fromLTWH(_chartLeft, top, _chartWidth, priceHeight);

    final closes = bars.map((bar) => bar.close).toList(growable: false);
    final trendFast = IndicatorCalculator.ema(closes, 21);
    final trendSlow = IndicatorCalculator.ema(closes, 55);
    final bollinger = IndicatorCalculator.bollinger(closes, 20, 2);

    _drawPriceChart(canvas, priceRect, closes, trendFast, trendSlow, bollinger);

    for (var index = 0; index < panels.length; index++) {
      final panelTop = priceRect.bottom + 8 + panelHeight * index;
      final rect = Rect.fromLTWH(_chartLeft, panelTop, _chartWidth, panelHeight - 4);
      _drawIndicatorPanel(canvas, rect, panels[index], closes);
    }
  }

  void _drawPriceChart(
    Canvas canvas,
    Rect rect,
    List<double> closes,
    List<double?> trendFast,
    List<double?> trendSlow,
    BollingerData bollinger,
  ) {
    final visibleBars = bars.sublist(_start);
    var minPrice = visibleBars.map((bar) => bar.low).reduce((a, b) => math.min(a, b).toDouble());
    var maxPrice = visibleBars.map((bar) => bar.high).reduce((a, b) => math.max(a, b).toDouble());
    final padding = (maxPrice - minPrice) * 0.08;
    minPrice -= padding;
    maxPrice += padding;
    if (maxPrice <= minPrice) maxPrice = minPrice + 1;

    final volumeHeight = math.min(42.0, rect.height * 0.16).toDouble();
    final plotTop = rect.top + 12;
    final plotBottom = rect.bottom - volumeHeight - 12;
    final candleWidth = math.max(2.0, math.min(11.0, _chartWidth / _visibleCount * 0.66)).toDouble();
    final y = (double value) =>
        plotBottom - (value - minPrice) / (maxPrice - minPrice) * (plotBottom - plotTop);

    _drawGrid(canvas, rect, minPrice, maxPrice, y);

    final maxVolume = visibleBars.map((bar) => bar.volume).reduce((a, b) => math.max(a, b).toDouble());
    for (var local = 0; local < visibleBars.length; local++) {
      final bar = visibleBars[local];
      final x = _xForLocal(local);
      final up = bar.close >= bar.open;
      final color = up ? green : red;
      final candlePaint = Paint()..color = color;
      canvas.drawLine(Offset(x, y(bar.high)), Offset(x, y(bar.low)), candlePaint..strokeWidth = 1);
      final bodyTop = y(math.max(bar.open, bar.close).toDouble());
      final bodyBottom = y(math.min(bar.open, bar.close).toDouble());
      final bodyRect = Rect.fromLTRB(
        x - candleWidth / 2,
        bodyTop,
        x + candleWidth / 2,
        math.max(bodyTop + 1.5, bodyBottom).toDouble(),
      );
      canvas.drawRect(bodyRect, candlePaint);

      final volumeTop = rect.bottom - 4 - (bar.volume / maxVolume) * volumeHeight;
      canvas.drawRect(
        Rect.fromLTRB(x - candleWidth / 2, volumeTop, x + candleWidth / 2, rect.bottom - 4),
        Paint()..color = color.withValues(alpha: 0.24),
      );
    }

    if (activeIndicators.contains(IndicatorKind.trendRibbon)) {
      _drawSeries(canvas, trendFast, y, green, width: 1.7);
      _drawSeries(canvas, trendSlow, y, violet, width: 1.35);
    }
    if (activeIndicators.contains(IndicatorKind.bollingerSqueeze)) {
      _drawSeries(canvas, bollinger.upper, y, blue.withValues(alpha: 0.72), width: 1);
      _drawSeries(canvas, bollinger.middle, y, muted, width: 1);
      _drawSeries(canvas, bollinger.lower, y, blue.withValues(alpha: 0.72), width: 1);
    }

    final last = bars.last;
    final lastY = y(last.close);
    final currentLine = Paint()
      ..color = green.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(_chartLeft, lastY), Offset(_chartLeft + _chartWidth, lastY), currentLine);
    _text(canvas, _formatValue(last.close), Offset(rect.right - 48, lastY - 15),
        size: 9, color: ink, weight: FontWeight.w700);
    _text(canvas, 'PRICE / VOLUME', Offset(rect.left, rect.top - 16), size: 10, color: body,
        weight: FontWeight.w700);
    _drawTimeLabels(canvas, rect);

    if (hoverIndex != null && hoverIndex! >= _start && hoverIndex! < bars.length) {
      final local = hoverIndex! - _start;
      final x = _xForLocal(local);
      final crosshair = Paint()
        ..color = ink.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), crosshair);
      final bar = bars[hoverIndex!];
      final tooltipText = '${_dateLabel(bar.time)}  ${_formatValue(bar.close)}';
      final tooltipWidth = 154.0;
      final tooltipX = (x + 8 + tooltipWidth > rect.right) ? x - tooltipWidth - 8 : x + 8;
      canvas.drawRect(
        Rect.fromLTWH(tooltipX, rect.top + 4, tooltipWidth, 22),
        Paint()..color = Colors.white,
      );
      canvas.drawRect(
        Rect.fromLTWH(tooltipX, rect.top + 4, tooltipWidth, 22),
        Paint()
          ..color = ink.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke,
      );
      _text(canvas, tooltipText, Offset(tooltipX + 8, rect.top + 9), size: 9, color: ink);
    }
  }

  void _drawIndicatorPanel(Canvas canvas, Rect rect, IndicatorKind kind, List<double> closes) {
    canvas.drawRect(rect, Paint()..color = const Color(0xfffafbfb));
    canvas.drawRect(
      rect,
      Paint()
        ..color = grid
        ..style = PaintingStyle.stroke,
    );
    _text(canvas, kind.shortLabel, Offset(rect.left + 6, rect.top + 4),
        size: 9, color: body, weight: FontWeight.w700);

    final first = switch (kind) {
      IndicatorKind.rsiPulse => IndicatorCalculator.rsi(closes, 14),
      IndicatorKind.macdMomentum => IndicatorCalculator.macd(closes).primary,
      IndicatorKind.volumePressure => IndicatorCalculator.volumePressure(bars),
      IndicatorKind.smartFlow => IndicatorCalculator.smartFlow(bars).primary,
      _ => const <double?>[],
    };
    final second = switch (kind) {
      IndicatorKind.rsiPulse => IndicatorCalculator.ema(
          IndicatorCalculator.rsi(closes, 14).map((value) => value ?? 50).toList(), 5),
      IndicatorKind.macdMomentum => IndicatorCalculator.macd(closes).secondary,
      IndicatorKind.smartFlow => IndicatorCalculator.smartFlow(bars).secondary,
      _ => const <double?>[],
    };
    final third = kind == IndicatorKind.macdMomentum
        ? IndicatorCalculator.macd(closes).tertiary
        : const <double?>[];

    var minValue = -1.0;
    var maxValue = 1.0;
    if (kind == IndicatorKind.rsiPulse) {
      minValue = 0;
      maxValue = 100;
    } else if (kind == IndicatorKind.volumePressure || kind == IndicatorKind.smartFlow) {
      minValue = -100;
      maxValue = 100;
    } else {
      final values = <double>[...
        first.whereType<double>(),
        second.whereType<double>(),
        third.whereType<double>(),
      ];
      if (values.isNotEmpty) {
        minValue = values.reduce((a, b) => math.min(a, b).toDouble());
        maxValue = values.reduce((a, b) => math.max(a, b).toDouble());
        final range = math.max(0.0001, maxValue - minValue).toDouble();
        minValue -= range * 0.16;
        maxValue += range * 0.16;
      }
    }
    if (maxValue <= minValue) maxValue = minValue + 1;
    final y = (double value) =>
        rect.bottom - 8 - (value - minValue) / (maxValue - minValue) * (rect.height - 25);

    if (kind == IndicatorKind.rsiPulse) {
      _drawReference(canvas, rect, y(70), violet.withValues(alpha: 0.4));
      _drawReference(canvas, rect, y(30), violet.withValues(alpha: 0.4));
    } else {
      _drawReference(canvas, rect, y(0), grid);
    }
    _drawSeries(canvas, first, y, kind == IndicatorKind.rsiPulse ? violet : green, width: 1.5);
    if (second.isNotEmpty) {
      _drawSeries(canvas, second, y, kind == IndicatorKind.smartFlow ? blue : ink, width: 1);
    }
    if (kind == IndicatorKind.macdMomentum) {
      _drawHistogram(canvas, third, y, rect, green, red);
    }
  }

  void _drawHistogram(
    Canvas canvas,
    List<double?> values,
    double Function(double) y,
    Rect rect,
    Color positive,
    Color negative,
  ) {
    final zero = y(0);
    for (var local = 0; local < _visibleCount; local++) {
      final value = values[_start + local];
      if (value == null) continue;
      final x = _xForLocal(local);
      final nextX = local + 1 < _visibleCount ? _xForLocal(local + 1) : x + 3;
      canvas.drawRect(
        Rect.fromLTRB(
          x - 2,
          math.min(zero, y(value)).toDouble(),
          nextX - 2,
          math.max(zero, y(value)).toDouble(),
        ),
        Paint()..color = (value >= 0 ? positive : negative).withValues(alpha: 0.32),
      );
    }
  }

  void _drawGrid(Canvas canvas, Rect rect, double minValue, double maxValue, double Function(double) y) {
    for (var row = 0; row <= 4; row++) {
      final value = minValue + (maxValue - minValue) * row / 4;
      final lineY = y(value);
      canvas.drawLine(
        Offset(rect.left, lineY),
        Offset(rect.right, lineY),
        Paint()..color = grid,
      );
      _text(canvas, _formatValue(value), Offset(2, lineY - 6), size: 9, color: muted);
    }
  }

  void _drawReference(Canvas canvas, Rect rect, double lineY, Color color) {
    canvas.drawLine(Offset(rect.left, lineY), Offset(rect.right, lineY), Paint()..color = color);
  }

  void _drawSeries(
    Canvas canvas,
    List<double?> values,
    double Function(double) y,
    Color color, {
    double width = 1,
  }) {
    if (values.isEmpty) return;
    Path? path;
    for (var local = 0; local < _visibleCount; local++) {
      final value = values[_start + local];
      if (value == null) {
        if (path != null) {
          canvas.drawPath(
            path,
            Paint()
              ..color = color
              ..strokeWidth = width
              ..style = PaintingStyle.stroke,
          );
        }
        path = null;
        continue;
      }
      final point = Offset(_xForLocal(local), y(value));
      if (path == null) {
        path = Path()..moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    if (path != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..style = PaintingStyle.stroke,
      );
    }
  }

  void _drawTimeLabels(Canvas canvas, Rect rect) {
    for (var mark = 0; mark < 4; mark++) {
      final local = ((_visibleCount - 1) * mark / 3).round();
      final x = _xForLocal(local);
      _text(canvas, _dateLabel(bars[_start + local].time), Offset(x - 22, rect.bottom + 4), size: 8, color: muted);
    }
  }

  double _xForLocal(int local) =>
      _chartLeft + (_visibleCount <= 1 ? 0 : local / (_visibleCount - 1) * _chartWidth);

  void _text(
    Canvas canvas,
    String value,
    Offset offset, {
    double size = 10,
    Color color = ink,
    FontWeight weight = FontWeight.w400,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: value,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: weight,
          fontFamily: 'Malgun Gothic',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  String _dateLabel(DateTime value) => '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

  String _formatValue(double value) => value.abs() >= 1000 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) =>
      oldDelegate.bars != bars ||
      oldDelegate.activeIndicators != activeIndicators ||
      oldDelegate.zoom != zoom ||
      oldDelegate.hoverIndex != hoverIndex;
}
