# Publishing Guide for Checkly

This guide will help you publish Checkly to the Google Play Store.

## Quick Start

1. **Build the App Bundle** (recommended over APK):
   ```bash
   flutter build appbundle --release
   ```
   The output will be at: `build/app/outputs/bundle/release/app-release.aab`

2. **Host Privacy Policy Online**
   - Upload `PRIVACY_POLICY.md` to a web hosting service
   - GitHub Pages, Netlify, or your own website work well
   - Make sure the URL is publicly accessible

3. **Create Screenshots**
   - Take screenshots of the app on a real device or emulator
   - Minimum 2 screenshots required, 4-8 recommended
   - Show: Home screen, Checklist detail, Settings

4. **Create Feature Graphic**
   - Size: 1024 x 500 pixels
   - Should include app icon and tagline
   - Use design tools like Canva, Figma, or Photoshop

5. **Submit to Play Console**
   - Follow the checklist in `PLAY_STORE_CHECKLIST.md`
   - Complete all required fields
   - Submit for review

## Files Included

- **PRIVACY_POLICY.md** - Privacy policy document (must be hosted online)
- **TERMS_OF_SERVICE.md** - Terms of service (optional but recommended)
- **PLAY_STORE_LISTING.md** - Store listing content and descriptions
- **PLAY_STORE_CHECKLIST.md** - Complete submission checklist

## Important Notes

### Privacy Policy Hosting
You must host the privacy policy online. Options:
- **GitHub Pages**: Free, easy setup
- **Netlify**: Free tier available
- **Your own website**: If you have one
- **Google Sites**: Free option

### App Bundle vs APK
- **App Bundle (.aab)**: Recommended, smaller size, optimized by Google
- **APK**: Works but larger file size

### First Submission
- Review time: 1-7 days typically
- May require additional information
- Be patient and responsive to feedback

## Support

For questions about publishing:
- Email: masteyesseeds@gmail.com
- Google Play Console Help: https://support.google.com/googleplay/android-developer

## Next Steps After Publishing

1. Monitor user reviews and ratings
2. Respond to user feedback
3. Plan feature updates
4. Monitor crash reports in Play Console
5. Consider adding analytics (optional, privacy-conscious)

---

Good luck with your Play Store submission! 🚀

