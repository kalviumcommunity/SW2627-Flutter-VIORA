# VIORA — Luxury Salon & Member Access Web & Mobile Application

A luxury, high-end salon web and mobile application engineered with **Flutter**, **Dart**, and **Firebase Architecture** (Auth, Cloud Firestore, and Storage). Designed with an obsidian & champagne gold aesthetic, full 360° studio photoshoots across all hair lengths and textures, custom nail design studio, and real-time VIP booking.

---

## 🏗️ Architecture Overview

| Component | Role & Implementation | Key Features |
| :--- | :--- | :--- |
| **Dart** | The programming language Flutter runs on | Null-safe models, async streams, clean MVVM service architecture |
| **Flutter** | Cross-platform UI framework | Edge-to-edge mobile + luxury centered responsive web container (`ResponsiveWebContainer`) |
| **Firebase Auth** | User identity & sessions | Email/Password, Google, Apple, VIP Guest access, Membership tiers (`Silver`, `Gold`, `Platinum`, `Black Card`) |
| **Cloud Firestore** | Real-time NoSQL database | Live appointments collection, real-time catalog streams for cuts, nail art, stylists, and branches |
| **Firebase Storage** | File & media storage | Photoshoot asset pipeline, client reference photo uploads |
| **📱 Emulator / Device / Web** | Where your app actually runs | Native Chrome/Edge web execution, web-server mode, and iOS/Android emulators |

---

## 🌟 Interactive Flow & Screens (16 Production Screens)

1. **Onboarding & VIP Access**: [`lib/screens/onboarding_screen.dart`](lib/screens/onboarding_screen.dart)
2. **Authentication & Member Portal**: [`lib/screens/sign_in_screen.dart`](lib/screens/sign_in_screen.dart) (Wired to `AuthService`)
3. **Location & Branch Selection**: [`lib/screens/location_screen.dart`](lib/screens/location_screen.dart), [`lib/screens/branches_list_screen.dart`](lib/screens/branches_list_screen.dart)
4. **Curated Services Showcase**: [`lib/screens/services_categories_screen.dart`](lib/screens/services_categories_screen.dart), [`lib/screens/home_screen.dart`](lib/screens/home_screen.dart)
5. **Hair Services & Styling Menu**: [`lib/screens/hair_services_screen.dart`](lib/screens/hair_services_screen.dart), [`lib/screens/hair_cut_styling_screen.dart`](lib/screens/hair_cut_styling_screen.dart)
6. **Long Layered Cut 360° Studio**: [`lib/screens/long_layered_cut_detail_screen.dart`](lib/screens/long_layered_cut_detail_screen.dart)
   - 12 Dynamic Texture & Length Combinations (Straight, Wavy, Curly, Coily $\times$ Long, Medium, Short)
   - Fringe Customizer: Curtain Bangs vs. Center-Parted No Bangs
   - Interactive 360° Angle Views (`Front View`, `Side Profile`, `Back Cascading`)
7. **Layer Cut 360° Studio**: [`lib/screens/layer_cut_detail_screen.dart`](lib/screens/layer_cut_detail_screen.dart)
8. **Nail Art Services & Customizer**: [`lib/screens/nail_services_screen.dart`](lib/screens/nail_services_screen.dart), [`lib/screens/nail_art_services_screen.dart`](lib/screens/nail_art_services_screen.dart), [`lib/screens/nail_detail_screen.dart`](lib/screens/nail_detail_screen.dart)
9. **Senior Stylist Booking**: [`lib/screens/stylist_selection_screen.dart`](lib/screens/stylist_selection_screen.dart)
10. **Date & Time Reservation**: [`lib/screens/date_time_selection_screen.dart`](lib/screens/date_time_selection_screen.dart) (Wired to `FirestoreService.createAppointment()`)
11. **VIP Booking Confirmation**: [`lib/screens/booking_confirmed_screen.dart`](lib/screens/booking_confirmed_screen.dart)

---

## ⚡ Running the App

### Option A: Launch in Antigravity IDE (Recommended)
1. Open this folder in Antigravity IDE:
   ```powershell
   "C:\Users\agnes\AppData\Local\Programs\Antigravity IDE\bin\antigravity-ide.cmd" "C:\Users\agnes\.gemini\antigravity\scratch\maison_salon_app"
   ```
2. Press **F5** or navigate to **Run and Debug** (`Ctrl+Shift+D`).
3. Select any target:
   - `VIORA (Flutter Web - Chrome)`
   - `VIORA (Flutter Web - Edge)`
   - `VIORA (Flutter Web Server)`
   - `VIORA (Mobile Emulator / Device)`

### Option B: Run via Terminal Scripts
Double-click or run:
```bat
run_web.bat
```
or in PowerShell:
```powershell
.\run_web.ps1
```

### Option C: Native Flutter CLI
```bash
flutter pub get
flutter run -d chrome --web-port 8080 --web-renderer canvaskit
```

---

## 🌐 Web Scaffolding & Responsive Layout

- **PWA Scaffolding**: [`web/index.html`](web/index.html) with custom gold preloader monogram and [`web/manifest.json`](web/manifest.json) configured with theme `#C59265` and background `#FAF8F5`.
- **Desktop Web Wrapper**: [`lib/widgets/responsive_web_container.dart`](lib/widgets/responsive_web_container.dart) centers the mobile app viewport on desktop monitors, framing it in deep obsidian slate with gold status bars, while expanding edge-to-edge on mobile browser viewports.

---

## 🔒 Firebase Services Layer

- **Firebase Core & Manager**: [`lib/core/firebase/firebase_manager.dart`](lib/core/firebase/firebase_manager.dart), [`lib/core/firebase/firebase_options.dart`](lib/core/firebase/firebase_options.dart)
- **Auth Service**: [`lib/services/auth_service.dart`](lib/services/auth_service.dart)
- **Firestore Service**: [`lib/services/firestore_service.dart`](lib/services/firestore_service.dart)
- **Storage Service**: [`lib/services/storage_service.dart`](lib/services/storage_service.dart)
