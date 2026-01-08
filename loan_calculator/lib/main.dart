import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:loan_calculator/components/calculator_interface.dart';
import 'package:loan_calculator/themes/theme.dart';
import 'package:loan_calculator/widgets/global_keys.dart';
import 'package:provider/provider.dart';

void main() async {
  await MobileAds.instance.initialize();
  runApp(
    ChangeNotifierProvider(
      create: (_) => Themes(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<Themes>(context);

    return MaterialApp(
      navigatorKey: GlobalSnackBar.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: theme.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      home: Container(
        color: theme.backgroundColor,
        child: SafeArea(
          child: CalculatorInterface()
        ),
      ),
    );
  }
}