# 🚀 Quick Start Guide - Antique Auction App

## ⚡ Get Running in 5 Minutes

### Step 1: Install Dependencies
```bash
flutter pub get
```

### Step 2: Firebase Setup (Critical!)

#### Option A: Use Demo Mode (For Testing Structure Only)
⚠️ **Note**: The app will crash without Firebase configuration. You MUST set up Firebase.

#### Option B: Full Setup (Recommended)
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project: "Antique Auction"
3. Add Android app:
   - Package name: `com.example.antique`
   - Download `google-services.json` → Place in `android/app/`
4. Add iOS app (optional):
   - Bundle ID: `com.example.antique`
   - Download `GoogleService-Info.plist` → Place in `ios/Runner/`

5. **Enable Firebase Services:**
   - **Authentication**: Enable Email/Password
   - **Firestore Database**: Create database in test mode
   - **Storage**: Create bucket

6. **Deploy Security Rules:**
   - Copy rules from `FIREBASE_RULES.md`
   - Paste in Firebase Console → Firestore → Rules
   - Paste in Firebase Console → Storage → Rules

### Step 3: Run the App
```bash
flutter run
```

## 🎯 First Time User Flow

### 1. Sign Up
- Tap "Sign Up" on login screen
- Enter name, email, password
- Tap "Sign Up"
- You're automatically logged in!

### 2. Browse Antiques
- Home screen shows active auctions
- Tap any card to view details

### 3. Place a Bid
- On detail screen, tap "Place Bid"
- Enter amount > current bid
- Tap "Place Bid" to submit

### 4. Check Your Bids
- Tap "My Bids" in bottom navigation
- See Active, Won, and Lost bids

### 5. View Profile
- Tap "Profile" in bottom navigation
- See your stats and account info

## 🔧 Make Yourself an Admin

To add antiques, you need admin access:

1. Sign up and login
2. Go to [Firebase Console](https://console.firebase.google.com/)
3. Navigate to: Firestore Database
4. Find your user in `users` collection
5. Click on your user document
6. Find the `isAdmin` field
7. Change value from `false` to `true`
8. Save
9. Restart the app
10. You'll see "+" button in home screen

## 📝 Add Your First Antique (Admin Only)

1. Tap "+" icon in top-right of home screen
2. Tap the image area to select/take photo
3. Fill in:
   - Title: "Victorian Chair"
   - Description: "Rare 19th century..."
   - Category: "Furniture"
   - Base Price: "100"
   - End Date: Select future date & time
4. Tap "Add Antique"
5. Watch it appear on home screen!

## 🎨 Test the Complete Flow

### User Journey Test:
```
1. Sign Up → Login
2. Browse Antiques
3. View Antique Detail
4. Place Bid
5. Check "My Bids"
6. View Profile
7. Logout
```

### Admin Journey Test:
```
1. Login as admin
2. Tap "+" to add antique
3. Upload image
4. Fill details
5. Submit
6. Verify appears on home
7. Switch to regular user
8. Place bid on your antique
```

## 🐛 Common Issues & Fixes

### ❌ App crashes on startup
**Solution**: Firebase not configured
- Check `google-services.json` is in `android/app/`
- Verify Firebase is initialized in `main.dart`
- Run `flutter clean` and rebuild

### ❌ Can't see "Add Antique" button
**Solution**: Not admin user
- Follow "Make Yourself an Admin" section above
- Restart app after setting `isAdmin: true`

### ❌ Images not uploading
**Solution**: Storage not configured
- Enable Firebase Storage in console
- Deploy storage rules from `FIREBASE_RULES.md`

### ❌ Can't place bids
**Solution**: Firestore rules issue
- Deploy Firestore rules from `FIREBASE_RULES.md`
- Check user is authenticated

### ❌ "Permission denied" errors
**Solution**: Security rules not deployed
- Copy rules from `FIREBASE_RULES.md`
- Deploy in Firebase Console
- Wait 1-2 minutes for rules to propagate

## 📱 Platform-Specific Setup

### Android Additional Steps:
None required if `google-services.json` is in place!

### iOS Additional Steps (if building for iOS):
1. Open `ios/Runner.xcworkspace` in Xcode
2. Add `GoogleService-Info.plist` to Runner target
3. Update Info.plist for camera/photo permissions:
```xml
<key>NSCameraUsageDescription</key>
<string>Need camera access to take photos of antiques</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Need photo library access to select images</string>
```

## 🎯 Next Steps

Once app is running:

1. **Read Full Documentation**:
   - [README.md](README.md) - Project overview
   - [SETUP_GUIDE.md](SETUP_GUIDE.md) - Detailed setup
   - [FIREBASE_RULES.md](FIREBASE_RULES.md) - Security details

2. **Customize**:
   - Change app name in `pubspec.yaml`
   - Update colors in `lib/theme/app_colors.dart`
   - Modify Firebase project name

3. **Test Thoroughly**:
   - Try all user flows
   - Test on real devices
   - Verify real-time updates

4. **Deploy**:
   - Build APK: `flutter build apk`
   - Build iOS: `flutter build ios`

## ⚡ Super Quick Test (2 Minutes)

If you just want to see the structure without Firebase:

1. Comment out Firebase initialization in `main.dart`:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(); // COMMENTED
  runApp(const MyApp());
}
```

2. Run app - you'll see the splash screen and UI structure
3. ⚠️ Features won't work without Firebase!

## 🎉 Success Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] Firebase project created
- [ ] `google-services.json` added (Android)
- [ ] Firebase Authentication enabled
- [ ] Firestore database created
- [ ] Storage bucket created
- [ ] Security rules deployed
- [ ] App runs without errors
- [ ] Can sign up new user
- [ ] Can browse antiques
- [ ] Can place bids
- [ ] Can view profile

## 📞 Need Help?

1. Check error messages in console
2. Review [SETUP_GUIDE.md](SETUP_GUIDE.md)
3. Verify Firebase Console settings
4. Check security rules are deployed
5. Run `flutter doctor` for system issues
6. Try `flutter clean` and rebuild

---

**You're ready to go! Start with Sign Up and explore the app.** 🚀

*For detailed information, see [README.md](README.md) and [SETUP_GUIDE.md](SETUP_GUIDE.md)*
