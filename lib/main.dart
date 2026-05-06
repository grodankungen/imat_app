import 'package:flutter/material.dart';
import 'package:imat_app/app_theme.dart';
import 'package:imat_app/model/imat_data_handler.dart';
import 'package:imat_app/model/ui_state.dart';
import 'package:imat_app/pages/main_view.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImatDataHandler()),
        ChangeNotifierProvider(create: (_) => UiState()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'iMat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      home: const MainView(),
    );
  }
}
