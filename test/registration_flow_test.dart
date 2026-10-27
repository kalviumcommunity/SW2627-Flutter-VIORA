import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:viora_salon_app/screens/sign_in_screen.dart';
import 'package:viora_salon_app/services/api_client.dart';
import 'package:viora_salon_app/services/auth_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AuthService().signOut();
  });

  group('Registration Flow & Loading State Unit & Widget Tests', () {
    test('1. Successful registration parses token, user profile, and customerId', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/register')) {
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['name'], 'Aria Montgomery');
          expect(body['email'], 'aria.montgomery@viora.com');
          expect(body['password'], 'secret123');

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'User registered successfully',
              'token': 'mock_jwt_token_aria_2026',
              'user': {
                'id': 'user_aria_001',
                'name': 'Aria Montgomery',
                'email': 'aria.montgomery@viora.com',
                'phone': '+91 98200 11111',
                'role': 'customer',
                'customerId': 'CUST-0099',
              }
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      ApiClient().httpClient = mockClient;

      final user = await AuthService().createUserWithEmailAndPassword(
        name: 'Aria Montgomery',
        email: 'aria.montgomery@viora.com',
        password: 'secret123',
        phone: '+91 98200 11111',
      );

      expect(user.name, 'Aria Montgomery');
      expect(user.email, 'aria.montgomery@viora.com');
      expect(user.customerId, 'CUST-0099');
      expect(AuthService().isAuthenticated, isTrue);
      expect(AuthService().currentUser?.email, 'aria.montgomery@viora.com');
    });

    test('2. Duplicate email registration throws ApiException with 400 and backend message', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/register')) {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'A user with this email already exists',
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      ApiClient().httpClient = mockClient;

      expect(
        () async => await AuthService().createUserWithEmailAndPassword(
          name: 'Existing User',
          email: 'duplicate@viora.com',
          password: 'secretpassword123',
        ),
        throwsA(isA<ApiException>().having(
          (e) => e.message,
          'message',
          'A user with this email already exists',
        )),
      );

      expect(AuthService().isAuthenticated, isFalse);
    });

    test('3. Timeout exception produces ApiException(408) without hanging', () async {
      final mockClient = MockClient((request) async {
        await Future.delayed(const Duration(milliseconds: 100));
        throw TimeoutException('Connection timed out');
      });

      ApiClient().httpClient = mockClient;
      ApiClient().requestTimeout = const Duration(milliseconds: 50);

      expect(
        () async => await ApiClient().post('/auth/register', body: {'test': true}),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'statusCode', 408)),
      );

      ApiClient().requestTimeout = const Duration(seconds: 8);
    });

    testWidgets('4. Registration form validates fields before submission', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to sign up mode
      final createAccountTabButton = find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT');
      expect(createAccountTabButton, findsOneWidget);
      await tester.tap(createAccountTabButton);
      await tester.pumpAndSettle();

      expect(find.text('FULL NAME'), findsOneWidget);
      expect(find.text('PHONE NUMBER (OPTIONAL)'), findsOneWidget);

      // Clear email and submit to trigger validation
      final emailField = find.widgetWithText(TextField, 'sarah.kothari@gmail.com');
      if (emailField.evaluate().isNotEmpty) {
        await tester.enterText(emailField, '');
      }

      // Submit Create Account
      final submitButton = find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
    });

    testWidgets('5. Loading state resets to false and displays error on registration failure', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/auth/register')) {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'A user with this email already exists',
            }),
            400,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      ApiClient().httpClient = mockClient;

      await tester.pumpWidget(
        const MaterialApp(
          home: SignInScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Create Account mode
      await tester.tap(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'));
      await tester.pumpAndSettle();

      // Fill in valid details with the duplicate email
      final textFields = find.byType(TextField);
      expect(textFields, findsNWidgets(4)); // Name, Email, Phone, Password

      await tester.enterText(textFields.at(0), 'Duplicate User');
      await tester.enterText(textFields.at(1), 'duplicate@viora.com');
      await tester.enterText(textFields.at(3), 'secretpassword123');

      final submitBtn = find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT');
      await tester.ensureVisible(submitBtn);
      await tester.tap(submitBtn);
      await tester.pump(); // Start request

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();

      // Error message must be rendered
      expect(find.text('A user with this email already exists'), findsAtLeastNWidgets(1));

      // Button must be back to 'CREATE ACCOUNT' (not stuck spinning)
      expect(find.widgetWithText(ElevatedButton, 'CREATE ACCOUNT'), findsOneWidget);
    });

    testWidgets('6. Guest access persists and bypasses backend requirements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          routes: {
            '/home': (context) => const Scaffold(body: Text('Home Screen View')),
          },
          home: const SignInScreen(),
        ),
      );
      await tester.pumpAndSettle();

      final guestBtn = find.text('Continue as Guest');
      expect(guestBtn, findsOneWidget);
      await tester.tap(guestBtn);
      await tester.pumpAndSettle();

      expect(AuthService().currentUser?.isGuest, isTrue);
      expect(AuthService().currentUser?.name, 'Guest Client');
      expect(find.text('Home Screen View'), findsOneWidget);
    });
  });
}