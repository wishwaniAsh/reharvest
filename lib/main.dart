import 'package:ReHarvest/pages/admin_dashboard.dart';
import 'package:ReHarvest/pages/datapage.dart';
import 'package:ReHarvest/pages/forgotpassword.dart';
import 'package:ReHarvest/pages/login_page.dart';
import 'package:ReHarvest/pages/prediction_screen.dart';
import 'package:ReHarvest/pages/signup.dart';
import 'package:ReHarvest/pages/startpage.dart';
import 'package:ReHarvest/pages/uploaddatapage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReHarvest',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/data_screen') {
          final args = settings.arguments as List<Map<String, String>>?;

          return MaterialPageRoute(
            builder: (context) => DataPage(
              allData: args ?? [], // pass empty list if no data provided
            ),
          );
        }

        // fallback to named routes
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const StartPage());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginPage());
          case '/admin_dashboard':
            return MaterialPageRoute(builder: (_) => const AdminDashboard());
          case '/forgot_password':
            return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpPage());
          case '/upload':
            return MaterialPageRoute(builder: (_) => const UploadDataPage());
            case '/predictions':    // <---- Add this line
            return MaterialPageRoute(builder: (_) => const PredictionScreen(initialData: {},));
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
