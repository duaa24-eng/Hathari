import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:url_launcher/url_launcher.dart'; // تأكدي من إضافة هذه المكتبة في pubspec.yaml

class StationManageView extends StatefulWidget {
  final String stationName;
  final String city;
  final String docId;
  final String stationEmail;
  final String stationPassword;
  final String fileUrl; // رابط الملف

  const StationManageView({
    super.key,
    required this.stationName,
    required this.city,
    required this.docId,
    required this.stationEmail,
    required this.stationPassword,
    required this.fileUrl,
  });

  @override
  State<StationManageView> createState() => _StationManageViewState();
}

class _StationManageViewState extends State<StationManageView> {
  bool _isSending = false;

  // دالة لفتح الرابط عند الضغط على زر عرض الملف
  Future<void> _openFileUrl() async {
    final Uri url = Uri.parse(widget.fileUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not open the link")),
        );
      }
    }
  }

  Future<void> _handleAction(String status) async {
    setState(() => _isSending = true);
    try {
      // 1. تحديث حالة الطلب في مجموعة station_requests
      await FirebaseFirestore.instance.collection('station_requests').doc(widget.docId).update({
        'status': status,
      });

      if (status == "Approved") {
        // 2. إنشاء الحساب في Firebase Authentication
        UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.stationEmail,
          password: widget.stationPassword,
        );
        
        // 3. تخزين البيانات في جدول 'stations' مستقل
        await FirebaseFirestore.instance.collection('stations').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'stationName': widget.stationName,
          'email': widget.stationEmail,
          'city': widget.city,
          'role': 'firefighter',
          'status': 'active',
          'approvedAt': FieldValue.serverTimestamp(),
        });

        await _sendEmailNotification('Approved');
      } else {
        await _sendEmailNotification('Rejected');
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Station $status ✅"), backgroundColor: status == "Approved" ? Colors.green : Colors.grey)
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _sendEmailNotification(String type) async {
    String adminEmail = 'duaaa7839@gmail.com';
    String appPassword = 'tuev ysdd fzuy qjvd';
    final smtpServer = gmail(adminEmail, appPassword);
    
    final message = Message()
      ..from = Address(adminEmail, 'Hathari Admin')
      ..recipients.add(widget.stationEmail)
      ..subject = type == 'Approved' ? 'Account Approved' : 'Request Update'
      ..text = type == 'Approved'
          ? 'Hello ${widget.stationName},\n\nYour account has been approved in Hathari system.\nEmail: ${widget.stationEmail}\nYou can now log in using your registered password.'
          : 'Your request to join Hathari system has been rejected.';
    
    await send(message, smtpServer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C), size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isSending 
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF9E122C))) 
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Center(
                    child: Text('Station Details', 
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF9E122C))),
                  ),
                  const SizedBox(height: 30),

                  _buildLabel('Station Name:'),
                  _buildDataContainer(widget.stationName),

                  const SizedBox(height: 15),
                  _buildLabel('Email Address:'),
                  _buildDataContainer(widget.stationEmail),

                  const SizedBox(height: 15),
                  _buildLabel('City:'),
                  _buildDataContainer(widget.city), // الآن تظهر كنص فقط لا يتغير

                  const SizedBox(height: 15),
                  _buildLabel('Documentation:'),
                  _buildFileButton(), // حقل عرض الملف

                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionButton(
                          text: 'Reject', 
                          color: Colors.grey.shade600, 
                          onTap: () => _handleAction("Rejected")
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: _buildActionButton(
                          text: 'Approve', 
                          color: const Color(0xFF9E122C), 
                          onTap: () => _handleAction("Approved")
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, bottom: 8),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF9E122C))),
    );
  }

  // حاوية عرض البيانات الثابتة
  Widget _buildDataContainer(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 15, color: Colors.black87)),
    );
  }

  // زر عرض الملف المصمم كحقل
  Widget _buildFileButton() {
    return InkWell(
      onTap: _openFileUrl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF9E122C).withOpacity(0.3)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("View Attached File", style: TextStyle(fontSize: 15, color: Colors.blue, decoration: TextDecoration.underline)),
            Icon(Icons.open_in_new, size: 20, color: Color(0xFF9E122C)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required String text, required Color color, required VoidCallback onTap}) {
    return SizedBox(
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
        onPressed: onTap,
        child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}