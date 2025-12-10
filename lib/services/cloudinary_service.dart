import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  /// Upload image to Cloudinary
  /// Throws an Exception if upload fails
  static Future<String> uploadImage(File file) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];

    if (cloudName == null || preset == null) {
      throw Exception(
        "Cloudinary config not found. Make sure .env has CLOUDINARY_CLOUD_NAME and CLOUDINARY_UPLOAD_PRESET",
      );
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..fields['folder'] = 'tokotelyu'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Cloudinary upload failed: $responseBody");
    }

    final secureUrl = RegExp(
      r'"secure_url":"(.*?)"',
    ).firstMatch(responseBody)?.group(1);

    if (secureUrl == null) {
      throw Exception("secure_url not found in response: $responseBody");
    }

    final cleanUrl = secureUrl.replaceAll(r'\/', '/');

    return cleanUrl;
  }

  static String extractPublicId(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final segments = uri.pathSegments;

    final uploadIndex = segments.indexOf('upload');
    final publicIdParts = segments.sublist(uploadIndex + 2);

    final fileName = publicIdParts.last.split('.').first;
    publicIdParts[publicIdParts.length - 1] = fileName;

    return publicIdParts.join('/');
  }

  static Future<void> deleteImage(String imageUrl) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
    final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];

    if (cloudName == null || apiKey == null || apiSecret == null) {
      throw Exception("Cloudinary delete config missing");
    }

    final publicId = extractPublicId(imageUrl);

    final url = Uri.parse(
      "https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload",
    );

    final basicAuth =
        'Basic ${base64Encode(utf8.encode('$apiKey:$apiSecret'))}';

    final request = http.Request("DELETE", url);
    request.headers["Authorization"] = basicAuth;

    request.bodyFields = {"public_ids[]": publicId};

    final streamed = await request.send();
    final response = await streamed.stream.bytesToString();

    if (streamed.statusCode != 200) {
      throw Exception("Failed to delete image: $response");
    }

    if (response.contains('"not_found"')) {
      print("Cloudinary: image not found → $publicId");
      return;
    }
  }
}
