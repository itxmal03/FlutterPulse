import 'package:flutter/material.dart';
import 'package:flutter_pulse/core/constants.dart';
import 'package:flutter_pulse/ui/screens/home_screen.dart';
import 'package:flutter_pulse/viewModels/build_viewmodel.dart';
import 'package:flutter_pulse/viewModels/history_viewmodel.dart';
import 'package:flutter_pulse/viewModels/pick_directory_viewmodel.dart';
import 'package:flutter_pulse/viewModels/sdk_info_viewmodel.dart';
import 'package:flutter_pulse/viewModels/theme_viewmodel.dart';
import 'package:provider/provider.dart';
 
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewmodel()),
        ChangeNotifierProvider(create: (_) => PickDirectoryViewmodel()),
        ChangeNotifierProvider(create: (_) => SdkInfoViewmodel()),
        // historyViewModel must be created before BuildViewModel
        // because BuildViewModel holds a reference to it
        ChangeNotifierProvider(create: (_) => HistoryViewModel()),
        ChangeNotifierProxyProvider<HistoryViewModel, BuildViewModel>(
          create: (ctx) =>
              BuildViewModel(historyViewModel: ctx.read<HistoryViewModel>()),
          update: (ctx, historyVm, previous) =>
              previous ?? BuildViewModel(historyViewModel: historyVm),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeVM = context.watch<ThemeViewmodel>();

    return MaterialApp(
      title: 'FlutterPulse',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.isDark
            ? AppColors.bg
            : const Color(0xFFFFFFFF),
        colorScheme: ColorScheme.light(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.dark(
          primary: AppColors.accent,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        fontFamily: 'monospace',
      ),
      themeMode: themeVM.isDark ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}
