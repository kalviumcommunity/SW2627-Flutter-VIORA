import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/core/theme/app_colors.dart';
import 'package:viora_salon_app/models/hair_service.dart';
import 'package:viora_salon_app/models/nail_service.dart';
import 'package:viora_salon_app/models/stylist.dart';
import 'package:viora_salon_app/services/auth_service.dart';
import 'package:viora_salon_app/services/firestore_service.dart';
import 'package:viora_salon_app/widgets/responsive_web_container.dart';

void main() {
  group('StringExtension Unit Tests', () {
    test('capitalize() capitalizes the first letter of string', () {
      expect('sarah'.capitalize(), 'Sarah');
      expect(''.capitalize(), '');
      expect('jessica.alba'.capitalize(), 'Jessica.alba');
    });
  });

  group('Model and Sample Data Tests', () {
    test('Stylist model contains sample stylists and valid imagePath', () {
      expect(Stylist.sampleStylists.isNotEmpty, isTrue);
      expect(Stylist.sampleStylists[1].imagePath, 'assets/images/avatar_jessica.png');
    });

    test('HairService model contains allHairCuts', () {
      expect(HairService.allHairCuts.isNotEmpty, isTrue);
      expect(HairService.allHairCuts.first.title, 'Layer Cut');
    });

    test('NailService model contains allNailServices', () {
      expect(NailService.allNailServices.isNotEmpty, isTrue);
      expect(NailService.allNailServices.first.title, 'Brown Ombre Cat Eye');
    });
  });

  group('FirestoreService Stream Tests', () {
    test('Streams yield haircut and nail data without errors', () async {
      final firestoreService = FirestoreService();
      final haircuts = await firestoreService.haircutsStream.first;
      final nailServices = await firestoreService.nailServicesStream.first;
      final stylists = await firestoreService.stylistsStream.first;

      expect(haircuts, equals(HairService.allHairCuts));
      expect(nailServices, equals(NailService.allNailServices));
      expect(stylists, equals(Stylist.sampleStylists));
    });
  });

  group('Theme and ResponsiveWebContainer Tests', () {
    test('AppColors contains required tokens', () {
      expect(AppColors.primary, const Color(0xFFC59265));
      expect(AppColors.border, const Color(0xFFEDE8E1));
      expect(AppColors.textSecondary, const Color(0xFF7A7672));
    });

    testWidgets('ResponsiveWebContainer renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveWebContainer(
            child: Text('Test Content'),
          ),
        ),
      );

      expect(find.text('Test Content'), findsOneWidget);
    });
  });
}
