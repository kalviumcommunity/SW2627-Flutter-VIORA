import 'dart:async';
import 'package:flutter/foundation.dart';

/// User VIP Membership Tier
enum MembershipTier { silver, gold, platinum, blackCard }

/// High-fidelity User Identity & Session Model
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final MembershipTier tier;
  final int loyaltyPoints;
  final bool isGuest;
  final DateTime memberSince;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.tier = MembershipTier.gold,
    this.loyaltyPoints = 2400,
    this.isGuest = false,
    required this.memberSince,
  });

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
      'photoUrl': photoUrl,
      'tier': tier.name,
      'loyaltyPoints': loyaltyPoints,
      'isGuest': isGuest,
      'memberSince': memberSince.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      photoUrl: map['photoUrl'] as String?,
      tier: MembershipTier.values.firstWhere(
        (t) => t.name == map['tier'],
        orElse: () => MembershipTier.gold,
      ),
      loyaltyPoints: (map['loyaltyPoints'] as num?)?.toInt() ?? 2400,
      isGuest: map['isGuest'] as bool? ?? false,
      memberSince: map['memberSince'] != null
          ? DateTime.parse(map['memberSince'] as String)
          : DateTime.now(),
    );
  }
}

/// Firebase Auth Service for VIORA
/// Manages user credentials, authentication sessions, and social logins
class AuthService {
  final _authStreamController = StreamController<UserModel?>.broadcast();
  UserModel? _currentUser;

  Stream<UserModel?> get authStateChanges => _authStreamController.stream;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    // Default logged in user for immediate interactive experience
    _currentUser = UserModel(
      uid: 'viora_member_001',
      name: 'Agnes Vance',
      email: 'agnes.vance@viora-luxury.com',
      photoUrl: 'assets/images/avatar_sarah.png',
      tier: MembershipTier.gold,
      loyaltyPoints: 3850,
      memberSince: DateTime(2024, 1, 15),
    );
    _authStreamController.add(_currentUser);
    debugPrint('🔐 [AuthService] Initialized user: ${_currentUser?.name} (${_currentUser?.email})');
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: email.split('@').first.capitalize(),
      email: email,
      photoUrl: 'assets/images/avatar_sophia.png',
      tier: MembershipTier.gold,
      loyaltyPoints: 2400,
      memberSince: DateTime.now(),
    );

    _currentUser = user;
    _authStreamController.add(user);
    debugPrint('🔐 [AuthService] Signed in: ${user.email}');
    return user;
  }

  Future<UserModel> createUserWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final user = UserModel(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      photoUrl: 'assets/images/avatar_sarah.png',
      tier: MembershipTier.silver,
      loyaltyPoints: 500, // Welcome points
      memberSince: DateTime.now(),
    );

    _currentUser = user;
    _authStreamController.add(user);
    debugPrint('🔐 [AuthService] Registered new member: ${user.name}');
    return user;
  }

  Future<UserModel> signInWithGoogle() async {
    await Future.delayed(const Duration(milliseconds: 800));
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
    debugPrint('🔐 [AuthService] Google Sign-In: ${user.name}');
    return user;
  }

  Future<UserModel> signInWithApple() async {
    await Future.delayed(const Duration(milliseconds: 800));
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
    debugPrint('🔐 [AuthService] Apple Sign-In: ${user.name}');
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    _authStreamController.add(null);
    debugPrint('🔐 [AuthService] User signed out');
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
    debugPrint('🔐 [AuthService] Continued as Guest');
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
