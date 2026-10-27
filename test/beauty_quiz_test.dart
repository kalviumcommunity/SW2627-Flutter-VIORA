import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:viora_salon_app/models/beauty_quiz_model.dart';
import 'package:viora_salon_app/services/api_client.dart';
import 'package:viora_salon_app/services/quiz_service.dart';
import 'package:viora_salon_app/screens/beauty_quiz_screen.dart';
import 'package:viora_salon_app/screens/beauty_quiz_result_screen.dart';

void main() {
  setUp(() {
    ApiClient().httpClient = MockClient((request) async {
      final path = request.url.path;

      if (path.endsWith('/customers/quiz/questions')) {
        final data = QuizService.defaultQuizQuestions.map((q) => q.toJson()).toList();
        return http.Response(
          jsonEncode({
            'success': true,
            'count': data.length,
            'data': data,
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      if (path.endsWith('/customers/quiz') && request.method == 'POST') {
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Beauty Quiz submitted and personalized recommendations generated successfully',
            'data': {
              'customerId': 'CUST-TEST',
              'profileArchetype': 'Airy Volume & Sleek Defiance',
              'summary': 'Tailored for 2B Wavy textures with customized root lift.',
              'profileChips': ['Hair: 2B Wavy', 'Skin: Combination', 'Concern: Volume & Lift'],
              'recommendations': {
                'products': [
                  {
                    'productId': 'PROD-H-01',
                    'name': 'Maison Revital Serum',
                    'category': 'Hair',
                    'price': 1200,
                    'formattedPrice': '₹1,200',
                    'imageUrl': 'https://images.unsplash.com/photo-1608248597359-2ff99479b188',
                    'matchReason': 'Restores weightless hydration and smooths cuticle frizz.',
                  }
                ],
                'services': [
                  {
                    'serviceId': 'SERV-01',
                    'name': 'Premium Hair Spa',
                    'category': 'Hair',
                    'duration': 60,
                    'price': 1500,
                    'formattedPrice': 'From ₹1,500',
                    'description': 'Specifically curated for hydration.',
                    'matchReason': 'High priority treatment.',
                  }
                ],
                'stylists': [
                  {
                    'stylistId': 'STYL-01',
                    'name': 'Christian Dior',
                    'rating': 4.95,
                    'experience': 10,
                    'branchName': 'Khar West Flagship',
                  }
                ]
              },
              'retakeCount': 0
            }
          }),
          201,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }

      return http.Response('{"success": true}', 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });
  });

  tearDown(() {
    ApiClient().httpClient = http.Client();
  });

  group('1 & 2. Beauty Quiz Model & Loading Tests', () {
    test('QuizQuestion and QuizOption parse accurately from JSON', () {
      final json = {
        'id': 'hairType',
        'title': 'What is your hair texture & type?',
        'subtitle': 'Select the closest description',
        'stepNumber': 1,
        'category': 'Hair Texture',
        'isMultiSelect': false,
        'required': true,
        'options': [
          {
            'id': '2B Wavy',
            'title': '2B Wavy',
            'description': 'Loose S-pattern waves with slight crown volume',
            'icon': 'wavy',
          },
          {
            'id': 'Straight',
            'title': 'Straight',
            'description': 'Fine to coarse straight hair with minimal natural curl',
            'icon': 'straight',
          }
        ]
      };

      final question = QuizQuestion.fromJson(json);
      expect(question.id, 'hairType');
      expect(question.title, 'What is your hair texture & type?');
      expect(question.isMultiSelect, isFalse);
      expect(question.required, isTrue);
      expect(question.options.length, 2);
      expect(question.options.first.id, '2B Wavy');
      expect(question.options.first.title, '2B Wavy');
    });

    test('QuizService default questions provide complete 5-step consultation', () {
      final questions = QuizService.defaultQuestions;
      expect(questions.length, 5);
      expect(questions[0].id, 'hairType');
      expect(questions[1].id, 'hairConcerns');
      expect(questions[2].id, 'skinType');
      expect(questions[3].id, 'goals');
      expect(questions[4].id, 'sensitivities');
    });

    test('QuizService.getQuestions() parses backend JSON envelope successfully', () async {
      final service = QuizService();
      final questions = await service.getQuestions();
      expect(questions.length, 5);
      expect(questions.first.id, 'hairType');
      expect(questions[1].id, 'hairConcerns');
      expect(questions[1].isMultiSelect, isTrue);
    });

    test('QuizService.submitQuiz() handles backend submission response properly', () async {
      final service = QuizService();
      final answers = QuizAnswers(
        hairType: '2B Wavy',
        hairConcerns: ['Volume & Lift'],
        skinType: 'Combination',
        goals: ['Deep Hydration'],
      );
      final result = await service.submitQuiz(answers);
      expect(result.profileArchetype, 'Airy Volume & Sleek Defiance');
      expect(result.products.isNotEmpty, isTrue);
      expect(result.services.isNotEmpty, isTrue);
      expect(result.stylists.isNotEmpty, isTrue);
    });
  });

  group('3 & 4. Answer Selection & Validation Logic', () {
    test('Single-select questions overwrite answer while multi-select appends/removes', () {
      final answers = QuizAnswers();
      final hairTypeQ = QuizService.defaultQuestions[0]; // single select
      final concernsQ = QuizService.defaultQuestions[1]; // multi select

      // Single select test
      answers.toggleOption(hairTypeQ, 'Straight');
      expect(answers.hairType, 'Straight');
      expect(answers.isOptionSelected(hairTypeQ, 'Straight'), isTrue);

      answers.toggleOption(hairTypeQ, '2B Wavy');
      expect(answers.hairType, '2B Wavy');
      expect(answers.isOptionSelected(hairTypeQ, 'Straight'), isFalse);
      expect(answers.isOptionSelected(hairTypeQ, '2B Wavy'), isTrue);

      // Multi select test
      answers.toggleOption(concernsQ, 'Frizz Control');
      answers.toggleOption(concernsQ, 'Volume & Lift');
      expect(answers.hairConcerns.contains('Frizz Control'), isTrue);
      expect(answers.hairConcerns.contains('Volume & Lift'), isTrue);
      expect(answers.isOptionSelected(concernsQ, 'Frizz Control'), isTrue);

      // Deselecting multi select option
      answers.toggleOption(concernsQ, 'Frizz Control');
      expect(answers.hairConcerns.contains('Frizz Control'), isFalse);
      expect(answers.hairConcerns.contains('Volume & Lift'), isTrue);
    });

    test('Required-answer validation blocks empty answers and passes answered questions', () {
      final answers = QuizAnswers();
      final hairTypeQ = QuizService.defaultQuestions[0]; // required single
      final sensitivitiesQ = QuizService.defaultQuestions[4]; // optional multi

      // Initially unanswered required question fails validation
      expect(answers.isStepAnswered(hairTypeQ), isFalse);

      // After answering, passes validation
      answers.setSingleAnswer('hairType', '2B Wavy');
      expect(answers.isStepAnswered(hairTypeQ), isTrue);

      // Optional question passes even if empty
      expect(sensitivitiesQ.required, isFalse);
      expect(answers.isStepAnswered(sensitivitiesQ), isTrue);
    });

    test('QuizAnswers formats payload matching Node.js backend requirements', () {
      final answers = QuizAnswers(
        hairType: '2B Wavy',
        hairConcerns: ['Volume & Lift', 'Frizz Control'],
        skinType: 'Combination',
        goals: ['Deep Hydration', 'Radiant Glow'],
        sensitivities: ['Sulfate & Paraben Free'],
      );

      final payload = answers.toBackendJson();
      expect(payload['hairType'], '2B Wavy');
      expect(payload['hairConcerns'], equals(['Volume & Lift', 'Frizz Control']));
      expect(payload['skinType'], 'Combination');
      expect(payload['goals'], equals(['Deep Hydration', 'Radiant Glow']));
      expect(payload['sensitivities'], equals(['Sulfate & Paraben Free']));
    });
  });

  group('7 & 8. Result Calculation & Fallback Generation', () {
    test('QuizService generates tailored archetype and curated services/products', () {
      final service = QuizService();
      final answers = QuizAnswers(
        hairType: '2B Wavy',
        hairConcerns: ['Volume & Lift'],
        skinType: 'Combination',
        goals: ['Deep Hydration'],
      );

      final result = service.generateFallback(answers);

      expect(result.profileArchetype, contains('Airy Volume'));
      expect(result.profileChips.isNotEmpty, isTrue);
      expect(result.profileChips.any((c) => c.contains('Wavy')), isTrue);
      expect(result.services.isNotEmpty, isTrue);
      expect(result.products.isNotEmpty, isTrue);
    });

    test('QuizResultModel parses complete backend response', () {
      final json = {
        'id': 'res-123',
        'profileArchetype': 'Glass Silk & Luminous Radiance',
        'summary': 'Tailored for smooth light reflection.',
        'profileChips': ['Hair: Straight', 'Skin: Dry', 'Concern: Frizz'],
        'recommendations': {
          'services': [
            {
              'serviceId': 'serv-1',
              'name': 'Kérastase Fusio-Dose Glass Glaze',
              'category': 'Hair',
              'duration': 45,
              'price': 4500,
              'formattedPrice': '₹4,500',
              'description': 'Concentrated nano-infusion for gloss.',
              'matchReason': 'PRIMARY MATCH'
            }
          ],
          'products': [
            {
              'productId': 'prod-1',
              'name': 'Oribe Gold Lust Nourishing Hair Oil',
              'category': 'Hair',
              'price': 5800,
              'formattedPrice': '₹5,800',
              'imageUrl': 'https://example.com/oil.jpg',
              'matchReason': 'Liquid gold restorative elixir.'
            }
          ],
          'stylists': [
            {
              'stylistId': 'styl-1',
              'name': 'Christian Dior',
              'rating': 4.98,
              'experience': 12,
              'branchName': 'Khar West Flagship'
            }
          ]
        }
      };

      final model = QuizResultModel.fromJson(json);
      expect(model.profileArchetype, 'Glass Silk & Luminous Radiance');
      expect(model.services.length, 1);
      expect(model.services.first.name, 'Kérastase Fusio-Dose Glass Glaze');
      expect(model.products.first.formattedPrice, '₹5,800');
      expect(model.stylists.first.name, 'Christian Dior');
    });
  });

  group('Widget Tests: 1, 3, 4, 5, 6. Interactive Quiz Flow & Persistence', () {
    testWidgets('Renders Quiz questions and validates required answers', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: BeautyQuizScreen(),
        ),
      );

      // Initial loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Settle question loading
      await tester.pumpAndSettle();

      // Check header and step counter
      expect(find.text('Beauty Quiz'), findsOneWidget);
      expect(find.text('STEP 1 OF 5'), findsOneWidget);
      expect(find.text('What is your hair texture & type?'), findsOneWidget);
      expect(find.text('2B Wavy'), findsOneWidget);

      // Set virtual screen size for mobile layout
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.5;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Attempt clicking NEXT without selection -> inline validation error should trigger
      final nextButton = find.text('NEXT');
      expect(nextButton, findsOneWidget);
      await tester.tap(nextButton);
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Validation banner should be visible
      expect(find.text('Please select an option to continue.'), findsOneWidget);

      // Tap an option ('2B Wavy')
      await tester.tap(find.text('2B Wavy'));
      await tester.pumpAndSettle();

      // Validation error disappears
      expect(find.text('Please select an option to continue.'), findsNothing);

      // Clear any snackbar so it doesn't intercept tap
      ScaffoldMessenger.of(tester.element(find.byType(BeautyQuizScreen))).clearSnackBars();
      await tester.pumpAndSettle();

      // Click NEXT to navigate to Step 2
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should now be on Step 2
      expect(find.text('STEP 2 OF 5'), findsOneWidget);
      expect(find.text('What is your primary hair concern?'), findsOneWidget);

      // Select multiple options on Step 2
      await tester.tap(find.text('Volume & Lift'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Frizz Control'));
      await tester.pumpAndSettle();

      // Test Back navigation (Item 5 & 6: persistence)
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Back to Step 1
      expect(find.text('STEP 1 OF 5'), findsOneWidget);
      // '2B Wavy' must still be selected (checkmark visible)
      expect(find.byIcon(Icons.check), findsOneWidget);

      // Move forward to Step 2 again
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Back on Step 2, both frizz and volume should have checkmarks preserved
      expect(find.text('STEP 2 OF 5'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNWidgets(2));
    });
  });

  group('Widget Tests: 10. Personalized Recommendations Display', () {
    testWidgets('BeautyQuizResultScreen displays archetype, services, products & retake', (WidgetTester tester) async {
      const sampleResult = QuizResultModel(
        profileArchetype: 'Airy Volume & Sleek Defiance',
        summary: 'Tailored for 2B Wavy textures that need customized root lift and bounce.',
        profileChips: ['Hair: 2B Wavy', 'Skin: Combination', 'Concern: Volume & Lift'],
        services: [
          RecommendedService(
            serviceId: 'SERV-01',
            name: 'Premium Hair Spa',
            category: 'Hair',
            duration: 60,
            price: 1500,
            formattedPrice: 'From ₹1,500',
            description: 'Specifically curated to restore hydration and reduce frizz for your 2B Wavy hair texture.',
            matchReason: 'High priority treatment for immediate moisture replenishment.',
          ),
        ],
        products: [
          RecommendedProduct(
            productId: 'PROD-H-01',
            name: 'Maison Revital Serum',
            category: 'Hair',
            price: 1200,
            formattedPrice: '₹1,200',
            imageUrl: 'https://images.unsplash.com/photo-1608248597359-2ff99479b188',
            matchReason: 'Restores weightless hydration and smooths cuticle frizz.',
          ),
        ],
        stylists: [
          RecommendedStylist(
            stylistId: 'STYL-01',
            name: 'Christian Dior',
            rating: 4.95,
            experience: 10,
            specialization: ['Hair Architecture', 'Balayage Artistry'],
            branchName: 'Khar West Flagship',
          ),
        ],
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: BeautyQuizResultScreen(result: sampleResult),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Archetype
      expect(find.text('Personalized Recommendations'), findsOneWidget);
      expect(find.text('Airy Volume & Sleek Defiance'), findsOneWidget);
      expect(find.text('Hair: 2B Wavy'), findsOneWidget);
      expect(find.text('Skin: Combination'), findsOneWidget);

      // Recommended Services section & Card
      expect(find.text('RECOMMENDED SERVICES'), findsOneWidget);
      expect(find.text('Premium Hair Spa'), findsOneWidget);
      expect(find.text('From ₹1,500'), findsOneWidget);
      expect(find.text('Book Now'), findsOneWidget);

      // Prescribed Products section & Card
      expect(find.text('PRESCRIBED PRODUCTS'), findsOneWidget);
      expect(find.text('Maison Revital Serum'), findsOneWidget);
      expect(find.text('₹1,200'), findsOneWidget);

      // Retake action button
      expect(find.text('RETAKE QUIZ'), findsOneWidget);
    });
  });
}
