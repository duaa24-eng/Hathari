//done 21/4
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/station_pages/request.dart';
import 'package:hathari_app/screens/station_pages/dash_station.dart';
import 'package:hathari_app/screens/Notification.dart';
import 'package:hathari_app/screens/password.dart'; 

class LoginStation extends StatefulWidget {
  const LoginStation({super.key});

  @override
  State<LoginStation> createState() => _LoginStationState();
}
class _LoginStationState extends State<LoginStation> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showSnackBar('Please enter email and password', Colors.orange);
      return; }
    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      final doc = await FirebaseFirestore.instance
          .collection('stations')
          .doc(userCredential.user!.uid)
          .get();
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        final String status = data?['status'] ?? 'Active';
        if (status == 'Rejected' || status == 'Deleted') {
          await FirebaseAuth.instance.signOut();
          _showSnackBar(
            status == 'Deleted' 
                ? 'This station has been removed by the admin.' 
                : 'This station application was rejected.', 
            Colors.red
          );
          return;
        }

        // تسجيل الدخول بنجاح لصفحة المحطة
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const StationHome()),
        );

      } else {
        // إذا نجح التسجيل في Auth لكنه غير موجود في جدول stations (مثلاً يوزر عادي حاول يدخل هنا)
        await FirebaseAuth.instance.signOut();
        _showSnackBar('Access denied: No station record found for this account.', Colors.red);
      }
      
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') message = 'No account found with this email';
      else if (e.code == 'wrong-password') message = 'Incorrect password';
      else if (e.code == 'invalid-email') message = 'Email format is invalid';
      else if (e.code == 'user-disabled') message = 'This account has been disabled';
      
      _showSnackBar(message, Colors.red);
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: Stack(
        children: [
          const Positioned(
            top: 150, left: 0, right: 0,
            child: Center(
              child: Text('Station Login',
                style: TextStyle(fontFamily: 'Inter', fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF9E122C)),
              ),
            ),
          ),
          Positioned(
            top: 50, 
            left: 20, 
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          
          _buildLabel(top: 250, text: 'Email:'),
          _buildTextField(
            top: 290, 
            controller: _emailController, 
            hint: 'station@mail.com',
            keyboardType: TextInputType.emailAddress
          ),
          _buildLabel(top: 370, text: 'Password:'),
          _buildTextField(
            top: 410, 
            controller: _passwordController, 
            isPassword: true,
            obscureText: _obscurePassword,
            onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
          
          Positioned(
            top: 490, left: 0, right: 0,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgetPassword(userType: "Station"),
                  ),
                );
              },
              child: const Text('forget password?',
                style: TextStyle(fontSize: 18, color: Color(0xFF9E122C), decoration: TextDecoration.underline),
              ),
            ),
          ),

          Positioned(
            top: 580, left: 50, right: 50,
            child: GestureDetector(
              onTap: _isLoading ? null : _login,
              child: Container(
                height: 55,
                decoration: BoxDecoration(color: const Color(0xFF9E122C), borderRadius: BorderRadius.circular(12)),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login', style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 100, left: 0, right: 0,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FirestationRequest())),
              child: const Center(
                child: Text('Register New Station',
                  style: TextStyle(fontSize: 20, color: Color(0xFF9E122C), fontWeight: FontWeight.w500, decoration: TextDecoration.underline),
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 30,
            right: 40,
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SendNotificationScreen()), 
                );
              },
              child: const Icon(
                Icons.mark_email_unread, 
                size: 39, 
                color: Color(0xFF852221),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel({required double top, required String text}) {
    return Positioned(
      left: 50, top: top,
      child: Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF9E122C))),
    );
  }

  Widget _buildTextField({
    required double top, 
    required TextEditingController controller, 
    String? hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Positioned(
      top: top, left: 50, right: 50,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: isPassword 
                ? IconButton(
                    icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9E122C)),
                    onPressed: onToggleVisibility,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}