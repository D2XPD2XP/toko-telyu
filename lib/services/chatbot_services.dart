import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:toko_telyu/models/product.dart';
import 'package:toko_telyu/models/product_category.dart';

class ChatbotService {
  final String apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
  late GenerativeModel model;
  late ChatSession chat;

  ChatbotService() {
    model = GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: apiKey);
    chat = model.startChat();
  }

  String productListToString(List<Product> products) {
    return products
        .map(
          (p) =>
              """
Nama: ${p.productName}
Kategori: ${p.category.categoryName}
Harga: Rp ${p.price}
Deskripsi: ${p.description}
""",
        )
        .join("\n");
  }

  String productCategoryListToString(List<ProductCategory> categories) {
    return categories.map((c) => "- ${c.categoryName}").join("\n");
  }

  Future<String> sendMessage(
    String message,
    List<Product> products,
    List<ProductCategory> categories,
  ) async {
    String templateAnswer =
        "Jawablah dengan Format satu paragraf to the point 9namun tetap ramah dan penggunaan emoticon dibolehkan. Jawab dengan format yang rapih juga dan kurangi penggunaan \"*\" (bintang) dan jika memang akan menampilkan daftar, gunakan \"-\". Jika pertanyaan tidak berhubungan dengan TOKO TELYU atau bahkan E-commerce, jawab dengan 'Maaf, saya hanya dapat membantu pertanyaan yang berhubungan dengan TOKO TELYU.'. Jika pertanyaan tidak dimengerti, jawab dengan 'Maaf, saya tidak mengerti pertanyaan Anda. Silakan ajukan pertanyaan lain.'";
    final response = await chat.sendMessage(
      Content.text(
        "Anda adalah TOKTEL AI dari aplikasi E-commerce TOKO TELYU untuk menggantikan customer service. Aturan anda adalah $templateAnswer. Kategori produk yang tersedia adalah:\n${productCategoryListToString(categories)}\nDaftar produk yang tersedia adalah:\n${productListToString(products)}\nPrompt utamanya adalah: $message. .",
      ),
    );
    return response.text ?? "Tidak ada respons";
  }
}
