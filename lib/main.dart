import 'package:ReHarvest/pages/admin_dashboard.dart';
import 'package:ReHarvest/pages/forgotpassword.dart';
import 'package:ReHarvest/pages/login_page.dart';
import 'package:ReHarvest/pages/signup.dart';
import 'package:ReHarvest/pages/startpage.dart';
import 'package:flutter/material.dart';
// import 'login_page.dart'; // Placeholder – create this next

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
      routes: {
        '/': (context) =>  StartPage(),
        '/login': (context) => const LoginPage(), 
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/signup': (context) => const SignUpPage(),


      },
    );
  }
}
