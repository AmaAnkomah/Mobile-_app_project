import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F172A), // Deep Slate
      body: Stack(
        children: [
          // Background Gradient/Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD4AF37).withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo/Title Section
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Color(0xFFD4AF37),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFD4AF37).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.school_outlined,
                          size: 60,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    Center(
                      child: Text(
                        'LUMINA ACADEMY',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: Text(
                        'The Future of Learning',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 48),

                    // Login Form
                    Text(
                      'LOG IN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: 24),
                    _buildTextField(
                      controller: _emailController,
                      label: 'EMAIL ADDRESS',
                      icon: Icons.email_outlined,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      controller: _passController,
                      label: 'PASSWORD',
                      icon: Icons.lock_outline,
                      obscureText: true,
                    ),
                    SizedBox(height: 32),

                    Consumer<AuthProvider>(
                      builder: (context, auth, child) => auth.isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFD4AF37),
                              ),
                            )
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFD4AF37),
                                foregroundColor: Color(0xFF0F172A),
                                padding: EdgeInsets.symmetric(vertical: 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              onPressed: () async {
                                final success = await auth.login(
                                  _emailController.text,
                                  _passController.text,
                                );
                                if (success) {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Authentication Failed'),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                                }
                              },
                              child: Center(
                                child: Text(
                                  'CONTINUE',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SignUpScreen()),
                          );
                        },
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: TextStyle(color: Color(0xFF94A3B8)),
                            children: [
                              TextSpan(
                                text: "Get Access",
                                style: TextStyle(
                                  color: Color(0xFFD4AF37),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFF334155)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color(0xFFD4AF37),
        decoration: InputDecoration(
          filled: false,
          prefixIcon: Icon(icon, color: Color(0xFF64748B), size: 20),
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            letterSpacing: 1.2,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
