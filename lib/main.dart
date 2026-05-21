import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models/todo_list.dart';
import 'models/todo_item.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TASKR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFE8FF47),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0D0D0D),
        fontFamily: 'Courier',
      ),
      home: const HomeScreen(),
    );
  }
}
