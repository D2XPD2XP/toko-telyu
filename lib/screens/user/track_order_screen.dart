import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({super.key, required String orderId});

  @override
  Widget build(BuildContext context) {
    final Color mainColor = Color(0xFFED1E28);
    final Color greyColor = Colors.grey.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Detail Status",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        children: [
          // ... (Sisa kode body sama seperti sebelumnya)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              children: [
                _buildStepperStep(
                  icon: Icons.widgets_outlined,
                  label: "Packed",
                  isCompleted: true,
                  isActive: false,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
                _buildStepperConnector(isCompleted: true, mainColor: mainColor),
                _buildStepperStep(
                  icon: Icons.local_shipping,
                  label: "Shipped",
                  isCompleted: false,
                  isActive: true,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
                _buildStepperConnector(
                  isCompleted: false,
                  mainColor: mainColor,
                ),
                _buildStepperStep(
                  icon: Icons.inventory_outlined,
                  label: "Delivered",
                  isCompleted: false,
                  isActive: false,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
              ],
            ),
          ),

          Divider(thickness: 6, color: Colors.grey[100]),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Status",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                SizedBox(height: 4),
                Text(
                  "Shipped",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          _buildTimelineItem(
            date: "Monday, 04 October 2025",
            time: "11:48 WIB",
            description:
                "Paket sedang disiapkan dan akan diserahkan kepada ekpedisi untuk dikirimkan.",
            courier: "Kurir: JNE",
            isLast: false,
            isActive: true,
            mainColor: mainColor,
            greyColor: greyColor,
          ),
          _buildTimelineItem(
            date: "Monday, 03 October 2025",
            time: "11:48 WIB",
            description:
                "Paket sedang disiapkan dan akan diserahkan kepada ekpedisi untuk dikirimkan.",
            courier: "Kurir: JNE",
            isLast: false,
            isActive: false,
            mainColor: mainColor,
            greyColor: greyColor,
          ),
          _buildTimelineItem(
            date: "Monday, 03 October 2025",
            time: "11:48 WIB",
            description:
                "Paket sedang disiapkan dan akan diserahkan kepada ekpedisi untuk dikirimkan.",
            courier: "Kurir: JNE",
            isLast: false,
            isActive: false,
            mainColor: mainColor,
            greyColor: greyColor,
          ),
          _buildTimelineItem(
            date: "Monday, 02 October 2025",
            time: "11:48 WIB",
            description:
                "Paket sedang disiapkan dan akan diserahkan kepada ekpedisi untuk dikirimkan.",
            courier: "Kurir: JNE",
            isLast: true,
            isActive: false,
            mainColor: mainColor,
            greyColor: greyColor,
          ),
        ],
      ),
    );
  }

  // ... (Helper Widgets seperti _buildStepperStep, _buildStatusCircle, dll TETAP SAMA)
  // Saya salin ulang helper widgets agar file lengkap dan runnable

  Widget _buildStepperStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required Color mainColor,
    required Color greyColor,
  }) {
    Color iconColor = isCompleted || isActive ? mainColor : greyColor;
    Color textColor = isActive
        ? mainColor
        : (isCompleted ? Colors.black : greyColor);
    FontWeight textWeight = isActive ? FontWeight.bold : FontWeight.normal;

    return Expanded(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 40, height: 35, color: Colors.white),
              Positioned(top: 0, child: Icon(icon, size: 30, color: iconColor)),
              Positioned(
                bottom: 0,
                child: _buildStatusCircle(
                  isCompleted: isCompleted,
                  isActive: isActive,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: textWeight),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCircle({
    required bool isCompleted,
    required bool isActive,
    required Color mainColor,
    required Color greyColor,
  }) {
    if (isCompleted) {
      return Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.check, size: 10, color: Colors.white),
      );
    }
    if (isActive) {
      return Container(
        padding: EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: mainColor,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Icon(Icons.circle, size: 8, color: Colors.white),
      );
    }
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: greyColor, width: 2),
      ),
    );
  }

  Widget _buildStepperConnector({
    required bool isCompleted,
    required Color mainColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0),
        child: Divider(
          color: isCompleted ? mainColor : Colors.grey.shade300,
          thickness: 2,
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String date,
    required String time,
    required String description,
    required String courier,
    required bool isLast,
    required bool isActive,
    required Color mainColor,
    required Color greyColor,
  }) {
    Color iconColor = isActive ? mainColor : greyColor;
    IconData iconData = isActive
        ? Icons.check_circle
        : Icons.check_circle_outline;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 60,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),
                if (!isLast)
                  Expanded(child: Container(width: 2, color: greyColor)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.black : Colors.black87,
                        ),
                      ),
                      Expanded(child: Container()),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    courier,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
