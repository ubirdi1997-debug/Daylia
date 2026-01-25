# Google Play Store Submission Checklist

Use this checklist to ensure you have everything ready before submitting to the Play Store.

## Pre-Submission Requirements

### ✅ App Information
- [x] App name: Checkly Lists
- [x] Short description (80 chars): "Offline checklist app for daily routines, tasks, and reusable lists."
- [x] Full description: See PLAY_STORE_LISTING.md
- [x] App icon: Generated from assets/icon.png (1024x1024)
- [ ] Feature graphic (1024x500): Need to create
- [ ] Screenshots: Need to create (minimum 2, recommended 4-5)

### ✅ Legal Documents
- [x] Privacy Policy: Created (PRIVACY_POLICY.md)
- [ ] Privacy Policy hosted online: Need to upload to web hosting
- [x] Terms of Service: Created (TERMS_OF_SERVICE.md) - Optional but recommended
- [ ] Terms of Service hosted online: Optional

### ✅ App Assets
- [x] App icon (all densities): Generated
- [ ] Phone screenshots (16:9 or 9:16): Need to create
- [ ] Tablet screenshots (7" and 10"): Optional
- [ ] Feature graphic (1024x500): Need to create
- [ ] Promotional graphic: Optional

### ✅ Technical Requirements
- [x] APK/App Bundle built: ✅ Latest build in release mode
- [ ] App Bundle (.aab) created: Recommended (smaller size, better for Play Store)
- [x] App signed with release key: ✅ Configured with signing keys
- [x] Target SDK: 36 (meets Google Play requirements - currently targeting SDK 36)
- [x] Min SDK: 21 (Android 5.0+)
- [x] Permissions minimal: ✅ Only POST_NOTIFICATIONS, no alarm/timer permissions
- [x] App tested on devices: Ready to test

### ✅ Content Rating
- [ ] Content rating questionnaire completed: Need to do in Play Console
- [x] App suitable for Everyone: ✅ Confirmed

### ✅ Store Listing Details
- [x] Category: Tools / Productivity
- [x] Tags/Keywords: Listed in PLAY_STORE_LISTING.md
- [x] Contact email: masteyesseeds@gmail.com
- [ ] Support URL: Optional
- [ ] Website: Optional

### ✅ Testing
- [ ] Internal testing track: Set up in Play Console
- [ ] Closed testing: Optional
- [ ] Open testing: Optional before production

## Submission Steps

1. **Create Google Play Developer Account**
   - Pay one-time $25 registration fee
   - Complete account setup

2. **Create New App**
   - Go to Play Console
   - Click "Create app"
   - Fill in app details

3. **Upload App Bundle/APK**
   - Go to "Production" or "Internal testing"
   - Upload the release build
   - Fill in release notes

4. **Complete Store Listing**
   - Upload screenshots
   - Add descriptions
   - Set pricing (Free)
   - Upload feature graphic

5. **Set Content Rating**
   - Complete questionnaire
   - Get rating certificate

6. **Privacy Policy**
   - Host privacy policy online
   - Add URL in Play Console

7. **Review and Submit**
   - Review all information
   - Submit for review
   - Wait for approval (usually 1-3 days)

## Post-Submission

- [ ] Monitor for review feedback
- [ ] Respond to user reviews
- [ ] Monitor crash reports
- [ ] Track analytics (if added later)
- [ ] Plan updates

## Quick Commands

### Build App Bundle (Recommended)
```bash
flutter build appbundle --release
```
Output: `build/app/outputs/bundle/release/app-release.aab`

### Build APK (Alternative)
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

### Test on Device
```bash
flutter install
```

## Notes

- App Bundle (.aab) is preferred over APK as it's optimized and smaller
- Privacy policy must be publicly accessible (host on GitHub Pages, your website, etc.)
- Screenshots should showcase key features
- Feature graphic should be eye-catching and represent the app
- First submission may take longer to review (up to 7 days)

