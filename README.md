# 📖 Holy Quran & Islamic Suite App

[![Flutter Version](https://img.shields.io/badge/Flutter-v3.22+-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-v3.4+-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Provider%20(MVVM)-FF6F00?style=for-the-badge&logo=google&logoColor=white)](https://pub.dev/packages/provider)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-green?style=for-the-badge)](https://flutter.dev)

A feature-rich, optimized, and beautifully crafted Islamic application built with Flutter. This application provides users with an offline-first Holy Quran experience featuring multi-language translations, a comprehensive digital Tasbih counter with audio-haptic feedback, smart prayer tracking based on live calculations, and customized UI state configurations.

---

## 📱 App Walkthrough & Screenshots

Explore the pixel-perfect, premium user interface designed with deep Islamic emerald accents (`#2E7D32` & `#1B3D2A`) supporting responsive light and dark themes:

### 🌟 Core Dashboards & Splashes
<p align="center">
  <img src="screenshots/Native_Splash_screen.png" width="24%" alt="Native Splash" />
  <img src="screenshots/splash_screen.png" width="24%" alt="App Splash" />
  <img src="screenshots/dashboard_screen.png" width="24%" alt="Dashboard" />
  <img src="screenshots/drawer.png" width="24%" alt="Main Drawer" />
</p>

### 📖 Holy Quran & Customization Experience
<p align="center">
  <img src="screenshots/surah_details_screen.png" width="24%" alt="Surah Details" />
  <img src="screenshots/display_showing_option_holy_quran.png" width="24%" alt="Display Options" />
  <img src="screenshots/translation_language_option_screen.png" width="24%" alt="Language Translation" />
  <img src="screenshots/select_qari_option_screen.png" width="24%" alt="Qari Selector" />
</p>

### 📿 Smart Tasbih & Prayer Modules
<p align="center">
  <img src="screenshots/digital_tasbih.png" width="24%" alt="Digital Tasbih" />
  <img src="screenshots/custom_setup_digital_tasbih.png" width="24%" alt="Custom Tasbih Setup" />
  <img src="screenshots/prayer_timers.png" width="24%" alt="Prayer Timers" />
  <img src="screenshots/search_delegate.png" width="24%" alt="Search Delegate" />
</p>

### 🔖 Bookmarks, Sadaqah & Settings
<p align="center">
  <img src="screenshots/bookmark_screen.png" width="24%" alt="Bookmarks" />
  <img src="screenshots/bookmark_delete_widgets.png" width="24%" alt="Bookmark Management" />
  <img src="screenshots/sadaqah_donation_screen.png" width="24%" alt="Sadaqah Donation" />
  <img src="screenshots/sadaqah_jariyah_pop_up_widgets.png" width="24%" alt="Sadaqah Pop-up" />
</p>

### ⚙️ System Configuration & Info
<p align="center">
  <img src="screenshots/settings_options.png" width="32%" alt="Settings Screen" />
  <img src="screenshots/about_app_screen.png" width="32%" alt="About App" />
  <img src="screenshots/about_developer_info.png" width="32%" alt="Developer Info" />
</p>

---

## ✨ Key Features

*   **📖 Al-Quran Al-Kareem:** High-performance typography rendering engine (`QuranFont`) with optimized caching for flawless reading.
*   **🌍 Multi-lingual Localized Engine:** Seamlessly toggle localized data arrays among 10 languages (English, Bengali, Spanish, French, Indonesian, Russian, Swedish, Turkish, Urdu, Chinese).
*   **📿 Audio-Haptic Tasbih Module:** Complete Dhikr suite integrated with asynchronous `just_audio` system triggers and hardware impact configurations (`HapticFeedback`).
*   **📍 Location-Aware Prayer Timings:** Precision offline algorithm using `adhan` and `geolocator` mapping with manual adjustments and smart fallback systems.
*   **🔖 Smart Bookmarks & Caching:** Granular persistence for individual Ayahs utilizing asynchronous `SharedPreferences` encoding.
*   **💳 Dynamic Donation UI Integration:** Built-in monetization layer support with native dialog components for global integration.

---

## 🏗️ Technical Architecture & Complete Project Directory

This workspace incorporates the Clean Architectural MVVM (Model-View-ViewModel) pattern via state management blocks, eliminating boilerplate code dependencies:

```text
lib/
├── main.dart                       # App core engine launcher & global MultiProvider tree
├── data/                           # Local hardcoded structural asset datasets
│   └── qari_data.dart              # Static collection records for supported Reciters
├── font/                           # Custom typography assets configuration
│   └── fonts_style.dart            # Typography wrapper for Arabic layout dimensions
├── logics/                         # Business logic & cross-cutting utilities
│   ├── prayer_logic.dart           # Offline Adhan calculations & dynamic geo-coordinate fetchers
│   ├── quran_search.dart           # Custom inline multi-dimensional text query search algorithm
│   └── share_logic.dart            # Platform share triggers to broadcast multilingual Ayahs
├── providers/                      # Application state managers (ViewModels)
│   ├── bookmark_provider.dart      # Manages reactive local data caching operations for Ayahs
│   ├── notification_provider.dart  # Controls operational status and updates for notifications
│   ├── qari_provider.dart          # Keeps track of selected globally streamable reciters
│   ├── quran_provider.dart         # Synchronizes real-time multi-lingual translation bindings
│   ├── tasbih_provider.dart        # Real-time counter tracker mapping sound and vibration states
│   └── view_mode_provider.dart     # Persists layout structure models (Arabic, Translation, or Both)
├── screens/                        # UI Presentation Layout Viewports
│   ├── bookmark_screen.dart        # Lists out bookmarked records safely
│   ├── donation_screen.dart        # Beautiful interactive dashboard for donations
│   ├── home_screen.dart            # Main structural dashboard of the application
│   ├── language_ui.dart            # Language selector interface layout
│   ├── main_drawer.dart            # App wide navigation slide drawer control
│   ├── prayer_screen.dart          # Renders automated high-fidelity localized prayer time wheels
│   ├── qari_selection_screen.dart  # Stream list control hub for selectable reciters
│   ├── splash_screen.dart          # Handles asynchronous application initialization workflows
│   ├── surah_detail_screen.dart    # Immersive scroll viewport tailored for core Quran reading
│   └── tasbih_screen.dart          # Full screen interactive digital counter workspace
├── services/                       # Third-party transaction pipelines
│   └── payment_service.dart        # Setup logic wrapper for localized monetization pipelines
├── themes/                         # Look and feel parameters configuration
│   └── theme_provider.dart         # Direct cross-platform state switcher for light & dark mode
└── widgets/                        # Atomic decoupled building blocks
    ├── about_us.dart               # Dedicated modal rendering organizational info
    ├── guidance_overlay_card.dart  # Contextual smart tutorial modal helper layer
    ├── quick_action_card.dart      # Grid component tailored for lightning-fast module hops
    └── show_sadakah_overlay.dart   # Interactive operational notification sheet for donations

