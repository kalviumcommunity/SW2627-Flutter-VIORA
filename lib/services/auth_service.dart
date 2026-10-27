import 'dart:async';
import 'package:flutter/foundation.dart';
import 'api_client.dart';
import 'token_storage.dart';

/// User VIP Membership Tier
enum MembershipTier { silver, gold, platinum, blackCard }

/// High-fidelity User Identity & Session Model
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? customerId;
  final String? photoUrl;
  final MembershipTier tier;
  final int loyaltyPoints;
  final bool isGuest;
  final DateTime memberSince;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.role = 'customer',
    this.customerId,
    this.photoUrl,
    this.tier = MembershipTier.gold,
    this.loyaltyPoints = 2400,
    this.isGuest = false,
    required this.memberSince,
  });

  String get userInitials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (name.isNotEmpty) {
      return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'VI';
  }

  String get tierName {
    switch (tier) {
      case MembershipTier.silver:
        return 'Silver Privilege';
      case MembershipTier.gold:
        return 'Gold Artisan';
      case MembershipTier.platinum:
        return 'Platinum VIP';
      case MembershipTier.blackCard:
        return 'Maison Black Card';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'customerId': customerId,
      'photoUrl': photoUrl,
      'tier': tier.name,
      'loyaltyPoints': loyaltyPoints,
      'isGuest': isGuest,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: (map['uid'] ?? map['id'] ?? map['_id'] ?? '').toString(),
      name: (map['name'] ?? 'Valued Client').toString(),
      email: (map['email'] ?? '').toString(),
      phone: map['phone']?.toString(),
      role: map['role']?.toString() ?? 'customer',
      customerId: map['customerId']?.toString(),
      photoUrl: map['photoUrl'] as String?,
      tier: MembershipTier.values.firstWhere(
        (t) => t.name == map['tier'],
        orElse: () => MembershipTier.gold,
      ),
      loyaltyPoints: (map['loyaltyPoints'] as num?)?.toInt() ?? 2400,
      isGuest: map['isGuest'] as bool? ?? false,
      memberSince: map['memberSince'] != null
          ? DateTime.tryParse(map['memberSince'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// Authentication Service for VIORA
/// Manages user credentials, backend sessions, and identity state
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _authStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  Stream<UserModel?> get authStateChanges => _authStreamController.stream;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null && !_currentUser!.isGuest;

  Future<void> init() async {
    final token = await TokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      try {
        final res = await ApiClient().get('/auth/me');
        if (res is Map<String, dynamic> && res['success'] == true && res['user'] != null) {
          final userData = res['user'] as Map<String, dynamic>;
          _currentUser = UserModel.fromMap(userData);
          _authStreamController.add(_currentUser);
          debugPrint('🔑 [AuthService] Restored authenticated session: ${_currentUser?.name} (${_currentUser?.email})');
          return;
        }
      } catch (e) {
        debugPrint('⚠️ [AuthService] Token expired or invalid: $e');
        await TokenStorage.clearToken();
      }
    }

    _currentUser = null;
    _authStreamController.add(null);
    debugPrint('🔑 [AuthService] No active authenticated session (logged out state)');
  }

  /// Sign in with email and password against the backend API
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final res = await ApiClient().post(
      '/auth/login',
      body: {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      includeAuth: false,
    );

    if (res is Map<String, dynamic> && res['success'] == true) {
      final token = res['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }

      final userData = (res['user'] as Map<String, dynamic>?) ?? {};
      final user = UserModel(
        uid: (userData['id'] ?? userData['_id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}').toString(),
        name: (userData['name'] ?? email.split('@').first.capitalize()).toString(),
        email: (userData['email'] ?? email).toString(),
        phone: userData['phone']?.toString(),
        role: userData['role']?.toString() ?? 'customer',
        customerId: userData['customerId']?.toString(),
        photoUrl: 'assets/images/avatar_sarah.png',
        tier: MembershipTier.gold,
        loyaltyPoints: 2400,
        memberSince: DateTime.now(),
      );

      _currentUser = user;
      _authStreamController.add(user);
      debugPrint('🔑 [AuthService] Signed in via backend API: ${user.email} (${user.name})');
      return user;
    }

    throw ApiException(
      statusCode: 400,
      message: res is Map && res['message'] != null ? res['message'].toString() : 'Authentication failed',
    );
  }

  /// Register new user and customer profile via backend API
  Future<UserModel> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    String? phone,
    String role = 'customer',
  }) async {
    final res = await ApiClient().post(
      '/auth/register',
      body: {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
        'phone': phone?.trim() ?? '',
        'role': role,
      },
      includeAuth: false,
    );

    if (res is Map<String, dynamic> && res['success'] == true) {
      final token = res['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await TokenStorage.saveToken(token);
      }

      final userData = (res['user'] as Map<String, dynamic>?) ?? {};
      final user = UserModel(
        uid: (userData['id'] ?? userData['_id'] ?? 'user_${DateTime.now().millisecondsSinceEpoch}').toString(),
        name: (userData['name'] ?? name).toString(),
        email: (userData['email'] ?? email).toString(),
        phone: userData['phone']?.toString(),
        role: userData['role']?.toString() ?? role,
        customerId: userData['customerId']?.toString(),
        photoUrl: 'assets/images/avatar_sarah.png',
        tier: MembershipTier.silver,
        loyaltyPoints: 500,
        memberSince: DateTime.now(),
      );

      _currentUser = user;
      _authStreamController.add(user);
      debugPrint('🔑 [AuthService] Registered new member via backend API: ${user.name}');
      return user;
    }

    throw ApiException(
      statusCode: 400,
      message: res is Map && res['message'] != null ? res['message'].toString() : 'Registration failed',
    );
  }

  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = UserModel(
      uid: 'google_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Victoria Saint-Laurent',
      email: 'victoria.stl@gmail.com',
      photoUrl: 'assets/images/avatar_jessica.png',
      tier: MembershipTier.platinum,
      loyaltyPoints: 5200,
      memberSince: DateTime(2023, 6, 20),
    );

    _currentUser = user;
    _authStreamController.add(user);
    return user;
  }

  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 400));
    final user = UserModel(
      uid: 'apple_user_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Elena Rostova',
      email: 'elena.rostova@icloud.com',
      photoUrl: 'assets/images/avatar_sophia.png',
      tier: MembershipTier.blackCard,
      loyaltyPoints: 12400,
      memberSince: DateTime(2022, 11, 10),
    );

    _currentUser = user;
    _authStreamController.add(user);
    return user;
  }

  Future<void> signOut() async {
    await TokenStorage.clearToken();
    _currentUser = null;
    _authStreamController.add(null);
    debugPrint('🔑 [AuthService] User signed out and token cleared');
  }

  void continueAsGuest() {
    _currentUser = UserModel(
      uid: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Guest Client',
      email: 'guest@viora.com',
      isGuest: true,
      tier: MembershipTier.silver,
      loyaltyPoints: 0,
      memberSince: DateTime.now(),
    );
    _authStreamController.add(_currentUser);
  }

  void dispose() {
    _authStreamController.close();
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
