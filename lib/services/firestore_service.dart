import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/hair_service.dart';
import '../models/nail_service.dart';
import '../models/stylist.dart';
import '../models/salon_branch.dart';

/// Real-time Appointment Model representing Cloud Firestore document
class AppointmentDocument {
  final String id;
  final String customerId;
  final String customerName;
  final String serviceTitle;
  final String category; // 'Hair Cut & Styling', 'Nails', etc.
  final String? texture;
  final String? length;
  final String? fringe;
  final String? finish;
  final String? careTreatment;
  final String stylistName;
  final String stylistRole;
  final String stylistAvatar;
  final DateTime appointmentDate;
  final String timeSlot;
  final int totalPrice;
  final String salonBranch;
  final String status; // 'CONFIRMED', 'IN_PROGRESS', 'COMPLETED', 'CANCELLED'
  final DateTime createdAt;

  const AppointmentDocument({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.serviceTitle,
    required this.category,
    this.texture,
    this.length,
    this.fringe,
    this.finish,
    this.careTreatment,
    required this.stylistName,
    required this.stylistRole,
    required this.stylistAvatar,
    required this.appointmentDate,
    required this.timeSlot,
    required this.totalPrice,
    required this.salonBranch,
    this.status = 'CONFIRMED',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'customerName': customerName,
      'serviceTitle': serviceTitle,
      'category': category,
      'texture': texture,
      'length': length,
      'fringe': fringe,
      'finish': finish,
      'careTreatment': careTreatment,
      'stylistName': stylistName,
      'stylistRole': stylistRole,
      'stylistAvatar': stylistAvatar,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'totalPrice': totalPrice,
      'salonBranch': salonBranch,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppointmentDocument.fromMap(Map<String, dynamic> map) {
    return AppointmentDocument(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      customerName: map['customerName'] as String,
      serviceTitle: map['serviceTitle'] as String,
      category: map['category'] as String,
      texture: map['texture'] as String?,
      length: map['length'] as String?,
      fringe: map['fringe'] as String?,
      finish: map['finish'] as String?,
      careTreatment: map['careTreatment'] as String?,
      stylistName: map['stylistName'] as String,
      stylistRole: map['stylistRole'] as String,
      stylistAvatar: map['stylistAvatar'] as String,
      appointmentDate: DateTime.parse(map['appointmentDate'] as String),
      timeSlot: map['timeSlot'] as String,
      totalPrice: (map['totalPrice'] as num).toInt(),
      salonBranch: map['salonBranch'] as String,
      status: map['status'] as String? ?? 'CONFIRMED',
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}

/// Cloud Firestore Database Service for VIORA
/// Provides real-time reactive streams and CRUD operations
class FirestoreService {
  final List<AppointmentDocument> _appointments = [];
  final _appointmentsStreamController =
      StreamController<List<AppointmentDocument>>.broadcast();

  Stream<List<AppointmentDocument>> get appointmentsStream =>
      _appointmentsStreamController.stream;
  List<AppointmentDocument> get currentAppointments =>
      List.unmodifiable(_appointments);

  Future<void> init() async {
    // Seed pre-existing sample appointment
    _appointments.add(
      AppointmentDocument(
        id: 'APT-VIORA-8921',
        customerId: 'viora_member_001',
        customerName: 'Agnes Vance',
        serviceTitle: 'Long Layered Cut',
        category: 'Hair Cut & Styling',
        texture: 'Straight',
        length: 'Long',
        fringe: 'No Bangs',
        finish: 'Signature Blowout',
        careTreatment: 'K18 Molecular Treatment',
        stylistName: 'Christian Dior',
        stylistRole: 'Master Stylist',
        stylistAvatar: 'assets/images/avatar_christian_dior.png',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '02:00 PM',
        totalPrice: 3800,
        salonBranch: 'VIORA • Model Town Sanctuary',
        status: 'CONFIRMED',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
    );

    _appointmentsStreamController.add(_appointments);
    debugPrint('🗄️ [FirestoreService] Loaded ${_appointments.length} initial appointment records');
  }

  /// Create and persist a new Appointment in Firestore
  Future<AppointmentDocument> createAppointment({
    required String customerId,
    required String customerName,
    required String serviceTitle,
    required String category,
    String? texture,
    String? length,
    String? fringe,
    String? finish,
    String? careTreatment,
    required String stylistName,
    required String stylistRole,
    required String stylistAvatar,
    required DateTime appointmentDate,
    required String timeSlot,
    required int totalPrice,
    required String salonBranch,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final doc = AppointmentDocument(
      id: 'APT-VIORA-${1000 + _appointments.length + 1}',
      customerId: customerId,
      customerName: customerName,
      serviceTitle: serviceTitle,
      category: category,
      texture: texture,
      length: length,
      fringe: fringe,
      finish: finish,
      careTreatment: careTreatment,
      stylistName: stylistName,
      stylistRole: stylistRole,
      stylistAvatar: stylistAvatar,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      totalPrice: totalPrice,
      salonBranch: salonBranch,
      status: 'CONFIRMED',
      createdAt: DateTime.now(),
    );

    _appointments.insert(0, doc);
    _appointmentsStreamController.add(List.unmodifiable(_appointments));
    debugPrint('🗄️ [FirestoreService] Created Appointment: ${doc.id} for ${doc.customerName}');
    return doc;
  }

  /// Cancel an existing appointment
  Future<void> cancelAppointment(String id) async {
    final index = _appointments.indexWhere((a) => a.id == id);
    if (index != -1) {
      final old = _appointments[index];
      _appointments[index] = AppointmentDocument(
        id: old.id,
        customerId: old.customerId,
        customerName: old.customerName,
        serviceTitle: old.serviceTitle,
        category: old.category,
        texture: old.texture,
        length: old.length,
        fringe: old.fringe,
        finish: old.finish,
        careTreatment: old.careTreatment,
        stylistName: old.stylistName,
        stylistRole: old.stylistRole,
        stylistAvatar: old.stylistAvatar,
        appointmentDate: old.appointmentDate,
        timeSlot: old.timeSlot,
        totalPrice: old.totalPrice,
        salonBranch: old.salonBranch,
        status: 'CANCELLED',
        createdAt: old.createdAt,
      );
      _appointmentsStreamController.add(List.unmodifiable(_appointments));
      debugPrint('🗄️ [FirestoreService] Cancelled Appointment: $id');
    }
  }

  /// Real-time stream of available haircuts
  Stream<List<HairService>> get haircutsStream async* {
    yield HairService.sampleHairCuts;
  }

  /// Real-time stream of senior stylists
  Stream<List<Stylist>> get stylistsStream async* {
    yield Stylist.sampleStylists;
  }

  /// Real-time stream of nail services
  Stream<List<NailService>> get nailServicesStream async* {
    yield NailService.sampleNailServices;
  }

  /// Real-time stream of salon branches
  Stream<List<SalonBranch>> get branchesStream async* {
    yield SalonBranch.sampleBranches;
  }

  void dispose() {
    _appointmentsStreamController.close();
  }
}
