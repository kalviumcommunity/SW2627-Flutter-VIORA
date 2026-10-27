import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/firebase/firebase_manager.dart';
import 'widgets/responsive_web_container.dart';

// Customer Mobile App Screens
import 'screens/home_screen.dart';
import 'screens/services_categories_screen.dart';
import 'screens/subcategories_screen.dart';
import 'screens/service_details_screen.dart';
import 'screens/branches_list_screen.dart';
import 'screens/nail_services_screen.dart';
import 'screens/nail_art_services_screen.dart';
import 'screens/nail_detail_screen.dart';
import 'screens/skin_services_screen.dart';
import 'screens/massage_services_screen.dart';
import 'screens/hair_removal_services_screen.dart';
import 'screens/mens_grooming_services_screen.dart';
import 'screens/eyes_brows_services_screen.dart';
import 'screens/makeup_services_screen.dart';
import 'screens/hair_services_screen.dart';
import 'screens/hair_cut_styling_screen.dart';
import 'screens/layer_cut_detail_screen.dart';
import 'screens/long_layered_cut_detail_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/location_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/stylist_selection_screen.dart';
import 'screens/date_time_selection_screen.dart';
import 'screens/booking_confirmed_screen.dart';
import 'screens/my_appointments_screen.dart';

// Stylist Dashboard Screens
import 'screens/stylist_home_screen.dart';
import 'screens/stylist_appointment_details_screen.dart';
import 'screens/stylist_schedule_screen.dart';
import 'screens/stylist_availability_screen.dart';
import 'screens/stylist_services_screen.dart';
import 'screens/stylist_profile_screen.dart';

// Admin Web Dashboard Screen
import 'screens/admin_dashboard_screen.dart';

import 'models/stylist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    return MaterialApp(
      title: 'VIORA — Luxury Salon & Member Access',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/home',
      builder: (context, child) {
        return ResponsiveWebContainer(
          child: child ?? const SizedBox.shrink(),
        );
      },
      routes: {
        // Customer Mobile Flow
        '/home': (context) => const HomeScreen(),
        '/services': (context) => const ServicesCategoriesScreen(),
        '/subcategories': (context) => const SubcategoriesScreen(),
        '/service_details': (context) => const ServiceDetailsScreen(),
        '/select_branch': (context) => const BranchesListScreen(),
        '/salons': (context) => const BranchesListScreen(),
        '/branches': (context) => const BranchesListScreen(),
        '/location': (context) => const LocationPermissionScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/sign-in': (context) => const SignInScreen(),
        '/stylists': (context) => const StylistSelectionScreen(),
        '/date_time': (context) => DateTimeSelectionScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/date-time': (context) => DateTimeSelectionScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/booking_confirmed': (context) => BookingConfirmedScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/booking-confirmed': (context) => BookingConfirmedScreen(
              stylist: Stylist.sampleStylists[2],
            ),
        '/my_appointments': (context) => const MyAppointmentsScreen(),

        // Specialized Curated Catalogs
        '/hair': (context) => const HairServicesScreen(),
        '/hair-cuts': (context) => const HairCutStylingScreen(),
        '/layer-cut-detail': (context) => const LayerCutDetailScreen(
              initialTexture: 'Straight',
              initialLength: 'Long',
            ),
        '/long-layered-cut-detail': (context) =>
            const LongLayeredCutDetailScreen(
              initialTexture: 'Straight',
              initialLength: 'Long',
            ),
        '/nails': (context) => const NailServicesScreen(),
        '/nail-art': (context) => const NailArtServicesScreen(),
        '/nail-detail': (context) => const NailDetailScreen(),
        '/skin': (context) => const SkinServicesScreen(),
        '/massage': (context) => const MassageServicesScreen(),
        '/hair-removal': (context) => const HairRemovalServicesScreen(),
        '/eyes-brows': (context) => const EyesBrowsServicesScreen(),
        '/makeup': (context) => const MakeupServicesScreen(),
        '/mens-grooming': (context) => const MensGroomingServicesScreen(),

        // Stylist Dashboard Flow
        '/stylist_login': (context) => const SignInScreen(),
        '/stylist_home': (context) => const StylistHomeScreen(),
        '/stylist_appointment_details': (context) =>
            const StylistAppointmentDetailsScreen(),
        '/stylist_schedule': (context) => const StylistScheduleScreen(),
        '/stylist_availability': (context) => const StylistAvailabilityScreen(),
        '/stylist_services': (context) => const StylistServicesScreen(),
        '/stylist_profile': (context) => const StylistProfileScreen(),

        // Admin Web Dashboard Flow
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
      },
    );
  }
}
