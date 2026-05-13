//done 21/4
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ManageStationScreen extends StatelessWidget {
  const ManageStationScreen({super.key});

  
  Future<void> _handleLogout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      
      Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: $e")),
      );
    }
  }

  
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = user.uid;
        String? email = user.email;

        
        var requestQuery = await FirebaseFirestore.instance
            .collection('station_requests')
            .where('email', isEqualTo: email)
            .get();

        for (var doc in requestQuery.docs) {
          await doc.reference.update({'status': 'Deleted'});
        }

       
        await FirebaseFirestore.instance.collection('stations').doc(uid).delete();

        
        await user.delete();

        if (!context.mounted) return;
        
       
        Navigator.pushNamedAndRemoveUntil(context, '/Welcome_screen', (route) => false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Deleted Successfully")),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please re-login to perform this action for security reasons.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3EF),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10, top: 10),
                  /*child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF9E122C)),
                    onPressed: () => Navigator.pop(context),
                  ),*/
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Manage Station",
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Color(0xFF9E122C),
                      ),
                    ),
                    const SizedBox(height: 60),
                    _buildActionCard(context, "Delete account", () => _showDeleteDialog(context)),
                    const SizedBox(height: 30),
                    _buildActionCard(context, "Log out", () => _handleLogout(context)),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, VoidCallback onTap) {
    return Transform.rotate(
      angle: 0.0078,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 290,
          height: 55,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: const TextStyle(fontSize: 28, color: Color(0xFF9E122C)),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context); 
              _deleteAccount(context); 
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}