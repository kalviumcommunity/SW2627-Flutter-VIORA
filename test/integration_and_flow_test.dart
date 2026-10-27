import 'package:viora_salon_app/screens/my_appointments_screen.dart';
import 'package:viora_salon_app/screens/customer_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/models/salon_branch.dart';
import 'package:viora_salon_app/models/stylist.dart';
import 'package:viora_salon_app/services/api_client.dart';
import 'package:viora_salon_app/services/auth_service.dart';
import 'package:viora_salon_app/services/branch_service.dart';
import 'package:viora_salon_app/screens/sign_in_screen.dart';
import 'package:viora_salon_app/screens/branches_list_screen.dart';
import 'package:viora_salon_app/screens/booking_confirmed_screen.dart';

void main() {
  group('1. ApiClient & ApiException Unit Tests', () {
    test('ApiException captures message and statusCode', () {
      final ex = ApiException(
        statusCode: 401,
        message: 'Invalid email or password',
      );
      expect(ex.message, 'Invalid email or password');
      expect(ex.statusCode, 401);
      expect(ex.toString(), contains('401'));
      expect(ex.toString(), contains('Invalid email or password'));
    });

    test('ApiClient singleton configuration', () {
      final client1 = ApiClient();
      final client2 = ApiClient();
      expect(identical(client1, client2), isTrue);
      expect(client1.baseUrl, anyOf('http://localhost:5000/api', 'http://10.0.2.2:5000/api'));
    });
  });

  group('2. AuthService State & Model Tests', () {
    test('AuthService initial state is unauthenticated', () {
      final auth = AuthService();
      expect(auth.currentUser, isNull);
      expect(auth.isAuthenticated, isFalse);
    });

    test('UserModel instantiation and getters', () {
      final user = UserModel(
        uid: 'user_123',
        name: 'Sarah Kothari',
        email: 'sarah.kothari@gmail.com',
        phone: '+91 98200 12345',
        role: 'customer',
        memberSince: DateTime(2024, 1, 1),
      );

      expect(user.uid, 'user_123');
      expect(user.name, 'Sarah Kothari');
      expect(user.email, 'sarah.kothari@gmail.com');
      expect(user.tierName, 'Gold Artisan');
      expect(user.isGuest, isFalse);

      final map = user.toMap();
      expect(map['name'], 'Sarah Kothari');
      expect(map['email'], 'sarah.kothari@gmail.com');
    });

    test('AuthService signOut clears state', () async {
      final auth = AuthService();
      await auth.signOut();
      expect(auth.currentUser, isNull);
      expect(auth.isAuthenticated, isFalse);
    });
  });

  group('3. BranchService & SalonBranch Tests', () {
    test('SalonBranch.sampleBranches contains flagship salons', () {
      final branches = SalonBranch.sampleBranches;
      expect(branches.length, greaterThanOrEqualTo(3));

      final names = branches.map((b) => b.name).toList();
      expect(names.any((n) => n.contains('Khar West')), isTrue);
      expect(names.any((n) => n.contains('Juhu')), isTrue);
    });

    test('BranchService fallback returns sample branches on error or empty', () async {
      final service = BranchService();
      final branches = await service.getBranches();
      expect(branches.isNotEmpty, isTrue);
      expect(branches.first.name, isNotEmpty);
      expect(branches.first.address, isNotEmpty);
    });
  });

  group('4. SignInScreen Widget & Validation Tests', () {
    testWidgets('Renders SignInScreen initial elements in Sign In mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );
      await tester.pump();

      expect(find.text('SIGN IN'), findsWidgets);
      expect(find.text('EMAIL ADDRESS'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsOneWidget);
      expect(find.text('Continue as Guest'), findsOneWidget);
    });

    testWidgets('Toggling mode shows Create Account fields (Name, Phone)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );
      await tester.pump();

      final createAccountTab = find.text('CREATE ACCOUNT');
      expect(createAccountTab, findsOneWidget);
      await tester.tap(createAccountTab);
      await tester.pump();

      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('PHONE NUMBER (OPTIONAL)'), findsOneWidget);
      expect(find.text('CREATE ACCOUNT'), findsWidgets);
    });

    testWidgets('Validates empty email on submit', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );
      await tester.pump();

      final emailField = find.widgetWithText(TextField, 'sarah.kothari@gmail.com');
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, '');
      }

      final signInCta = find.widgetWithText(ElevatedButton, 'SIGN IN');
      await tester.tap(signInCta);
      await tester.pump();

      expect(find.text('Please enter your email address'), findsOneWidget);
    });
  });

  group('5. Booking & Confirmation Flow Tests', () {
    testWidgets('BranchesListScreen renders with selected service details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BranchesListScreen(
            selectedServiceTitle: 'Signature Bespoke Styling',
            selectedPrice: 150,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Service: Signature Bespoke Styling'), findsOneWidget);
      expect(find.text('ALL SALONS'), findsOneWidget);
    });

    testWidgets('BookingConfirmedScreen displays preserved booking details', (WidgetTester tester) async {
      final sampleStylist = Stylist.sampleStylists[0];

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmedScreen(
            stylist: sampleStylist,
            lookName: 'Balayage Glow',
            selectedDateString: 'Sat, 14 Oct',
            selectedTimeString: '11:30 AM',
            finalPrice: 140,
            selectedBranchName: 'VIORA · Khar West',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Reservation Requested'), findsOneWidget);
      expect(find.text('Session Reservation — Backend Appointment Sync Pending Sprint 3'), findsOneWidget);
      expect(find.text('VIORA · Khar West'), findsOneWidget);
      expect(find.text('Balayage Glow'), findsOneWidget);
      expect(find.textContaining('14 Oct'), findsOneWidget);
      expect(find.text('₹140'), findsOneWidget);
      expect(find.text('VIEW APPOINTMENTS'), findsOneWidget);
    });
    testWidgets('BookingConfirmedScreen communicates prototype reservation mode without fake DB IDs', (WidgetTester tester) async {
      final sampleStylist = Stylist.sampleStylists[1];

      await tester.pumpWidget(
        MaterialApp(
          home: BookingConfirmedScreen(
            stylist: sampleStylist,
            lookName: 'Layer Cut & Gloss',
            selectedDateString: 'Sun, 15 Oct',
            selectedTimeString: '02:00 PM',
            finalPrice: 180,
            selectedBranchName: 'VIORA · Bandra Heritage',
          ),
        ),
      );
      await tester.pump();

      // Mandated status notice
      expect(find.text('Session Reservation — Backend Appointment Sync Pending Sprint 3'), findsOneWidget);

      // Explains prototype / session mode
      expect(find.textContaining('prototype/session mode and has not been confirmed by the backend database'), findsOneWidget);

      // Verifies preserved selections
      expect(find.text('VIORA · Bandra Heritage'), findsOneWidget);
      expect(find.text('Layer Cut & Gloss'), findsOneWidget);
      expect(find.text('₹180'), findsOneWidget);

      // Verifies absence of fake database claims or fabricated IDs
      expect(find.textContaining('MongoDB ID'), findsNothing);
      expect(find.textContaining('ObjectId('), findsNothing);
    });
  });

  group('6. MyAppointmentsScreen Tests', () {
    testWidgets('Renders segmented tabs (ACTIVE RESERVATIONS, PAST JOURNEYS)', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyAppointmentsScreen(),
        ),
      );
      await tester.pump();

      expect(find.byWidgetPredicate((w) => w is Text && (w.data == 'MY APPOINTMENTS' || w.data == 'My Bookings')), findsOneWidget);
      expect(find.text('ACTIVE RESERVATIONS'), findsOneWidget);
      expect(find.text('PAST JOURNEYS'), findsOneWidget);
    });

    testWidgets('Toggling to PAST JOURNEYS displays completed treatments', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MyAppointmentsScreen(),
        ),
      );
      await tester.pump();

      // Tap PAST JOURNEYS
      final pastTab = find.text('PAST JOURNEYS');
      await tester.tap(pastTab);
      await tester.pump();

      expect(find.text('Signature Haute Coiffure'), findsOneWidget);
      expect(find.text('COMPLETED'), findsWidgets);
      expect(find.text('REBOOK EXPERIENCE'), findsWidgets);
    });
  });

  group('7. CustomerProfileScreen & Journey Tests', () {
    testWidgets('Renders customer profile header and VIP Atelier pass', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CustomerProfileScreen(),
        ),
      );
      await tester.pump();

      expect(find.byWidgetPredicate((w) => w is Text && (w.data == 'CUSTOMER PROFILE' || w.data == 'My Profile')), findsOneWidget);
      expect(find.text('VIORA ATELIER PASS'), findsOneWidget);
      expect(find.text('BEAUTY JOURNEY & DIAGNOSTICS'), findsOneWidget);
      expect(find.text('Hair Texture'), findsOneWidget);
      expect(find.text('RETAKE CONSULTATION QUIZ'), findsOneWidget);
      expect(find.text('COMMUNICATION PREFERENCES'), findsOneWidget);
    });
  });

  group('8. Platform-Adaptive ApiClient Tests', () {
    test('ApiClient provides valid defaultBaseUrl format', () {
      final url = ApiClient.defaultBaseUrl;
      expect(url.startsWith('http://'), isTrue);
      expect(url.endsWith('/api'), isTrue);
    });
  });
}
