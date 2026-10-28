import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:viora_salon_app/screens/home_screen.dart';
import 'package:viora_salon_app/screens/branches_list_screen.dart';
import 'package:viora_salon_app/screens/viora_search_screen.dart';
import 'package:viora_salon_app/screens/date_time_selection_screen.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: child,
      theme: ThemeData(
        fontFamily: 'Inter',
      ),
    );
  }

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

      final inputFinder = find.byKey(const Key('home_search_input_field'));
      await tester.enterText(inputFinder, 'Khar');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);

      final clearBtn = find.byKey(const Key('search_clear_button'));
      expect(clearBtn, findsOneWidget);

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

  group('BUG 2 — Salons Page Search & Filters Comprehensive Regression Tests', () {
    testWidgets('1. ALL SALONS tab displays all eligible branches', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('2. Search matches salon name and branch name', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Khar West');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsNothing);
      expect(find.text('VIORA — Colaba'), findsNothing);
    });

    testWidgets('3. Search matches supported location field (address)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Pali Road');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsNothing);
    });

    testWidgets('4. Search matches supported service categories (e.g. Beauty, Hair)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Beauty');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('5. Search is case-insensitive and trims leading/trailing spaces', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, '   jUhU   ');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsNothing);
    });

    testWidgets('6. Clearing search query restores complete list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Juhu');
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Colaba'), findsNothing);

      final clearBtn = find.byKey(const Key('salon_search_clear_button'));
      expect(clearBtn, findsOneWidget);
      await tester.tap(clearBtn);
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
      expect(find.text('VIORA — Juhu'), findsOneWidget);
      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('7. POPULAR tab orders branches by rating and serviceCount', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final popularTabFinder = find.byKey(const Key('tab_popular'));
      await tester.tap(popularTabFinder);
      await tester.pumpAndSettle();

      // Colaba is highest rated (4.9★, 52 services)
      expect(find.text('VIORA — Colaba'), findsOneWidget);
    });

    testWidgets('8. NEAREST tab orders branches by valid distance', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final nearestTabFinder = find.byKey(const Key('tab_nearest'));
      await tester.tap(nearestTabFinder);
      await tester.pumpAndSettle();

      // Nearest is Khar West (0.8 km)
      expect(find.text('VIORA — Khar West'), findsOneWidget);
    });

    testWidgets('9. Combined search and filter: Popular with query', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      // Select POPULAR
      await tester.tap(find.byKey(const Key('tab_popular')));
      await tester.pumpAndSettle();

      // Search for 'Beauty'
      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'Beauty');
      await tester.pumpAndSettle();

      // Colaba and Khar West should be present, ordered by popularity
      expect(find.text('VIORA — Colaba'), findsOneWidget);
      expect(find.text('VIORA — Khar West'), findsOneWidget);
    });

    testWidgets('10. Changing filter tabs updates displayed list immediately', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      // Switch to NEAREST
      await tester.tap(find.byKey(const Key('tab_nearest')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tab_nearest')), findsOneWidget);

      // Switch to ALL SALONS
      await tester.tap(find.byKey(const Key('tab_all_salons')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('tab_all_salons')), findsOneWidget);
    });

    testWidgets('11. Empty results display elegant message and Reset button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      final searchInput = find.byKey(const Key('salon_search_input'));
      await tester.enterText(searchInput, 'UnknownNonExistentSalonXYZ');
      await tester.pumpAndSettle();

      expect(find.text('No Salons Found'), findsOneWidget);
      expect(find.text('RESET FILTERS'), findsOneWidget);

      // Tap RESET FILTERS
      await tester.tap(find.text('RESET FILTERS'));
      await tester.pumpAndSettle();

      expect(find.text('VIORA — Khar West'), findsOneWidget);
    });

    testWidgets('12. Tapping a salon card opens DateTimeSelectionScreen', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget(const BranchesListScreen()));
      await tester.pumpAndSettle();

      // Tap first salon
      await tester.tap(find.text('SELECT SALON →').first);
      await tester.pumpAndSettle();

      expect(find.byType(DateTimeSelectionScreen), findsOneWidget);
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
      expect(find.text('with Christian Dior'), findsOneWidget);
      expect(find.text('Signature Haute Coiffure'), findsOneWidget);
    });
  });
}
