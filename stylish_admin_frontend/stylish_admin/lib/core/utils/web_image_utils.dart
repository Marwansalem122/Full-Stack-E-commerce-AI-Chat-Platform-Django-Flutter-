import 'dart:convert';
import 'dart:typed_data';

class WebImageUtils {
  static const int MAX_IMAGE_SIZE = 2 * 1024 * 1024;

  /// Validates an image file size
  static bool validateImageSize(Uint8List bytes) {
    return bytes.length <= MAX_IMAGE_SIZE;
  }

  /// Encodes bytes to a data URL with proper mime type
  static String encodeToDataUrl(Uint8List bytes, String mimeType) {
    final base64String = base64Encode(bytes);

    return 'data:$mimeType;base64,$base64String';
  }

  /// Extracts mime type from a data URL
  static String? extractMimeTypeFromDataUrl(String dataUrl) {
    final RegExp mimeTypeRegex = RegExp(r'data:(.*?);base64,');
    final match = mimeTypeRegex.firstMatch(dataUrl);
    return match?.group(1);
  }

  /// Extracts base64 data from a data URL
  static String extractBase64FromDataUrl(String dataUrl) {
    final parts = dataUrl.split(';base64,');
    return parts.length > 1 ? parts[1] : '';
  }

  /// Extracts bytes from a data URL
  static Uint8List extractBytesFromDataUrl(String dataUrl) {
    final base64Data = extractBase64FromDataUrl(dataUrl);
    return base64Decode(base64Data);
  }

  /// Prepares images for multipart upload
  /// Returns a list of image data maps ready for backend upload
  static List<Map<String, dynamic>> prepareImagesForUpload({
    required List<String> imageUrls,
    required List<bool> isPrimaryFlags,
    required String productName,
  }) {
    final List<Map<String, dynamic>> preparedImages = [];

    for (int i = 0; i < imageUrls.length; i++) {
      final String imageUrl = imageUrls[i];
      final bool isPrimary = isPrimaryFlags[i];

      if (imageUrl.startsWith('data:')) {
        final String? mimeType = extractMimeTypeFromDataUrl(imageUrl);
        if (mimeType == null) continue;

        final String fileExtension = mimeType.split('/').last;
        final String fileName = 'product_image_${i + 1}.$fileExtension';

        preparedImages.add({
          'data': imageUrl,
          'name': fileName,
          'is_primary': isPrimary,
          'order': i,
          'alt_text': '$fileName - $productName',
          'mime_type': mimeType,
        });
      }
    }
    return preparedImages;
  }
}
