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
        fontFamilyFallback: const ['Apple SD Gothic Neo', 'Noto Sans KR', 'Arial'],
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.greenInk,
          brightness: Brightness.light,
          surface: Colors.white,
        ).copyWith(
          primary: AppColors.greenInk,
          onPrimary: Colors.white,
          outline: AppColors.border,
          onSurface: AppColors.ink,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -.7),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          bodyLarge: TextStyle(fontSize: 16, height: 1.5),
          bodyMedium: TextStyle(fontSize: 14, height: 1.5),
          bodySmall: TextStyle(fontSize: 12, height: 1.5),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(44, 44),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(44, 44),
            foregroundColor: AppColors.ink,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surfaceMuted,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.greenInk, width: 1.5)),
        ),
        tooltipTheme: const TooltipThemeData(
          waitDuration: Duration(milliseconds: 350),
          textStyle: TextStyle(color: Colors.white, fontSize: 12),
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
