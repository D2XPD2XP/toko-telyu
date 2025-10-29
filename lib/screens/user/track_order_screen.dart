import 'package:flutter/material.dart';

class TrackOrderScreen extends StatelessWidget {
  const TrackOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Warna merah utama Anda
    final Color mainColor = Color(0xFFED1E28);
    // Warna abu-abu untuk item yang tidak aktif
    final Color greyColor = Colors.grey.shade400;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Detail Status",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),

        backgroundColor: Colors.white,
        elevation: 1, // Sedikit bayangan
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // --- BAGIAN 1: STEPPER HORIZONTAL ---
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Row(
              children: [
                // Step 1: Packed (Selesai)
                _buildStepperStep(
                  icon: Icons.inventory_2_outlined, // <-- IKON BARU
                  label: "Packed",
                  isCompleted: true,
                  isActive: false,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
                // Connector 1 (Selesai)
                _buildStepperConnector(isCompleted: true, mainColor: mainColor),

                // Step 2: Shipped (Aktif)
                _buildStepperStep(
                  icon: Icons.local_shipping, // <-- IKON BARU
                  label: "Shipped",
                  isCompleted: false, // Belum selesai, tapi aktif
                  isActive: true,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
                // Connector 2 (Belum Selesai)
                _buildStepperConnector(
                  isCompleted: false,
                  mainColor: mainColor,
                ),

                // Step 3: Delivered (Belum Selesai)
                _buildStepperStep(
                  icon: Icons.inventory_outlined, // <-- IKON BARU
                  label: "Delivered",
                  isCompleted: false,
                  isActive: false,
                  mainColor: mainColor,
                  greyColor: greyColor,
                ),
              ],
            ),
          ),

          // Garis pemisah
          Divider(thickness: 6, color: Colors.grey[100]),

          // --- BAGIAN 2: JUDUL STATUS ---
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

          // --- BAGIAN 3: TIMELINE VERTIKAL ---
          // Data dummy untuk timeline
          _buildTimelineItem(
            date: "Monday, 04 October 2025",
            time: "11:48 WIB",
            description:
                "Paket sedang disiapkan dan akan diserahkan kepada ekpedisi untuk dikirimkan.",
            courier: "Kurir: JNE",
            isLast: false,
            isActive: true, // Item paling atas (aktif)
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
            isActive: false, // Item lama
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
            isLast: true, // Item paling bawah
            isActive: false,
            mainColor: mainColor,
            greyColor: greyColor,
          ),
        ],
      ),
    );
  }

  // --- WIDGET BANTU UNTUK STEPPER ---
  // Ini adalah versi yang sudah diperbaiki layout-nya
  Widget _buildStepperStep({
    required IconData icon,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required Color mainColor,
    required Color greyColor,
  }) {
    // Tentukan warna berdasarkan status
    Color iconColor = isCompleted || isActive ? mainColor : greyColor;
    Color textColor = isActive
        ? mainColor
        : (isCompleted ? Colors.black : greyColor);
    FontWeight textWeight = isActive ? FontWeight.bold : FontWeight.normal;

    return Expanded(
      child: Column(
        children: [
          // Stack dengan layout yang lebih aman (tidak pakai bottom negatif)
          Stack(
            alignment: Alignment.center,
            children: [
              // Latar putih di belakang ikon (mencegah terpotong)
              Container(
                width: 40,
                height: 35, // Beri ruang 35px untuk ikon + lingkaran
                color: Colors.white,
              ),

              // Ikon utama (dipaksa ke atas)
              Positioned(top: 0, child: Icon(icon, size: 30, color: iconColor)),

              // Lingkaran status (dipaksa ke bawah)
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
          SizedBox(height: 12), // Jarak antara ikon dan teks
          // Teks Label
          Text(
            label,
            style: TextStyle(color: textColor, fontWeight: textWeight),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BANTU BARU UNTUK LINGKARAN STATUS ---
  Widget _buildStatusCircle({
    required bool isCompleted,
    required bool isActive,
    required Color mainColor,
    required Color greyColor,
  }) {
    if (isCompleted) {
      // Lingkaran centang merah
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
      // Lingkaran titik merah
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
    // Lingkaran abu-abu
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

  // --- WIDGET BANTU UNTUK GARIS KONEKTOR ---
  Widget _buildStepperConnector({
    required bool isCompleted,
    required Color mainColor,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 25.0), // Agar sejajar dgn ikon
        child: Divider(
          color: isCompleted ? mainColor : Colors.grey.shade300,
          thickness: 2,
        ),
      ),
    );
  }

  // --- WIDGET BANTU UNTUK TIMELINE VERTIKAL ---
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
          // Bagian Kiri: Ikon dan Garis
          Container(
            width: 60, // Lebar untuk perataan
            child: Column(
              children: [
                // Ikon
                Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white, // Agar menutupi garis
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 24),
                ),

                // Garis (jika bukan item terakhir)
                if (!isLast)
                  Expanded(child: Container(width: 2, color: greyColor)),
              ],
            ),
          ),

          // Bagian Kanan: Teks
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0, right: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris Tanggal dan Waktu
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
                  // Deskripsi
                  Text(
                    description,
                    style: TextStyle(
                      color: isActive ? Colors.black : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  // Kurir
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
