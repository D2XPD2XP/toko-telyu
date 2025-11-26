import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/services/network_services.dart';

class ConnectionGuard extends StatelessWidget {
  ConnectionGuard({super.key, required this.child});

  final Widget child;
  final _network = NetworkService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: _network.connectionStatus,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final isOnline = snapshot.data!;

        return Stack(
          children: [
            child,
            if (!isOnline)
              Positioned.fill(
                child: Material(
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 90,
                          color: Color(0xFFED1E28),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "No Internet Connection",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFED1E28),
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "Please check your connection",
                          style: GoogleFonts.poppins(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
