import 'package:ReHarvest/pages/admin_dashboard.dart';
import 'package:ReHarvest/pages/datapage.dart';
import 'package:ReHarvest/pages/forgotpassword.dart';
import 'package:ReHarvest/pages/login_page.dart';
import 'package:ReHarvest/pages/prediction_screen.dart';
import 'package:ReHarvest/pages/signup.dart';
import 'package:ReHarvest/pages/startpage.dart';
import 'package:ReHarvest/pages/uploaddatapage.dart';
import 'package:ReHarvest/pages/viewdatapage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ReHarvest/firebase_options.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  await _initializeFirebase();
  
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    // Try to access the default app - if it throws, we need to initialize
    try {
      final app = Firebase.app();
      if (kDebugMode) {
        print('Firebase app already exists: ${app.name}');
      }
      return;
    } on FirebaseException catch (e) {
      if (e.code == 'no-app') {
        // No app exists, proceed with initialization
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
      print('Firebase already initialized (duplicate app error caught)');
      return;
    }
    print('Unexpected Firebase initialization error: $e');
    // Continue running the app even if Firebase fails
  }
}
void testDatabase() async {
  try {
    final database = FirebaseDatabase.instance;
    await database.ref().child('test').set({'test': 'value'});
    print('Database write test successful');
  } catch (e) {
    print('Database test failed: $e');
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
          case '/view_data':
            return MaterialPageRoute(builder: (_) => const ViewDataPage(allData: [],));
          case '/predictions':
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