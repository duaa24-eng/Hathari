import 'package:flutter/material.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  final Color mainRed = const Color(0xFF9E122C);

  Widget _imageContainer(String path) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.asset(
          path,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => 
              Icon(Icons.image_search, color: Colors.grey.shade400),
        ),
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
          icon: Icon(Icons.arrow_back_ios_new, color: mainRed),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'App Guide',
          style: TextStyle(color: mainRed, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How to use Hathari App:",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 20),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2.5), 
              },
              border: TableBorder.all(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)),
              children: [
                // 1. Red Alert Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/red.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Red Alert:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red.shade700)),
                          const Text("If the alert appears in red, this means there is a high fire risk. Pressing Call contacts the station.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 2. Orange Alert Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/orange.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Orange Alert:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange.shade800)),
                          const Text("Medium-level warning. Use the Fake button to confirm if it's a false alarm.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 3. Yellow Alert Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/yellow.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Yellow Alert:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber.shade700)),
                          const Text("Early warning or slight temperature increase. Needs monitoring.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 4. Fake Button Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/fake.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fake Button:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainRed)),
                          const Text("Used to cancel notifications when the alert is false or caused by a sensor error.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 5. Call Station Button Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/call.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Call Station Button:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainRed)),
                          const Text("Allows the user to contact the station or emergency department directly.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 6. History Button Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/history.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("History Button:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainRed)),
                          const Text("Displays all previous alerts and saved records inside the system.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 7. Fire Instruction Button Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/inst.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Fire Instruction Button:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainRed)),
                          const Text("Shows fire safety instructions and guidance during emergencies.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
                // 8. Send Notification Button Row
                TableRow(
                  children: [
                    Padding(padding: const EdgeInsets.all(8.0), child: _imageContainer("photos/noti.png")),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Send Notification Button:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: mainRed)),
                          const Text("Sends warning notifications to users or authorities when danger is detected.", style: TextStyle(fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}