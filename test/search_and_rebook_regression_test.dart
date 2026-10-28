import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/screens/home_screen.dart';
import 'package:viora_salon_app/screens/viora_search_screen.dart';
import 'package:viora_salon_app/screens/branches_list_screen.dart';
import 'package:viora_salon_app/screens/date_time_selection_screen.dart';
import 'package:viora_salon_app/core/theme/app_theme.dart';

Widget createTestWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: child,
  );
}

void main() {
  group('BUG 1 — Home Search Regression Tests', () {
    testWidgets('Tapping Home Search Bar opens VioraSearchScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const HomeScreen()));
      await tester.pumpAndSettle();

      final searchBarFinder = find.byKey(const Key('home_search_bar_button'));
      expect(searchBarFinder, findsOneWidget);

      await tester.tap(searchBarFinder);
      await tester.pumpAndSettle();

      expect(find.byType(VioraSearchScreen), findsOneWidget);
      expect(find.text('Search Atelier'), findsOneWidget);
      expect(find.byKey(const Key('home_search_input_field')), findsOneWidget);
    });

    testWidgets('Entering query filters items and clearing query restores items', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const VioraSearchScreen()));
      await tester.pumpAndSettle();

      // Enter query 'Khar'
      final inputFinder = find.byKey(const Key('home_search_input_field'));
      await tester.enterText(inputFinder, 'Khar');
      await tester.pumpAndSettle();

      // Result should show Khar West
      expect(find.text('VIORA — Khar West'), findsOneWidget);

      // Clear button should be visible
      final clearBtn = find.byKey(const Key('search_clear_button'));
      expect(clearBtn, findsOneWidget);

      // Clear query
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('CURATED ATELIER SEARCHES'), findsOneWidget);
    });

    testWidgets('Empty search results display elegant empty state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const VioraSearchScreen()));
      await tester.pumpAndSettle();

      final inputFinder = find.byKey(const Key('home_search_input_field'));
      await tester.enterText(inputFinder, 'NonExistentServiceXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No Bespoke Results'), findsOneWidget);
      expect(find.text('CLEAR SEARCH'), findsOneWidget);
    });
  });

  group('BUG 2 — Salons Page Search & Filters Regression Tests', () {
    testWidgets('ALL SALONS tab displays all eligible branches', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('POPULAR tab orders branches by rating and serviceCount', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final popularTabFinder = find.byKey(const Key('tab_popular'));
      expect(popularTabFinder, findsOneWidget);
      await tester.tap(popularTabFinder);
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('NEAREST tab orders branches by distance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final nearestTabFinder = find.byKey(const Key('tab_nearest'));
      expect(nearestTabFinder, findsOneWidget);
      await tester.tap(nearestTabFinder);
      await tester.pumpAndSettle();

      // Nearest is Khar West (0.8 km)
      expect(find.text('VIORA — Khar West'), findsOneWidget);
    });

    testWidgets('Searching salon by query filters list and clear restores list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Juhu');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsNothing);

      // Tap clear
      final clearBtn = find.byKey(const Key('salon_search_clear_button'));
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });
  });

  group('BUG 3 — Rebooking Preserves Original Branch & Stylist', () {
    testWidgets('Rebooking passes preselectedBranchName and highlights branch', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(
        const BranchesListScreen(
          selectedServiceTitle: 'Signature Haute Coiffure',
          selectedPrice: 140,
          preselectedBranchName: 'VIORA • Khar West',
          preferredStylistName: 'Christian Dior',
        ),
      ));
      await tester.pumpAndSettle();

      // Rebooking banner must be visible
      expect(find.text('ORIGINAL SALON PRESELECTED'), findsOneWidget);
      expect(find.text('VIORA — Khar West'), findsWidgets);
      expect(find.text('PREVIOUS APPOINTMENT SALON'), findsOneWidget);
      expect(find.byKey(const Key('continue_rebook_preselected_button')), findsOneWidget);
    });

    testWidgets('Rebooking when original branch is missing shows clear warning banner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(
        const BranchesListScreen(
          selectedServiceTitle: 'Signature Haute Coiffure',
          selectedPrice: 140,
          preselectedBranchName: 'VIORA • NonExistent Atlantis Branch',
        ),
      ));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('The original salon "VIORA • NonExistent Atlantis Branch" is currently unavailable'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping preselected salon rebook button navigates to DateTimeSelectionScreen with original stylist', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(
        const BranchesListScreen(
          selectedServiceTitle: 'Signature Haute Coiffure',
          selectedPrice: 140,
          preselectedBranchName: 'VIORA • Khar West',
          preferredStylistName: 'Christian Dior',
        ),
      ));
      await tester.pumpAndSettle();

      final continueBtn = find.byKey(const Key('continue_rebook_preselected_button'));
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      expect(find.byType(DateTimeSelectionScreen), findsOneWidget);
      // Stylist name should be Christian Dior
      expect(find.text('with Christian Dior'), findsOneWidget);
      expect(find.text('Signature Haute Coiffure'), findsOneWidget);
    });
  });
}
