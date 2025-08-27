import 'package:ReHarvest/pages/admin_dashboard.dart';
import 'package:ReHarvest/pages/datapage.dart';
import 'package:ReHarvest/pages/farmerdasboard.dart';
import 'package:ReHarvest/pages/farmholderscreen.dart';
import 'package:ReHarvest/pages/forgotpassword.dart';
import 'package:ReHarvest/pages/login_page.dart';
import 'package:ReHarvest/pages/prediction_screen.dart';
import 'package:ReHarvest/pages/signup.dart';
import 'package:ReHarvest/pages/startpage.dart';
import 'package:ReHarvest/pages/uploaddatapage.dart';
import 'package:ReHarvest/pages/viewdatapage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ReHarvest/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeFirebase();
  
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Check if Firebase is already initialized to avoid duplicate initialization
    try {
      Firebase.app();
      if (kDebugMode) {
        print('Firebase app already exists');
      }
      return;
    } on FirebaseException catch (e) {
      if (e.code == 'no-app') {
        // App doesn't exist, so initialize it
        if (kDebugMode) {
          print('Initializing Firebase...');
        }
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        if (kDebugMode) {
          print('Firebase initialized successfully');
        }
        return;
      }
      rethrow;
    }
  } catch (e) {
    // Handle the specific duplicate-app error
    if (e.toString().contains('duplicate-app')) {
      if (kDebugMode) {
        print('Firebase already initialized (duplicate app error caught)');
      }
      return;
    }
    if (kDebugMode) {
      print('Unexpected Firebase initialization error: $e');
    }
    // Continue running the app even if Firebase fails
  }
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
        '/': (context) => const StartPage(),
        '/login': (context) => const LoginPage(),
        '/admin_dashboard': (context) => const AdminDashboard(),
        '/farmholderscreen': (context) => const FarmHolderDashboard(),
        '/farmerdashboard': (context) => const FarmerDashboard(),
        '/forgot_password': (context) => const ForgotPasswordPage(),
        '/signup': (context) => const SignUpPage(),
        '/upload': (context) => const UploadDataPage(),
        '/view_data': (context) => const ViewDataPage(allData: []),
        '/predictions': (context) => const PredictionScreen(initialData: {}),
        '/data_screen': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as List<Map<String, String>>?;
          return DataPage(allData: args ?? []);
        },
      },
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
      },
    );
  }
}