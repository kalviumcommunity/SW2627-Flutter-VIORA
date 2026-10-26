// File generated for VIORA Flutter Web & Mobile Application
// Configured for Firebase Auth, Cloud Firestore, and Firebase Storage.

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase projects.
class DefaultFirebaseOptions {
  static const bool isConfigured = false; // Set to true once Firebase console keys are linked

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey_ReplaceWithYourActualFirebaseApiKey',
    appId: '1:1234567890:web:viora-luxury-salon',
    messagingSenderId: '1234567890',
    projectId: 'viora-luxury-salon',
    authDomain: 'viora-luxury-salon.firebaseapp.com',
    storageBucket: 'viora-luxury-salon.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey_ReplaceWithYourActualAndroidKey',
    appId: '1:1234567890:android:viora-luxury-salon',
    messagingSenderId: '1234567890',
    projectId: 'viora-luxury-salon',
    storageBucket: 'viora-luxury-salon.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDemoKey_ReplaceWithYourActualiOSKey',
    appId: '1:1234567890:ios:viora-luxury-salon',
    messagingSenderId: '1234567890',
    projectId: 'viora-luxury-salon',
    storageBucket: 'viora-luxury-salon.appspot.com',
    iosBundleId: 'com.viora.luxury.salon',
  );
}

/// Firebase options data structure matching standard FlutterFire specification.
class FirebaseOptions {
  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;
  final String? authDomain;
  final String? databaseURL;
  final String? storageBucket;
  final String? measurementId;
  final String? trackingId;
  final String? deepLinkURLScheme;
  final String? androidClientId;
  final String? iosClientId;
  final String? iosBundleId;
  final String? appGroupId;

  const FirebaseOptions({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    this.authDomain,
    this.databaseURL,
    this.storageBucket,
    this.measurementId,
    this.trackingId,
    this.deepLinkURLScheme,
    this.androidClientId,
    this.iosClientId,
    this.iosBundleId,
    this.appGroupId,
  });
}
