import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CloudinaryService {
  /// Upload image to Cloudinary
  /// Throws an Exception if upload fails
  static Future<String> uploadImage(File file) async {
    final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME']!;
    final preset = dotenv.env['CLOUDINARY_UPLOAD_PRESET']!;

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = preset
      ..fields['folder'] = 'tokotelyu'
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final jsonString = await response.stream.bytesToString();

    if (response.statusCode != 200) {
      throw Exception("Cloudinary upload failed: $jsonString");
    }

    final data = jsonDecode(jsonString);

    if (data['secure_url'] == null) {
      throw Exception("secure_url missing. Full response: $jsonString");
    }

    return data['secure_url'];
  }

  static String extractPublicId(String imageUrl) {
    final url = Uri.parse(imageUrl);

    final segments = url.pathSegments;
    final uploadIndex = segments.indexOf('upload');

    final parts = segments.sublist(uploadIndex + 2).toList();

    final fileName = parts.last.split('.').first;
    parts[parts.length - 1] = fileName;

    return parts.join('/');
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
      debugPrint("Cloudinary: image not found → $publicId");
      return;
    }
  }
}
