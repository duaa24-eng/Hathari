//done
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AdminReplyScreen extends StatefulWidget {
  final String email;
  final String subject;

  const AdminReplyScreen({
    super.key,
    required this.email,
    required this.subject,
  });

  @override
  State<AdminReplyScreen> createState() => _AdminReplyScreenState();
}

class _AdminReplyScreenState extends State<AdminReplyScreen> {
  final TextEditingController _replyController = TextEditingController();
  bool isSending = false;

  // دالة إرسال الإيميل الحقيقي
  Future<void> _sendRealEmail(String recipientEmail, String replyMessage) async {
    String username = 'duaaa7839@gmail.com';
    String password = 'tuev ysdd fzuy qjvd'; // App Password

    final smtpServer = gmail(username, password);

    final message = Message()
      ..from = Address(username, 'Hathari App Admin')
      ..recipients.add(recipientEmail)
      ..subject = 'Update on your issue: ${widget.subject}'
      ..text = "Hello,\n\nRegarding your issue: ${widget.subject}\n\nAdmin Response:\n$replyMessage\n\nThank you for using Hathari App.";

    try {
      await send(message, smtpServer);
      print('Email sent successfully to $recipientEmail');
    } catch (e) {
      print('Email sending failed: $e');
      // لا نعطل العملية إذا فشل الإيميل، الأهم هو قاعدة البيانات
    }
  }

  Future<void> _handleSendReply() async {
    final String replyText = _replyController.text.trim();

    if (replyText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply first')),
      );
      return;
    }

    setState(() => isSending = true);

    try {
      // 1. ضمان رد واحد فقط: نستخدم معرف مستند ثابت (Email + Subject)
      // هذا يضمن أنه إذا رد الآدمن مرة ثانية، يتم تحديث الرد نفسه ولا يتكرر
      String docId = "${widget.email}_${widget.subject}".replaceAll(RegExp(r'[.#$\[\]]'), '_');

      String fullMessage = "Issue: ${widget.subject}\n\nAdmin Response: $replyText";

      await FirebaseFirestore.instance.collection('replies').doc(docId).set({
        'toUserEmail': widget.email,
        'originalSubject': widget.subject,
        'fullMessage': fullMessage,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. إرسال الإيميل الحقيقي
      await _sendRealEmail(widget.email, replyText);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply sent and Email dispatched!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color mainRed = Color(0xFF9E122C);
    final double rotationAngle = 0.45 * (math.pi / 180);
    final Matrix4 customTransform = Matrix4.identity()..setEntry(0, 1, 0.01)..setEntry(1, 0, -0.01);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "Write Reply",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: mainRed, fontStyle: FontStyle.italic),
                ),
              ),
            ),

            _buildLabel("To User:", 170, Colors.black),
            _buildLabel("Subject:", 233, Colors.black),
            _buildLabel("Your Reply:", 350, Colors.black),

            _buildDataBox(top: 165, angle: rotationAngle, value: widget.email),
            _buildDataBox(top: 228, angle: rotationAngle, value: widget.subject),

            Positioned(
              top: 390,
              left: (MediaQuery.of(context).size.width / 2) - 150,
              child: Transform(
                transform: customTransform,
                child: Container(
                  width: 300,
                  height: 180,
                  padding: const EdgeInsets.all(10),
                  color: Colors.white,
                  child: TextField(
                    controller: _replyController,
                    maxLines: 7,
                    decoration: const InputDecoration(hintText: "Enter your response here...", border: InputBorder.none),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton("Close", customTransform, mainRed, () => Navigator.pop(context)),
                  _buildActionButton(
                    isSending ? "..." : "Send", 
                    customTransform, 
                    mainRed, 
                    isSending ? () {} : _handleSendReply
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataBox({required double top, required double angle, required String value}) {
    return Positioned(
      top: top,
      right: 30,
      child: Transform.rotate(
        angle: angle,
        child: Container(
          width: 210,
          height: 35,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: Colors.white,
          alignment: Alignment.centerLeft,
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87), overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, double top, Color color) => Positioned(
        top: top,
        left: 20,
        child: Text(text, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold)),
      );

  Widget _buildActionButton(String label, Matrix4 transform, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Transform(
        transform: transform,
        child: Container(
          width: 110,
          height: 45,
          color: color,
          alignment: Alignment.center,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}