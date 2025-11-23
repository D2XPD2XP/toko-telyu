import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatRoomScreen extends StatefulWidget {
  final String customerName;
  const ChatRoomScreen({super.key, required this.customerName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final Color primaryColor = const Color(0xFFED1E28);
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> _messages = [
    {
      "sender": "customer",
      "text": "Halo, apakah stok tersedia?",
      "time": "10:00",
      "read": true,
    },
    {
      "sender": "admin",
      "text": "Halo, stok masih tersedia.",
      "time": "10:01",
      "read": true,
    },
    {
      "sender": "customer",
      "text": "Terima kasih!",
      "time": "10:02",
      "read": false,
    },
  ];

  // ============================================================
  //  SEND MESSAGE
  // ============================================================
  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({
        "sender": "admin",
        "text": text,
        "time": DateFormat('HH:mm').format(DateTime.now()),
        "read": false,
      });
      _controller.clear();
    });

    Future.delayed(
      const Duration(milliseconds: 100),
      () =>
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent),
    );
  }

  // ============================================================
  //  CHAT BUBBLE WIDGET
  // ============================================================
  Widget _chatBubble(Map<String, dynamic> msg) {
    final bool isAdmin = msg["sender"] == "admin";

    return Align(
      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isAdmin ? primaryColor : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isAdmin ? 14 : 0),
            bottomRight: Radius.circular(isAdmin ? 0 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg["text"],
              style: TextStyle(
                color: isAdmin ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 5),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  msg["time"],
                  style: TextStyle(
                    fontSize: 10,
                    color: isAdmin ? Colors.white70 : Colors.grey[600],
                  ),
                ),
                if (isAdmin) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg["read"] ? Icons.done_all : Icons.done,
                    size: 14,
                    color: msg["read"] ? Colors.white : Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  INPUT BAR WIDGET
  // ============================================================
  Widget _chatInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Tulis pesan...",
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: primaryColor,
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  APP BAR WIDGET
  // ============================================================
  AppBar _customAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.8,
      leading: const BackButton(color: Colors.black),
      titleSpacing: 0,
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: primaryColor.withOpacity(0.15),
            child: Text(
              widget.customerName[0],
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.customerName,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  MAIN UI BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _customAppBar(),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (_, index) => _chatBubble(_messages[index]),
            ),
          ),
          _chatInputBar(),
        ],
      ),
    );
  }
}
