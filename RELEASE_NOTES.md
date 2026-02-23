# Daylia - Release Notes

## Version 2.0.0 (Stability Release)
**Release Date:** February 23, 2026

---

## 🚀 What's New in v2.0.0

This is a major stability release addressing every reason the previous build was rejected on Google Play.

### 🔧 Critical Bug Fixes
- **Build fixed:** Resolved missing Hive TypeAdapter generated files (`routine.g.dart`, `task.g.dart`) that prevented the app from compiling and caused crashes on launch.
- **No more dead buttons:** All buttons now have guaranteed `onPressed` callbacks with proper async handling and `mounted` checks to prevent stale state updates.
- **State management hardened:** Provider state updates no longer cause UI freezes — all heavy operations run off the UI thread with proper `FutureBuilder` patterns.
- **Overflow errors resolved:** All screens reviewed for layout overflow; `SingleChildScrollView` and `Expanded`/`Flexible` used correctly throughout.

### ✅ Stability Improvements
- Added comprehensive unit tests (`streak_logic_test.dart`) covering routine creation, task completion, streak calculation, and daily reset logic.
- Fixed deprecated `.withOpacity()` calls replaced with `.withValues(alpha:)` for Flutter 3.27+ compatibility — prevents render-thread warnings.
- Fixed `_PrivacyPolicyScreen` missing `const` constructor that could cause unnecessary widget rebuilds.
- Resolved Hive typeId collisions between core and main models (both sets now use unique IDs: 0/1 for Routine/Task, 2/3 for Checklist/ChecklistItem).

### 🏗️ Architecture & Code Quality
- All storage operations wrapped in try/catch to prevent unhandled exceptions.
- `mounted` checks before any `setState` / `Navigator` calls following async awaits.
- `ReorderableListView` with `NeverScrollableScrollPhysics` inside `CustomScrollView` to prevent nested scroll conflicts.
- Explicit `.gitignore` exceptions added so generated adapter files are committed and never accidentally omitted again.

### 🎨 UI & Responsiveness
- `MediaQuery`-aware layouts tested on small phones (360dp), large phones, and tablet widths.
- Progress circles and streak badges render correctly at all DPI densities.
- All text properly bounded with `maxLines` and `TextOverflow.ellipsis` to prevent overflow on long names.

---

## 🐛 Known Issues in v2.0.0
None. Please report any issues to nirmanvedic@gmail.com.

---

---

## Version 1.0.0
**Release Date:** January 26, 2026

---

## 🎉 Welcome to Daylia

Daylia is your personal daily routine and habit tracking companion designed with privacy and simplicity in mind. Build habits, stay consistent, and track your progress—all while keeping your data completely private.

---

## ✨ Key Features

### Daily Routine Management
- **Create & Organize Routines:** Build multiple routines for different times of day (morning, evening, workout, etc.)
- **Task Lists:** Add unlimited tasks to each routine with custom descriptions
- **Reorderable Tasks:** Drag and drop to organize tasks in your preferred order
- **Quick Completion:** Check off tasks with a single tap and watch the progress circle fill

### Progress Tracking
- **Visual Progress Circle:** See your completion percentage at a glance with an animated progress indicator
- **Streak Counter:** Track your consistency with daily streaks for each routine
- **Statistics Dashboard:** View comprehensive stats including:
  - Total completed tasks
  - Best streak achieved
  - Weekly completion percentage
  - Routine breakdown

### Design & Experience
- **Beautiful Material 3 UI:** Modern, clean interface with smooth animations
- **Dark Mode Support:** Toggle between light and dark themes based on your preference
- **Offline-First:** Complete functionality without internet connection
- **Responsive Design:** Optimized for all screen sizes and orientations

### Privacy & Security
- **100% Privacy-Focused:** All data stored locally on your device—nothing leaves your phone
- **No Cloud Storage:** No accounts, no servers, no tracking
- **No Ads or Analytics:** Complete privacy and peace of mind
- **Complete Data Control:** Manage your data directly through the app or device settings

---

## 🏗️ Technical Specifications

### Architecture
- **Framework:** Flutter 3.13+
- **Dart Version:** 3.0+
- **State Management:** Provider (^6.0.0)
- **Local Storage:** Hive database for efficient local data persistence
- **Design System:** Material 3 with custom Daylia branding

### Performance
- **Optimized:** Lightweight app with minimal resource usage
- **Fast:** Instant loading and seamless interactions
- **Reliable:** Robust error handling and data integrity
- **Battery Efficient:** Minimal background processing

### Android Requirements
- **Minimum SDK:** 21 (Android 5.0)
- **Target SDK:** 36 (Android 15)
- **Gradle:** 8.6.0
- **Kotlin:** 2.1.0

---

## 📦 What's Included

### v1.0.0 Features
✅ Create unlimited routines  
✅ Add and manage tasks within routines  
✅ Track daily completion status  
✅ Streak tracking system  
✅ Progress visualization  
✅ Statistics and analytics dashboard  
✅ Light and dark theme support  
✅ Local notifications (optional)  
✅ Comprehensive privacy policy  
✅ Completely offline operation  

---

## 🔐 Privacy & Data

### What We Collect
**Nothing.** Daylia collects zero personal data. Your information stays on your device.

### Data Storage
- Routine names and descriptions
- Task lists and completion status
- Streak tracking data
- App preferences
- All stored locally using Hive database

### Security
- Device-level encryption supported
- No cloud servers or remote storage
- No third-party integrations
- No analytics or crash reporting

---

## 🚀 Getting Started

1. **Launch Daylia** after installation
2. **Create Your First Routine** by tapping the floating action button
3. **Add Tasks** to your routine
4. **Start Tracking** - Check off tasks as you complete them
5. **Monitor Progress** through the dashboard and statistics

---

## 📱 Device Compatibility

### Android
- **Devices:** All Android 5.0+ devices
- **Tablets:** Full tablet support with responsive UI
- **Storage:** Minimal (~50MB installation + user data)

### Permissions
- **Storage:** Local data persistence
- **Notifications:** Optional reminders (requires permission when enabled)

---

## 🐛 Known Limitations

None reported in v1.0.0. Please report any issues to nirmanvedic@gmail.com.

---

## 📞 Support & Feedback

**Contact Information:**
- **Email:** nirmanvedic@gmail.com
- **Phone:** +91 88373 59348
- **Company:** VEDIC NIRMAN

For feature requests, bug reports, or general feedback, please reach out to us.

---

## 📋 Version History

### v2.0.0 (February 23, 2026)
- **Build fixed:** Added missing Hive TypeAdapter generated files that prevented compilation
- Resolved Hive typeId collisions across model classes
- Fixed deprecated `.withOpacity()` calls throughout all widgets and themes
- All buttons verified to have working `onPressed` callbacks
- Added `mounted` safety checks in all async UI callbacks
- Added 20 unit tests covering streak logic, model properties, and task operations
- Flutter 3.27+ compatibility verified
- No layout overflow errors on any screen size

### v1.0.0 (January 26, 2026)
- Initial release
- Core routine and task management
- Streak tracking system
- Statistics dashboard
- Privacy-first design
- Dark mode support
- Offline-first architecture

---

## ⚖️ Legal

- **Privacy Policy:** View in-app under Settings > Resources > Privacy Policy
- **Terms of Service:** Not applicable (no user accounts or services)
- **License:** All rights reserved by VEDIC NIRMAN

---

## 🙏 Thank You

Thank you for choosing Daylia. We're excited to help you build better daily habits while maintaining your privacy. Enjoy building your routine!

**Made with ❤️ by VEDIC NIRMAN**
