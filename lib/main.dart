import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_manager.dart';
import 'widgets/responsive_web_container.dart';

// Customer Flow Screens
import 'screens/onboarding_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/customer_main_scaffold.dart';
import 'screens/services_categories_screen.dart';
import 'screens/subcategories_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/branches_list_screen.dart';
import 'screens/date_time_selection_screen.dart';
import 'screens/booking_confirmed_screen.dart';
import 'screens/my_appointments_screen.dart';
import 'screens/customer_profile_screen.dart';

// Person 3 - Inspiration & Reviews Screens
import 'screens/inspiration_gallery_screen.dart';
import 'screens/inspiration_request_screen.dart';
import 'screens/inspiration_responses_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/submit_review_screen.dart';
import 'screens/stylist_reviews_screen.dart';
import 'screens/stylist_portfolio_screen.dart';

// Stylist Dashboard Screens
import 'screens/stylist_home_screen.dart';
import 'screens/stylist_appointment_details_screen.dart';
import 'screens/stylist_schedule_screen.dart';
import 'screens/stylist_availability_screen.dart';
import 'screens/stylist_services_screen.dart';
import 'screens/stylist_profile_screen.dart';

// Admin Dashboard Screen
import 'screens/admin_dashboard_screen.dart';

import 'models/stylist.dart';
import 'screens/beauty_quiz_screen.dart';
import 'screens/beauty_quiz_result_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent dynamic runtime font downloads over HTTP; all fonts are bundled locally in assets/fonts/
  GoogleFonts.config.allowRuntimeFetching = false;

  // Set system navigation and status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase (Auth, Firestore, Storage)
  await FirebaseManager().initialize();

  runApp(const VioraSalonApp());
}

class VioraSalonApp extends StatelessWidget {
  const VioraSalonApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = FirebaseManager().auth.isAuthenticated;

    return MaterialApp(
      title: 'VIORA - Luxury Salon & Member Access',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: isAuthenticated ? '/home' : '/onboarding',
      builder: (context, child) {
        return ResponsiveWebContainer(
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        // Customer Entry & Auth Flow
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const SignInScreen(),

        // Customer Main Flow
        '/home': (context) => const CustomerMainScaffold(),
        '/services': (context) => const ServicesCategoriesScreen(),
        '/subcategories': (context) => const SubcategoriesScreen(),
        '/service_details': (context) => const ServiceDetailsScreen(),
        '/select_branch': (context) => const BranchesListScreen(),
        '/date_time': (context) => DateTimeSelectionScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/booking_confirmed': (context) => BookingConfirmedScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/my_appointments': (context) => const MyAppointmentsScreen(),
        '/customer_profile': (context) => const CustomerProfileScreen(),
        '/beauty_quiz': (context) => const BeautyQuizScreen(),
        '/quiz_results': (context) => const BeautyQuizResultScreen(),

        // Person 3 Routes
        '/inspiration': (context) => const InspirationGalleryScreen(),
        '/inspiration_request': (context) => const InspirationRequestScreen(),
        '/inspiration_responses': (context) => const InspirationResponsesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/submit_review': (context) => const SubmitReviewScreen(),
        '/stylist_reviews': (context) => const StylistReviewsScreen(),
        '/stylist_portfolio': (context) => const StylistPortfolioScreen(),

        // Stylist Dashboard
        '/stylist_login': (context) => const SignInScreen(),
        '/stylist_home': (context) => const StylistHomeScreen(),
        '/stylist_appointment_details': (context) => const StylistAppointmentDetailsScreen(),
        '/stylist_schedule': (context) => const StylistScheduleScreen(),
        '/stylist_availability': (context) => const StylistAvailabilityScreen(),
        '/stylist_services': (context) => const StylistServicesScreen(),
        '/stylist_profile': (context) => const StylistProfileScreen(),

        // Admin Dashboard
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
