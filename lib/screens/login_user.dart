import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:hathari_app/screens/users_pages/singup_user.dart';
import 'package:hathari_app/screens/users_pages/Homepage_user.dart';
import 'package:hathari_app/screens/admin_pages/Homepage_admin.dart';
import 'package:hathari_app/screens/password.dart';
import 'package:hathari_app/screens/Notification.dart';

class LoginUser extends StatefulWidget {
  const LoginUser({super.key});

  @override
  State<LoginUser> createState() => _LoginUserState();
}

class _LoginUserState extends State<LoginUser> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  Future<void> _login() async {
    String username = _usernameController.text.trim();
    String password = _passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }
    setState(() => _isLoading = true);
    if (username == "Duaa24" && password == "2003##Du") {
      setState(() => _isLoading = false);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminDashboard()),
      );
      return;
    }


    try {
      var userQuery = await FirebaseFirestore.instance
          .collection('users')
          .where('userName', isEqualTo: username)
          .get();
      if (userQuery.docs.isNotEmpty) {
        String userEmail = userQuery.docs.first.data()['email'];
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail,
          password: password,   );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const UserHome()),
        ); } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username not found")),
        ); }
    } on FirebaseAuthException catch (e) {
      String message = "Login Failed";
      if (e.code == 'wrong-password') message = "Incorrect password";
      else if (e.code == 'user-not-found') message = "Account not found";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      resizeToAvoidBottomInset: false, 
      body: Stack(
        children: [
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Positioned(
            top: 150, left: 0, right: 0,
            child: Center(
              child: Text(
                'Welcome',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF9E122C),
                ),
              ),
            ),
          ),

      
          _buildLabel(top: 250, text: 'User Name:'),
          _buildTextField(
            top: 290,
            controller: _usernameController,
            hint: 'Enter your username',
          ),

    
          _buildLabel(top: 370, text: 'Password:'),
          _buildTextField(
            top: 410,
            controller: _passwordController,
            hint: '********',
            isPassword: true,
            obscureText: _isPasswordObscured,
            onToggleVisibility: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
          ),

          Positioned(
            top: 490, left: 0, right: 0,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ForgetPassword(userType: "User")),
                );
              },
              child: const Text(
                'forget password?',
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
                decoration: BoxDecoration(
                  color: const Color(0xFF9E122C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 100, left: 0, right: 0,
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpUser())),
              child: const Center(
                child: Text(
                  "Don't have an account? Sign Up",
                  style: TextStyle(fontSize: 18, color: Color(0xFF9E122C), decoration: TextDecoration.underline),
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
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF9E122C)),
      ),
    );
  }

  Widget _buildTextField({
    required double top,
    required TextEditingController controller,
    String? hint,
    bool isPassword = false,
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
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
          decoration: InputDecoration(
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            suffixIcon: isPassword ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF9E122C)),
              onPressed: onToggleVisibility,
            ) : null,
          ),
        ),
      ),
    );
  }
}