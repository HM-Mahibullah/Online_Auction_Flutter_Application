# Firestore Update Script for Existing Users

## Problem
Users who signed up BEFORE this fix won't have `passwordHash` field in their Firestore documents, so they won't be able to log in using the fallback verification method.

## Solutions

### Option 1: Manual Firestore Update (Recommended for few users)

1. **Go to Firebase Console**:
   - Open [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Firestore Database
   - Navigate to `users` collection

2. **For each user that needs fixing**:
   - Click on the user document
   - Click "Edit" on any field or Add field
   - Add new field: `passwordHash`
   - Value: Calculate hash of their password

3. **How to calculate password hash**:
   - Use the same formula from the code: `password.hashCode.toString()`
   - Example: If password is "password123": `"password123".hashCode.toString()`

### Option 2: Cloud Function (For many users)

Create a Cloud Function to update all existing users:

```javascript
// functions/index.js
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

// Add password hashes to all users that don't have them
exports.updateUserPasswordHashes = functions.https.onRequest(async (req, res) => {
  try {
    const db = admin.firestore();
    const usersRef = db.collection('users');
    const snapshot = await usersRef.where('passwordHash', '==', undefined).get();
    
    let updatedCount = 0;
    const batch = db.batch();
    
    snapshot.forEach(doc => {
      const email = doc.data().email;
      const userId = doc.id;
      
      // Get auth user to verify password exists
      // Note: You can't get password from Firebase Auth
      // This function can only add a placeholder
      
      batch.update(usersRef.doc(userId), {
        passwordHash: 'MIGRATE_MANUALLY', // Mark for manual migration
        migrationNeeded: true,
        migrationDate: new Date()
      });
      
      updatedCount++;
    });
    
    await batch.commit();
    res.json({ 
      message: 'Migration started',
      updatedCount: updatedCount 
    });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ error: error.message });
  }
});
```

### Option 3: Ask Users to Reset Password

If you want to avoid manual updates:

1. **Create a "Migrate" screen** that appears for users without `passwordHash`
2. **Ask them to reset their password**:
   - Show "Forgot Password" option
   - They receive password reset email
   - They set a new password
   - During sign-in with new password, `passwordHash` will be created

### Option 4: Force Signup Verification Email

Add to sign-in flow:

```dart
// If passwordHash doesn't exist and user is from old signup
if (user.passwordHash == null || user.passwordHash?.isEmpty == true) {
  // Send verification email to confirm they still own the account
  await _authRepository.sendEmailVerification();
  
  throw Exception(
    'Your account needs verification. Check your email and verify, '
    'then log in again.'
  );
}
```

## Testing After Update

1. **Test with new signup**:
   - Delete any test user from both Firebase Auth and Firestore
   - Do fresh signup
   - Verify `passwordHash` is created
   - Try login - should work

2. **Test with migrated old users**:
   - Try login with old credentials
   - Should show specific error if `passwordHash` missing
   - Apply migration option above

3. **Test wrong password**:
   - Try login with wrong password
   - Should show "Email or password is incorrect"

## Database Query to Find Users Without Password Hash

Run this in Firestore console to find affected users:

```
Collection: users
Filter 1: passwordHash does not exist
```

Or manually check each user document and look for missing `passwordHash` field.

## Important Notes

⚠️ **Security Reminder**:
- Current hash is simple and NOT secure for production
- Implement proper bcrypt or argon2 hashing
- Never store real passwords in Firestore
- Use Firebase Auth as primary authentication method

## Automated One-Time Migration Script (Dart)

You can create a one-time migration function in your Flutter app - run it once to migrate all existing users:

```dart
// In your admin panel or separate app
import 'package:crypto/crypto.dart'; // Add to pubspec.yaml

Future<void> migrateExistingUsersPasswordHash() async {
  final db = FirebaseFirestore.instance;
  final querySnapshot = await db.collection('users').get();
  
  int updatedCount = 0;
  
  for (var doc in querySnapshot.docs) {
    final passwordHash = doc.data()['passwordHash'];
    
    // Check if passwordHash is missing or empty
    if (passwordHash == null || (passwordHash is String && passwordHash.isEmpty)) {
      // For security, you should NOT generate hash without knowing password
      // Instead, mark for manual review
      await doc.reference.update({
        'migrationStatus': 'needs_password_reset',
        'lastMigrationCheck': DateTime.now(),
      });
      updatedCount++;
    }
  }
  
  print('Updated $updatedCount users for migration');
}
```

## Contact & Support

If users report login issues after this update:
1. Check if `passwordHash` field exists in their Firestore user document
2. If missing, apply one of the solutions above
3. Ask user to try "Forgot Password" to force a reset with new hash
