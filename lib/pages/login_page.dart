import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/auth_service.dart';
import 'top_curve_clipper.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;

  final AuthService _authService = AuthService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args == 'logout') {
      emailController.clear();
      passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          // Curved Header
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              child: Text(
                'Login',
                style: GoogleFonts.montserrat(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          // Login Form
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 200, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/login.png',
                      height: 200,
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    TextFormField(
                      controller: emailController,
                      style: GoogleFonts.montserrat(),
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: const Icon(Icons.email),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFBFBF6E), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFBFBF6E), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Password Field with Visibility Toggle
                    TextFormField(
                      controller: passwordController,
                      obscureText: !_passwordVisible,
                      style: GoogleFonts.montserrat(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: GoogleFonts.montserrat(),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _passwordVisible = !_passwordVisible;
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFBFBF6E), width: 2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: Color(0xFFBFBF6E), width: 1.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Please enter your password'
                          : null,
                    ),
                    const SizedBox(height: 24),

                    // Login Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _loginUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBFBF6E),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(
                              'Login',
                              style: GoogleFonts.montserrat(
                                fontSize: 18,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 12),

                    // Forgot Password
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/forgot_password');
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFFE10238),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Register Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: GoogleFonts.montserrat()),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/signup');
                          },
                          child: Text(
                            'Register Now',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFE10238),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Login function
  void _loginUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        User? user = await _authService.loginWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
        );

        if (user != null) {
          await _authService.ensureUserDataExists(user);

          Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
          String? userRole = userData?['role'] as String?;

          if (userRole == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'Role information not found. Please contact support.')),
            );
            setState(() => _isLoading = false);
            return;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Logged in successfully!')),
          );

          _navigateBasedOnRole(userRole);
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Login failed';
        if (e.code == 'user-not-found') errorMessage = 'No user found';
        else if (e.code == 'wrong-password') errorMessage = 'Incorrect password';
        else if (e.code == 'invalid-email') errorMessage = 'Invalid email';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateBasedOnRole(String role) {
    switch (role) {
      case 'Admin':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin_dashboard',
          (route) => false,
        );
        break;
      case 'Farm-holder':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/farmholderscreen',
          (route) => false,
        );
        break;
      case 'Farmer':
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/farmerdashboard',
          (route) => false,
        );
        break;
      default:
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/user_dashboard',
          (route) => false,
        );
    }
  }
}
