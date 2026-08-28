import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/market_bar.dart';
import '../../domain/enums/indicator_type.dart';
import '../../domain/services/technical_indicator_calculator.dart';

class MarketChart extends StatefulWidget {
  const MarketChart({
    super.key,
    required this.marketBars,
    required this.activeIndicatorTypes,
  });

  final List<MarketBar> marketBars;
  final Set<IndicatorType> activeIndicatorTypes;

  @override
  State<MarketChart> createState() => _MarketChartState();
}

class _MarketChartState extends State<MarketChart> {
  double _chartZoom = 1;
  double _chartZoomAtGestureStart = 1;
  int? _hoveredBarIndex;

  int? _getBarIndexAtPosition(Offset position, double width) {
    const leftAxis = 52.0;
    const rightAxis = 14.0;
    final chartWidth = width - leftAxis - rightAxis;
    if (chartWidth <= 0 || position.dx < leftAxis || position.dx > width - rightAxis) {
      return null;
    }
    final visibleCount = math.max(32, (widget.marketBars.length / _chartZoom).round()).toInt();
    final start = math.max(0, widget.marketBars.length - visibleCount).toInt();
    final ratio = ((position.dx - leftAxis) / chartWidth).clamp(0.0, 1.0);
    return (start + ratio * (visibleCount - 1)).round().clamp(0, widget.marketBars.length - 1).toInt();
  }

