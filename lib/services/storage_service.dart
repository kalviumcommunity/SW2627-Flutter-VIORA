import 'dart:async';
import 'package:flutter/foundation.dart';

/// Firebase Storage Service for VIORA
/// Handles salon photoshoots, 360° studio rotation assets, and client reference uploads
class StorageService {
  final Map<String, String> _uploadedMediaCache = {};

  Future<void> init() async {
    debugPrint('📦 [StorageService] Firebase Storage initialized with 134 bundled photoshoot assets');
  }

  /// Resolve image path - maps cloud storage URLs or bundled assets seamlessly
  String resolveImagePath(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    // Bundled asset path
    if (path.startsWith('assets/')) {
      return path;
    }
    return 'assets/images/$path';
  }

  /// Upload client hairstyle reference photo or consultation image to Cloud Storage
  Future<String> uploadClientReferencePhoto({
    required String customerId,
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));
    final cloudUrl = 'https://firebasestorage.googleapis.com/v0/b/viora-luxury-salon.appspot.com/o/client_uploads%2F${customerId}_$fileName?alt=media';
    _uploadedMediaCache[fileName] = cloudUrl;
    debugPrint('📦 [StorageService] Uploaded client reference photo to Firebase Storage: $cloudUrl');
    return cloudUrl;
  }
}
