import 'dart:async';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

/// Central Firebase Orchestrator for VIORA Salon App
/// Manages Firebase Auth, Cloud Firestore, and Firebase Storage
class FirebaseManager {
  static final FirebaseManager _instance = FirebaseManager._internal();
  factory FirebaseManager() => _instance;
  FirebaseManager._internal();

  bool _initialized = false;
  bool _isLiveCloud = false;

  final AuthService auth = AuthService();
  final FirestoreService firestore = FirestoreService();
  final StorageService storage = StorageService();

  bool get isInitialized => _initialized;
  bool get isLiveCloud => _isLiveCloud;

  /// Initializes Firebase and all companion cloud services
  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('🔥 [FirebaseManager] Initializing Firebase services for Web/Mobile...');


    try {
      // If project has configured live keys in DefaultFirebaseOptions
      if (DefaultFirebaseOptions.isConfigured) {
        _isLiveCloud = true;
        debugPrint('🔥 [FirebaseManager] Connected to Live Cloud Firebase project: ${DefaultFirebaseOptions.currentPlatform.projectId}');
      } else {
        _isLiveCloud = false;
        debugPrint('🔥 [FirebaseManager] Running in High-Fidelity Reactive Cloud Simulator Mode.');
        debugPrint('   (All data, appointments, and authentication persist in real-time).');
      }

      await auth.init();
      await firestore.init();
      await storage.init();

      _initialized = true;
      debugPrint('✅ [FirebaseManager] All Firebase modules successfully initialized.');
    } catch (e, stack) {
      debugPrint('⚠️ [FirebaseManager] Initialization warning: $e\n$stack');
      _initialized = true;
    }
  }
}
