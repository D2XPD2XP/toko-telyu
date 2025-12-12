import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';
import 'package:toko_telyu/models/user.dart';
import 'package:toko_telyu/screens/user/customer_service_chat_screen.dart';
import 'package:toko_telyu/services/chatbot_services.dart';
import 'package:toko_telyu/services/product_category_services.dart';
import 'package:toko_telyu/services/product_services.dart';
import 'package:toko_telyu/services/user_services.dart';
import 'package:toko_telyu/widgets/customer_service_button.dart';
import 'package:toko_telyu/widgets/chatbot_initial_menu.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final UserService _userService = UserService();
  final ProductService _productService = ProductService();
  final ProductCategoryService _productCategoryService =
      ProductCategoryService();
  final ChatbotService _chatbotService = ChatbotService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final Color primaryRed = const Color(0xFFED1E28);
  User? user;
  List<Product>? products;
  List<ProductCategory>? categories;
  bool isLoading = false;
  bool isLoadResponse = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });
    user = await _userService.loadUser();
    categories = await _productCategoryService.getCategories();
    products = await _productService.getAllProducts(categories!);
    setState(() {
      isLoading = false;
    });
  }

  final List<Map<String, dynamic>> _chatItems = [
    {"type": "initial_menu"},
  ];

  void _handleSend() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _chatItems.add({"type": "text", "isUser": true, "content": text});
      _controller.clear();
    });

    _scrollToBottom();
    setState(() {
      isLoadResponse = true;
    });
    await _handlerResponse(text, products!, categories!);
    setState(() {
      isLoadResponse = false;
    });
  }

  Future<void> _handlerResponse(
    String text,
    List<Product> products,
    List<ProductCategory> categories,
  ) async {
    String response;
    try {
      response = await _chatbotService.sendMessage(text, products, categories);
    } catch (e) {
      response = "Gagal mendapatkan respons dari bot. Error: $e";
    }
    setState(() {
      _chatItems.add({"type": "text", "isUser": false, "content": response});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFED1E28)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE5E5E5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Icon(Icons.headset_mic, color: Colors.black, size: 28),
            const SizedBox(width: 10),
            Text(
              "TOKTEL AI",
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _chatItems.length + 1 + (isLoadResponse ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Center(
                      child: Text(
                        "Today",
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }

                if (isLoadResponse && index == _chatItems.length + 1) {
                  return _buildTextBubble(text: "Typing...", isUser: false);
                }

                final item = _chatItems[index - 1];

                if (item["type"] == "initial_menu") {
                  return ChatbotInitialMenu(
                    username: user!.name,
                    onFaqTap: (text) {
                      _controller.text = text;
                      _handleSend();
                    },
                  );
                } else if (item["type"] == "text") {
                  return _buildTextBubble(
                    text: item["content"],
                    isUser: item["isUser"],
                  );
                } else if (item["type"] == "cs_card") {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      CustomerServiceButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const CustomerServiceChatScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.black87,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSend(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _handleSend,
                  child: Icon(Icons.send_rounded, color: primaryRed, size: 30),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? primaryRed : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser
                ? const Radius.circular(16)
                : const Radius.circular(0),
            bottomRight: isUser
                ? const Radius.circular(0)
                : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isUser ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
