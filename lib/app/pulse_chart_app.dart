import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../features/landing/presentation/pages/tradingview_workspace_page.dart';

class PulseChartApp extends StatelessWidget {
  const PulseChartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Chart',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.canvas,
        fontFamily: 'Malgun Gothic',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          brightness: Brightness.light,
          surface: Colors.white,
        ),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.green,
          selectionColor: Color(0x4400de5a),
          selectionHandleColor: AppColors.green,
        ),
      ),
      home: const TradingViewWorkspacePage(),
    );
  }
}
