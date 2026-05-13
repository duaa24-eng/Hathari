import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NewAlertPopup extends StatelessWidget {
  final String userName;
  final String userNumber;
  final String time;
  final LatLng location;
  final VoidCallback onAccept;
  final VoidCallback onFinish;

  const NewAlertPopup({
    super.key,
    required this.userName,
    required this.userNumber,
    required this.time,
    required this.location,
    required this.onAccept,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(10),
      child: Transform.rotate(
        angle: 0.37 * (math.pi / 180),
        child: Container(
          width: 318,
          height: 520,
          decoration: BoxDecoration(
            color: const Color(0xFF9E122C),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                'New Alert',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              _buildAlertInfo("User Name:", userName),
              _buildAlertInfo("Number:", userNumber),
              _buildAlertInfo("Time:", time),

              const SizedBox(height: 20),

              // ✅ استبدلنا GoogleMap بـ FlutterMap
              Transform.rotate(
                angle: 0.45 * (math.pi / 180),
                child: Container(
                  width: 258,
                  height: 171,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: ClipRect(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: location,
                        initialZoom: 15,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.none, // تعطيل التحريك
                        ),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.hathari_app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: location,
                              width: 40,
                              height: 40,
                              child: const Icon(
                                Icons.local_fire_department,
                                color: Colors.red,
                                size: 35,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 35),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildButton("Finish", const Color(0xFF900B09), onFinish),
                  _buildButton("Accept", Colors.black, onAccept),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 10),
          Expanded(
              child: Text(value,
                  style: const TextStyle(
                      color: Colors.white, fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildButton(String text, Color textColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: 0.45 * (math.pi / 180),
        child: Container(
          width: 110,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(text,
              style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}