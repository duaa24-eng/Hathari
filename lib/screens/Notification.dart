//done 
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class SendNotificationScreen extends StatefulWidget {
  const SendNotificationScreen({super.key});

  @override
  State<SendNotificationScreen> createState() => _SendNotificationScreenState();
}

class _SendNotificationScreenState extends State<SendNotificationScreen> {
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _descriptionController = TextEditingController();
  String selectedType = 'App';
  bool isLoading = false;

  Future<void> _handleSendNotification() async {
    final String subject = _subjectController.text.trim();
    final String email = _emailController.text.trim();
    final String description = _descriptionController.text.trim();

    if (subject.isEmpty || email.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'subject': subject,
        'senderEmail': email, 
        'description': description,
        'type': selectedType,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'unread',
        'deviceId': "Auto-linking Soon", // سيتم ربطه لاحقاً برمجياً
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sent Successfully!'), backgroundColor: Colors.green),
        );
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double rotation = 0.45 * (math.pi / 180);
    const Color mainRed = Color(0xFF9E122C);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            children: [
              const Text('Send Notification', 
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: mainRed, fontStyle: FontStyle.italic)),
              const SizedBox(height: 30),
              
              _inputLabel("Subject:"),
              _customTextField(_subjectController, "Title...", rotation),
              
              _inputLabel("Your Email:"),
              _customTextField(_emailController, "example@mail.com", rotation),

              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTypeBtn('App', mainRed),
                  const SizedBox(width: 15),
                  _buildTypeBtn('Device', mainRed),
                ],
              ),

              _inputLabel("Description:"),
              _customTextField(_descriptionController, "Details...", rotation, maxLines: 5),

              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _actionBtn("Close", mainRed, rotation, () => Navigator.pop(context)),
                  _actionBtn(isLoading ? "..." : "Send", mainRed, rotation, isLoading ? null : _handleSendNotification),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputLabel(String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Align(alignment: Alignment.centerLeft, child: Text(label, style: const TextStyle(fontSize: 22, color: Color(0xFF9E122C)))),
  );

  Widget _customTextField(TextEditingController ctrl, String hint, double angle, {int maxLines = 1}) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        color: Colors.white,
        child: TextField(
          controller: ctrl,
          maxLines: maxLines,
          decoration: InputDecoration(hintText: hint, contentPadding: const EdgeInsets.all(10), border: InputBorder.none),
        ),
      ),
    );
  }

  Widget _buildTypeBtn(String type, Color color) {
    bool isSelected = selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? color : Colors.white, border: Border.all(color: color)),
        child: Text(type, style: TextStyle(color: isSelected ? Colors.white : color, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _actionBtn(String label, Color color, double angle, VoidCallback? onTap) {
    return Transform.rotate(
      angle: angle,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 110, height: 50, color: color, alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 20)),
        ),
      ),
    );
  }
}