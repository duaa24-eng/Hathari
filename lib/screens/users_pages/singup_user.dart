import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/users_pages/device_Setup.dart';

class SignUpUser extends StatefulWidget {
  const SignUpUser({super.key});

  @override
  State<SignUpUser> createState() => _SignUpUserState();
}

class _SignUpUserState extends State<SignUpUser> {
  // تعريف الـ Controllers لالتقاط البيانات
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // دالة تسجيل المستخدم
  Future<void> _signUp() async {
    // 1. التحقق من تطابق كلمة المرور
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      return;
    }

    try {
      // 2. إنشاء الحساب في Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // 3. حفظ اسم المستخدم والبيانات الأولية في Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'userName': userNameController.text.trim(),
        'email': emailController.text.trim(),
        'role': 'user', // تمييزه كـ مستخدم عادي وليس أدمن
        'createdAt': DateTime.now(),
      });

      // 4. الانتقال للصفحة التالية (Device Setup)
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const UserDeviceSetup()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SingleChildScrollView( // أضفت هذا لضمان عدم حدوث Overflow عند ظهور الكيبورد
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Sign up',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 36, color: Color(0xFF9E122C)),
                  ),
                ),
              ),

              // حقول الإدخال مع ربطها بالـ Controllers
              _buildInputField(label: 'user name:', topLabel: 200, topInput: 240, controller: userNameController),
              _buildInputField(label: 'Email:', topLabel: 300, topInput: 340, controller: emailController),
              _buildInputField(label: 'password:', topLabel: 400, topInput: 440, isPassword: true, controller: passwordController),
              _buildInputField(label: 'Confirm password:', topLabel: 500, topInput: 540, isPassword: true, controller: confirmPasswordController),

              // زر التسجيل (Next)
              Positioned(
                bottom: 80,
                left: MediaQuery.of(context).size.width / 2 - 64,
                child: Transform.rotate(
                  angle: 0.45 * (3.14159 / 180),
                  child: GestureDetector(
                    onTap: _signUp, // استدعاء دالة التسجيل
                    child: Container(
                      width: 128,
                      height: 55,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9E122C),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Next',
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              // زر الرجوع
              Positioned(
                top: 50,
                left: 20,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({required String label, required double topLabel, required double topInput, bool isPassword = false, required TextEditingController controller}) {
    return Stack(
      children: [
        Positioned(
          left: 47,
          top: topLabel,
          child: Text(label, style: const TextStyle(fontSize: 20, color: Color(0xFF9E122C))),
        ),
        Positioned(
          top: topInput,
          left: 47,
          child: Transform.rotate(
            angle: 0.45 * (3.14159 / 180),
            child: Container(
              width: 290,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)], // لمسة جمالية بسيطة
              ),
              child: TextField(
                controller: controller,
                obscureText: isPassword,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}