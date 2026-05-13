//ما شغلناها رسمي \\ تشغلت
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hathari_app/screens/admin_pages/user_edit.dart'; 

class UserManagement extends StatefulWidget {
  const UserManagement({super.key});

  @override
  State<UserManagement> createState() => _UserManagementState();
}

class _UserManagementState extends State<UserManagement> {
  String searchQuery = ""; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Column(
          children: [
            // الهيدر: زر العودة والعنوان
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C), size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'User Management',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9E122C),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), // للموازنة مع زر العودة
                ],
              ),
            ),

            // شريط البحث
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 23, vertical: 10),
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF9E122C).withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  onChanged: (value) => setState(() => searchQuery = value.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: 'Search Users...',
                    prefixIcon: Icon(Icons.search, color: Color(0xFF9E122C)),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // رأس الجدول (Header) بنفس تنسيق الصورة
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 15),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF9E122C).withOpacity(0.4)),
              ),
              child: Row(
                children: const [
                  Expanded(flex: 2, child: Center(child: Text("Name", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E122C))))),
                  Expanded(flex: 2, child: Center(child: Text("City", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E122C))))),
                  Expanded(flex: 2, child: Center(child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E122C))))),
                  Expanded(flex: 1, child: Center(child: Text("Action", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF9E122C))))),
                ],
              ),
            ),

            // قائمة البيانات
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var docs = snapshot.data!.docs.where((doc) {
                    var name = (doc.data() as Map<String, dynamic>)['name']?.toString().toLowerCase() ?? "";
                    return name.contains(searchQuery);
                  }).toList();

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var data = docs[index].data() as Map<String, dynamic>;
                      data['docId'] = docs[index].id;
                      return _buildUserRow(context, data);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت بناء الصف (Row) بناءً على تنسيق الجوال
  Widget _buildUserRow(BuildContext context, Map<String, dynamic> user) {
    String status = user['status'] ?? "ACTIVE"; // افترضت وجود حقل حالة
    Color statusColor = status == "DELETED" ? Colors.orange : Colors.green;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: const Color(0xFF9E122C).withOpacity(0.4)),
          right: BorderSide(color: const Color(0xFF9E122C).withOpacity(0.4)),
          bottom: BorderSide(color: const Color(0xFF9E122C).withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Center(child: Text(user['name'] ?? "---", style: const TextStyle(fontSize: 13, color: Color(0xFF9E122C))))),
          Expanded(flex: 2, child: Center(child: Text(user['city'] ?? "---", style: const TextStyle(fontSize: 13, color: Color(0xFF9E122C))))),
          Expanded(
            flex: 2, 
            child: Center(
              child: Text(
                status.toUpperCase(), 
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)
              )
            )
          ),
          Expanded(
            flex: 1, 
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserEditScreen(docId: user['docId'], userData: user)),
                );
              },
              child: const Center(
                child: Text(
                  "View", 
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF9E122C), decoration: TextDecoration.underline)
                )
              ),
            )
          ),
        ],
      ),
    );
  }
}