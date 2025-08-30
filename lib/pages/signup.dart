import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'top_curve_clipper.dart';
import '../services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  String? selectedRole;
  final List<String> roles = ['Admin', 'Farm-holder', 'Farmer'];

  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3DC),
      body: Stack(
        children: [
          ClipPath(
            clipper: TopCurveClipper(),
            child: Container(
              height: 160,
              width: double.infinity,
              color: const Color(0xFFBFBF6E),
              alignment: Alignment.center,
              padding: const EdgeInsets.only(top: 40),
              child: Text(
                'Sign up',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 180, 24, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(usernameController, 'User name'),
                    const SizedBox(height: 12),
                    _buildTextField(
                      emailController,
                      'Email',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Email';
                        }
                        final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      passwordController,
                      'Password',
                      obscure: !_passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _passwordVisible = !_passwordVisible);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      confirmPasswordController,
                      'Confirm Password',
                      obscure: !_confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() => _confirmPasswordVisible = !_confirmPasswordVisible);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    // Role Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        hintText: 'Select Role',
                        hintStyle: GoogleFonts.montserrat(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFBFBF6E), width: 1.5),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFBFBF6E), width: 1.5),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFBFBF6E), width: 2),
                        ),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      dropdownColor: const Color(0xFFFFF3DC),
                      style: GoogleFonts.montserrat(color: Colors.black),
                      items: roles.map((role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedRole = value);
                      },
                      validator: (value) =>
                          value == null ? 'Please select a role' : null,
                    ),
                    const SizedBox(height: 20),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBFBF6E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.black)
                            : Text(
                                'Sign Up',
                                style: GoogleFonts.montserrat(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Or sign up with
                    Row(
                      children: [
                        const Expanded(child: Divider(thickness: 1)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Or Sign up with',
                            style: GoogleFonts.montserrat(),
                          ),
                        ),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Social Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        FaIcon(FontAwesomeIcons.facebook, size: 32),
                        FaIcon(FontAwesomeIcons.google, size: 32),
                        FaIcon(FontAwesomeIcons.apple, size: 32),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Already have an account?
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: GoogleFonts.montserrat(),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBFBF6E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          ),
                          child: Text(
                            'Login',
                            style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Registration function
  void _registerUser() async {
    if (_formKey.currentState!.validate() && selectedRole != null) {
      setState(() => _isLoading = true);

      try {
        User? user = await _authService.registerWithEmailAndPassword(
          emailController.text.trim(),
          passwordController.text.trim(),
          usernameController.text.trim(),
          selectedRole!,
        );

        if (user != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registered successfully!')),
          );

          // Get the role from database to ensure consistency
          Map<String, dynamic>? userData = await _authService.getUserData(user.uid);
          String? userRole = userData?['role'] as String?;

          // Use the role from database, fallback to selectedRole if needed
          final effectiveRole = userRole ?? selectedRole;

          // Navigate based on role
          if (effectiveRole == 'Admin') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/admin_dashboard',
              (route) => false,
            );
          } else if (effectiveRole == 'Farm-holder') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/farmholderscreen',
              (route) => false,
            );
          } else if (effectiveRole == 'Farmer') {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/farmerdashboard',
              (route) => false,
            );
          } else {
            // Fallback for unknown roles
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user_dashboard',
              (route) => false,
            );
          }
        }
      } on FirebaseAuthException catch (e) {
        String errorMessage = 'Registration failed';
        
        if (e.code == 'weak-password') {
          errorMessage = 'Password is too weak';
        } else if (e.code == 'email-already-in-use') {
          errorMessage = 'Email is already registered';
        } else if (e.code == 'invalid-email') {
          errorMessage = 'Invalid email address';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a role')),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.montserrat(),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBFBF6E), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFBFBF6E), width: 2),
        ),
      ),
      validator: validator ??
          (value) =>
              value == null || value.isEmpty ? 'Please enter $hint' : null,
    );
  }
}