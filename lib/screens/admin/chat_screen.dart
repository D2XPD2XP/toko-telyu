import 'package:flutter/material.dart';
import 'chat_room_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Color primaryColor = const Color(0xFFED1E28);
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> chatRooms = const [
    {
      "customerName": "Budi Santoso",
      "lastMessage": "Apakah stok tersedia?",
      "unread": 2,
      "time": "14:21",
    },
    {
      "customerName": "Siti Aminah",
      "lastMessage": "Terima kasih!",
      "unread": 0,
      "time": "09:02",
    },
    {
      "customerName": "Agus Wijaya",
      "lastMessage": "Kapan pesanan saya dikirim?",
      "unread": 1,
      "time": "Kemarin",
    },
  ];

  List<Map<String, dynamic>> get _filteredChatRooms {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) return chatRooms;

    return chatRooms.where((room) {
      final name = (room["customerName"] ?? "").toLowerCase();
      return name.contains(query);
    }).toList();
  }

  // ===================================================================
  //  Widget: Search Bar
  // ===================================================================
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Cari customer...",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 16,
          ),
        ),
      ),
    );
  }

  // ===================================================================
  //  Widget: Chat List Item
  // ===================================================================
  Widget _buildChatItem(Map<String, dynamic> room) {
    final String name = room["customerName"] ?? "";
    final String initial = name.isNotEmpty ? name[0] : "?";
    final String lastMessage = room["lastMessage"] ?? "(Tidak ada pesan)";
    final int unread = room["unread"] ?? 0;
    final String time = room["time"] ?? "";

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ChatRoomScreen(customerName: name)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),

        // ========================================================
        // Chat Row
        // ========================================================
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: primaryColor.withOpacity(0.15),
              child: Text(
                initial,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + Last Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    lastMessage,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Time + Unread Badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 6),
                if (unread > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ===================================================================
  //  Build Main UI
  // ===================================================================
  @override
  Widget build(BuildContext context) {
    final rooms = _filteredChatRooms;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Chats",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.8,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 16),

            Expanded(
              child: rooms.isEmpty
                  ? const Center(child: Text("Tidak ada chat ditemukan"))
                  : ListView.builder(
                      itemCount: rooms.length,
                      itemBuilder: (_, i) => _buildChatItem(rooms[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