  void _updateHoveredBar(Offset position, double width) {
    final index = _getBarIndexAtPosition(position, width);
    if (index != _hoveredBarIndex) setState(() => _hoveredBarIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onExit: (_) => setState(() => _hoveredBarIndex = null),
          child: Listener(
            onPointerHover: (event) => _updateHoveredBar(event.localPosition, constraints.maxWidth),
            onPointerMove: (event) => _updateHoveredBar(event.localPosition, constraints.maxWidth),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onScaleStart: (_) => _chartZoomAtGestureStart = _chartZoom,
              onScaleUpdate: (details) {
                final next = (_chartZoomAtGestureStart * details.scale).clamp(1.0, 4.5).toDouble();
                if (next != _chartZoom) setState(() => _chartZoom = next);
              },
              onDoubleTap: () => setState(() => _chartZoom = 1),
              child: CustomPaint(
                painter: _MarketChartPainter(
                  marketBars: widget.marketBars,
                  activeIndicatorTypes: widget.activeIndicatorTypes,
                  chartZoom: _chartZoom,
                  hoveredBarIndex: _hoveredBarIndex,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MarketChartPainter extends CustomPainter {
  _MarketChartPainter({
    required this.marketBars,
    required this.activeIndicatorTypes,
    required this.chartZoom,
    required this.hoveredBarIndex,
  });

  final List<MarketBar> marketBars;
  final Set<IndicatorType> activeIndicatorTypes;
  final double chartZoom;
  final int? hoveredBarIndex;

  static const ink = Color(0xff17191d);
  static const body = Color(0xff737881);
  static const muted = Color(0xff919191);
  static const grid = Color(0xffedf0f2);
  static const green = Color(0xff00de5a);
  static const red = Color(0xffe35d6a);
  static const violet = Color(0xff7457d6);
  static const blue = Color(0xff4285f4);

  late int _firstVisibleBarIndex;
  late int _visibleBarCount;
  late double _plotLeft;
  late double _plotWidth;

  @override
  void paint(Canvas canvas, Size size) {
    if (marketBars.isEmpty || size.width <= 10 || size.height <= 10) return;

    _visibleBarCount = math.min(marketBars.length, math.max(32, (marketBars.length / chartZoom).round())).toInt();
    _firstVisibleBarIndex = math.max(0, marketBars.length - _visibleBarCount).toInt();
    _plotLeft = 52;
    _plotWidth = math.max(1.0, size.width - _plotLeft - 14).toDouble();

    final panels = IndicatorType.values
        .where((indicatorType) => activeIndicatorTypes.contains(indicatorType) && !indicatorType.isOverlay)
        .toList(growable: false);
    const top = 22.0;
    final bottomPadding = 24.0;
    final available = math.max(180.0, size.height - top - bottomPadding).toDouble();
    final panelHeight = panels.isEmpty ? 0.0 : math.min(96.0, available * 0.13).toDouble();
    final priceHeight = math.max(
      170.0,
      available - panelHeight * panels.length - (panels.isEmpty ? 0 : 8),
    ).toDouble();
    final priceRect = Rect.fromLTWH(_plotLeft, top, _plotWidth, priceHeight);

    final closingPrices = marketBars.map((bar) => bar.close).toList(growable: false);
    final fastTrendLine = TechnicalIndicatorCalculator.ema(closingPrices, 21);
    final slowTrendLine = TechnicalIndicatorCalculator.ema(closingPrices, 55);
    final bollingerBands = TechnicalIndicatorCalculator.bollingerBands(closingPrices, 20, 2);

    _drawPriceChart(canvas, priceRect, closingPrices, fastTrendLine, slowTrendLine, bollingerBands);

    for (var index = 0; index < panels.length; index++) {
      final panelTop = priceRect.bottom + 8 + panelHeight * index;
      final rect = Rect.fromLTWH(_plotLeft, panelTop, _plotWidth, panelHeight - 4);
      _drawIndicatorPanel(canvas, rect, panels[index], closingPrices);
    }
  }

  void _drawPriceChart(
    Canvas canvas,
    Rect rect,
    List<double> closingPrices,
    List<double?> fastTrendLine,
    List<double?> slowTrendLine,
    BollingerBandsData bollingerBands,
  ) {
    final visibleBars = marketBars.sublist(_firstVisibleBarIndex);
    var minPrice = visibleBars.map((bar) => bar.low).reduce((a, b) => math.min(a, b).toDouble());
    var maxPrice = visibleBars.map((bar) => bar.high).reduce((a, b) => math.max(a, b).toDouble());
    final padding = (maxPrice - minPrice) * 0.08;
    minPrice -= padding;
    maxPrice += padding;
    if (maxPrice <= minPrice) maxPrice = minPrice + 1;

    final volumeHeight = math.min(42.0, rect.height * 0.16).toDouble();
    final plotTop = rect.top + 12;
    final plotBottom = rect.bottom - volumeHeight - 12;
    final candleWidth = math.max(2.0, math.min(11.0, _plotWidth / _visibleBarCount * 0.66)).toDouble();
    double y(double value) =>
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

    if (activeIndicatorTypes.contains(IndicatorType.trendRibbon)) {
      _drawSeries(canvas, fastTrendLine, y, green, width: 1.7);
      _drawSeries(canvas, slowTrendLine, y, violet, width: 1.35);
    }
    if (activeIndicatorTypes.contains(IndicatorType.bollingerSqueeze)) {
      _drawSeries(canvas, bollingerBands.upper, y, blue.withValues(alpha: 0.72), width: 1);
      _drawSeries(canvas, bollingerBands.middle, y, muted, width: 1);
      _drawSeries(canvas, bollingerBands.lower, y, blue.withValues(alpha: 0.72), width: 1);
    }

    final last = marketBars.last;
    final lastY = y(last.close);
    final currentLine = Paint()
      ..color = green.withValues(alpha: 0.55)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(_plotLeft, lastY), Offset(_plotLeft + _plotWidth, lastY), currentLine);
    _text(canvas, _formatValue(last.close), Offset(rect.right - 48, lastY - 15),
        size: 9, color: ink, weight: FontWeight.w700);
    _text(canvas, 'PRICE / VOLUME', Offset(rect.left, rect.top - 16), size: 10, color: body,
        weight: FontWeight.w700);
    _drawTimeLabels(canvas, rect);

    if (hoveredBarIndex != null && hoveredBarIndex! >= _firstVisibleBarIndex && hoveredBarIndex! < marketBars.length) {
      final local = hoveredBarIndex! - _firstVisibleBarIndex;
      final x = _xForLocal(local);
      final crosshair = Paint()
        ..color = ink.withValues(alpha: 0.2)
        ..strokeWidth = 1;
      canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), crosshair);
      final bar = marketBars[hoveredBarIndex!];
      final tooltipText = '${_formatBarDate(bar.timestamp)}  ${_formatValue(bar.close)}';
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

  void _drawIndicatorPanel(Canvas canvas, Rect rect, IndicatorType indicatorType, List<double> closingPrices) {
    canvas.drawRect(rect, Paint()..color = const Color(0xfffafbfb));
    canvas.drawRect(
      rect,
      Paint()
        ..color = grid
        ..style = PaintingStyle.stroke,
    );
    _text(canvas, indicatorType.shortName, Offset(rect.left + 6, rect.top + 4),
        size: 9, color: body, weight: FontWeight.w700);

    final first = switch (indicatorType) {
      IndicatorType.rsiPulse => TechnicalIndicatorCalculator.rsi(closingPrices, 14),
      IndicatorType.macdMomentum => TechnicalIndicatorCalculator.macd(closingPrices).primary,
      IndicatorType.volumePressure => TechnicalIndicatorCalculator.volumePressure(marketBars),
      IndicatorType.smartFlow => TechnicalIndicatorCalculator.smartFlow(marketBars).primary,
      _ => const <double?>[],
    };
    final second = switch (indicatorType) {
      IndicatorType.rsiPulse => TechnicalIndicatorCalculator.ema(
          TechnicalIndicatorCalculator.rsi(closingPrices, 14).map((value) => value ?? 50).toList(), 5),
      IndicatorType.macdMomentum => TechnicalIndicatorCalculator.macd(closingPrices).secondary,
      IndicatorType.smartFlow => TechnicalIndicatorCalculator.smartFlow(marketBars).secondary,
      _ => const <double?>[],
    };
    final third = indicatorType == IndicatorType.macdMomentum
        ? TechnicalIndicatorCalculator.macd(closingPrices).tertiary
        : const <double?>[];

    var minValue = -1.0;
    var maxValue = 1.0;
    if (indicatorType == IndicatorType.rsiPulse) {
      minValue = 0;
      maxValue = 100;
    } else if (indicatorType == IndicatorType.volumePressure || indicatorType == IndicatorType.smartFlow) {
      minValue = -100;
      maxValue = 100;
    } else {
      final values = <double>[
        ...first.whereType<double>(),
        ...second.whereType<double>(),
        ...third.whereType<double>(),
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
    double y(double value) =>
        rect.bottom - 8 - (value - minValue) / (maxValue - minValue) * (rect.height - 25);

    if (indicatorType == IndicatorType.rsiPulse) {
      _drawReference(canvas, rect, y(70), violet.withValues(alpha: 0.4));
      _drawReference(canvas, rect, y(30), violet.withValues(alpha: 0.4));
    } else {
      _drawReference(canvas, rect, y(0), grid);
    }
    _drawSeries(canvas, first, y, indicatorType == IndicatorType.rsiPulse ? violet : green, width: 1.5);
    if (second.isNotEmpty) {
      _drawSeries(canvas, second, y, indicatorType == IndicatorType.smartFlow ? blue : ink, width: 1);
    }
    if (indicatorType == IndicatorType.macdMomentum) {
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
    for (var local = 0; local < _visibleBarCount; local++) {
      final value = values[_firstVisibleBarIndex + local];
      if (value == null) continue;
      final x = _xForLocal(local);
      final nextX = local + 1 < _visibleBarCount ? _xForLocal(local + 1) : x + 3;
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
    for (var local = 0; local < _visibleBarCount; local++) {
      final value = values[_firstVisibleBarIndex + local];
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
      final local = ((_visibleBarCount - 1) * mark / 3).round();
      final x = _xForLocal(local);
      _text(canvas, _formatBarDate(marketBars[_firstVisibleBarIndex + local].timestamp), Offset(x - 22, rect.bottom + 4), size: 8, color: muted);
    }
  }

  double _xForLocal(int local) =>
      _plotLeft + (_visibleBarCount <= 1 ? 0 : local / (_visibleBarCount - 1) * _plotWidth);

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

  String _formatBarDate(DateTime value) => '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}';

  String _formatValue(double value) => value.abs() >= 1000 ? value.toStringAsFixed(0) : value.toStringAsFixed(2);

  @override
  bool shouldRepaint(covariant _MarketChartPainter oldDelegate) =>
      oldDelegate.marketBars != marketBars ||
      oldDelegate.activeIndicatorTypes != activeIndicatorTypes ||
      oldDelegate.chartZoom != chartZoom ||
      oldDelegate.hoveredBarIndex != hoveredBarIndex;
}
