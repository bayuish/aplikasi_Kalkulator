import 'package:aplikasikalkulator/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'logic/calculator_logic.dart';
import 'package:provider/provider.dart';

const supabaseUrl = 'https://znbwooekufqhaporjlnf.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpuYndvb2VrdWZxaGFwb3JqbG5mIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2MjAzNDQsImV4cCI6MjA1ODE5NjM0NH0.g6Ytr7d8iODe-x8gbiebYrxn9Fb7BDVvMUMQJ5K7l4g';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => CalculatorLogic(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}