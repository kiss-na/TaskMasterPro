import 'package:flutter/material.dart';
import 'package:task_manager/config/routes.dart';
import 'package:task_manager/config/theme.dart';
import 'package:task_manager/presentation/screens/home_screen.dart';

class TaskManagerApp extends StatelessWidget {
  const TaskManagerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      home: const HomeScreen(),
    );
  }
}
