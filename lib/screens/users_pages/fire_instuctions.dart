import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class FireInstructionsScreen extends StatefulWidget {
  final String username;
  final String password;

  const FireInstructionsScreen({
    super.key,
    required this.username,
    required this.password,
  });

  @override
  State<FireInstructionsScreen> createState() => _FireInstructionsScreenState();
}

class _FireInstructionsScreenState extends State<FireInstructionsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // التحقق من صلاحية الأدمن بناءً على البيانات المحددة
  bool get _isActuallyAdmin => 
      widget.username == "Duaa24" && widget.password == "2003##Du";

  Future<void> _openFile(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar("URL is invalid or unavailable");
      }
    } catch (e) {
      _showSnackBar("Error opening file");
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF9E122C)),
    );
  }

  // نافذة إضافة رابط جديد (للأدمن فقط)
  void _showAddDialog() {
    TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Add Instruction Link", style: TextStyle(color: Color(0xFF9E122C))),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(labelText: "Google Drive Link"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E122C),
              foregroundColor: Colors.white, // تم تغيير لون النص والأيقونة للأبيض
            ),
            onPressed: () async {
              if (urlController.text.isNotEmpty) {
                await _firestore.collection('instructions').add({
                  'url': urlController.text.trim(),
                  'timestamp': FieldValue.serverTimestamp(),
                });
                Navigator.pop(context);
                _showSnackBar("Added Successfully");
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  // نافذة تأكيد الحذف (للأدمن فقط)
  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to remove this instruction link?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              await _firestore.collection('instructions').doc(id).delete();
              Navigator.pop(context);
              _showSnackBar("Deleted Successfully");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF9E122C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Fire Instructions",
          style: TextStyle(
            color: Color(0xFF9E122C),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('instructions').orderBy('timestamp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          
          final docs = snapshot.data?.docs ?? [];

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (docs.isEmpty)
                  const Text("No instructions available.", style: TextStyle(color: Colors.grey))
                else
                  // عرض الرابط الأخير كأيقونة كبيرة
                  GestureDetector(
                    onTap: () => _openFile(docs.first['url']),
                    child: Column(
                      children: [
                        const Icon(Icons.local_fire_department, size: 120, color: Color(0xFF9E122C)),
                        const SizedBox(height: 10),
                        const Text(
                          "Tap to view Safety Guide",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF9E122C)),
                        ),
                        if (_isActuallyAdmin) ...[
                          const SizedBox(height: 30),
                          IconButton(
                            icon: const Icon(Icons.delete_forever, color: Colors.red, size: 40),
                            onPressed: () => _confirmDelete(docs.first.id),
                          ),
                          const Text("Delete Current Link", style: TextStyle(color: Colors.red)),
                        ]
                      ],
                    ),
                  ),
                
                // زر الإضافة للأدمن فقط يظهر في الأسفل إذا كانت القائمة فارغة
                if (_isActuallyAdmin && docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9E122C),
                        foregroundColor: Colors.white, // تم تغيير لون النص والأيقونة للأبيض هنا أيضاً
                      ),
                      onPressed: _showAddDialog,
                      icon: const Icon(Icons.add),
                      label: const Text("Add New Link"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}