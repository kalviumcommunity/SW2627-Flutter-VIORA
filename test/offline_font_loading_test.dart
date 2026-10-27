import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:viora_salon_app/core/theme/app_text_styles.dart';
import 'package:viora_salon_app/core/theme/app_theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Offline Typography & Google Fonts Verification', () {
    test('GoogleFonts runtime fetching is strictly disabled', () {
      expect(GoogleFonts.config.allowRuntimeFetching, isFalse);
    });

    test('AppTextStyles instantiate without throwing unhandled exceptions', () {
      expect(AppTextStyles.brandTitle().fontFamily, contains('CormorantGaramond'));
      expect(AppTextStyles.editorialTitle().fontFamily, contains('CormorantGaramond'));
      expect(AppTextStyles.priceStyle.fontFamily, contains('CormorantGaramond'));
      expect(AppTextStyles.uppercaseSubtitle().fontFamily, contains('Inter'));
      expect(AppTextStyles.fieldLabel.fontFamily, contains('Inter'));
      expect(AppTextStyles.inputText.fontFamily, contains('Inter'));
      expect(AppTextStyles.bodyText.fontFamily, contains('Inter'));
      expect(AppTextStyles.buttonText().fontFamily, contains('Inter'));
      expect(AppTextStyles.linkText().fontFamily, contains('Inter'));
      expect(AppTextStyles.socialButtonText.fontFamily, contains('Inter'));
      expect(AppTextStyles.caption.fontFamily, contains('Inter'));
    });

    testWidgets('Renders all typography variants offline without network requests', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Text('VIORA', style: AppTextStyles.brandTitle()),
                  Text('Find Your Nearest Salon', style: AppTextStyles.editorialTitle()),
                  Text('EXCLUSIVE ACCESS', style: AppTextStyles.uppercaseSubtitle()),
                  Text('EMAIL ADDRESS', style: AppTextStyles.fieldLabel),
                  Text('customer@example.com', style: AppTextStyles.inputText),
                  Text('Luxury treatments tailored for you', style: AppTextStyles.bodyText),
                  Text('BOOK NOW', style: AppTextStyles.buttonText()),
                  Text(r'$120', style: AppTextStyles.priceStyle),
                  const Text('Direct Cormorant Garamond',
                    style: TextStyle(
                      fontFamily: 'Cormorant Garamond',
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('VIORA'), findsOneWidget);
      expect(find.text('Find Your Nearest Salon'), findsOneWidget);
      expect(find.text('EXCLUSIVE ACCESS'), findsOneWidget);
      expect(find.text(r'$120'), findsOneWidget);
      expect(find.text('Direct Cormorant Garamond'), findsOneWidget);
    });
  });
}
