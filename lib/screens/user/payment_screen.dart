import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/screens/user/order_detail_screen.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatefulWidget {
  final String orderId;
  final String transactionToken;
  final String redirectUrl;

  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.transactionToken,
    required this.redirectUrl,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color primaryRed = const Color(0xFFED1E28);
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    bool redirected = false;

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (url.contains("example.com") && !redirected) {
              redirected = true;
              if (!mounted) return;

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: widget.orderId),
                ),
              );
            } else {
              if (mounted && !redirected) setState(() => isLoading = true);
            }
          },
          onPageFinished: (url) {
            if (mounted && !redirected) setState(() => isLoading = false);
          },
          onWebResourceError: (error) {
            if (!redirected) {
              _showError("Failed to load payment page: ${error.description}");
            }
          },
        ),
      );

    _loadPaymentPage();
  }

  void _loadPaymentPage() {
    if (widget.redirectUrl.isEmpty) {
      _showError("Payment URL is invalid");
      return;
    }

    try {
      controller.loadRequest(Uri.parse(widget.redirectUrl));
    } catch (e) {
      _showError("Unexpected error loading payment page");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() => isLoading = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: primaryRed, size: 38),
              const SizedBox(height: 12),
              Text(
                "Payment Error",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "OK",
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading)
              Container(
                color: Colors.white.withValues(alpha: 0.7),
                child: Center(
                  child: CircularProgressIndicator(
                    color: primaryRed,
                    strokeWidth: 3,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
