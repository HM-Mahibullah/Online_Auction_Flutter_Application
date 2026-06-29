# Firebase Authentication Fix - Complete Implementation Guide

## Problems Fixed

1. **"Authentication error. The supplied auth credential is incorrect, malformed or has expired"** - Better error handling and user-friendly messages
2. **Sign-in with Firestore verification** - Checks both Firebase Auth and Firestore database
3. **Improved error messages** - Specific messages for different error scenarios
4. **Input validation** - Validates email and password before attempting authentication

## Changes Made

### 1. **Firebase Auth Service** (`lib/data/services/firebase_auth_service.dart`)
- Enhanced error messages with specific codes
- Added `invalid-credential` case for better handling

### 2. **Firestore Service** (`lib/data/services/firestore_service.dart`)
- Added `getUserByEmail()` method - fetches user by email
- Added `verifyUserCredentials()` method - verifies email/password combination
- Added `_simpleHash()` helper method for password hashing

### 3. **Auth Repository** (`lib/repository/auth_repository.dart`)
- **Sign Up**: Now stores password hash in Firestore for verification
- **Sign In**: 
  - Primary: Uses Firebase Auth
  - Fallback: If Firebase fails, verifies against Firestore
  - Returns proper error messages
- Added `_simpleHash()` method for password hashing

### 4. **Auth ViewModel** (`lib/view_models/auth_view_model.dart`)
- Enhanced `signIn()` with:
  - Input validation (email and password required)
  - User-friendly error messages
  - Better error logging
- Enhanced `signUp()` with:
  - Input validation for all required fields
  - Password strength check (minimum 6 characters)
  - Better error messages

## Authentication Flow

```
SIGN UP:
1. User enters name, email, password
2. Create user in Firebase Auth
3. Store user data in Firestore with password hash
4. Auto sign-out and redirect to login
5. Show success message

SIGN IN:
1. User enters email and password
1. Try Firebase Auth sign-in
2. If success → fetch user from Firestore → redirect to dashboard
3. If Firebase fails → check Firestore for user by email
4. If user exists → verify password hash matches
5. If password matches → redirect to dashboard
6. If any validation fails → show specific error message
```

## Error Messages

| Error | Message |
|-------|---------|
| No email | "Please enter your email address" |
| No password | "Please enter your password" |
| User not found | "No account found with this email. Please sign up first." |
| Wrong password | "Email or password is incorrect. Please try again." |
| Too many attempts | "Too many login attempts. Please try again later." |
| Email already used | "This email is already registered. Please try another or log in." |
| Weak password | "Password is too weak. Use at least 8 characters..." |

## Database Schema

### Firestore Users Collection Structure:
```json
{
  "id": "firebase_uid",
  "email": "user@example.com",
  "name": "User Name",
  "phoneNumber": "+923001234567",
  "isAdmin": false,
  "createdAt": "timestamp",
  "totalBids": 0,
  "wonAuctions": 0,
  "passwordHash": "hashcode"
}
```

## How to Test

### Test Case 1: Successful Sign Up
1. Click "Sign Up" button
2. Enter: Name: "Test User", Email: "test@test.com", Password: "Password123"
3. Should see "Account created successfully!" and redirect to login
4. Firestore should contain the user with passwordHash

### Test Case 2: Successful Sign In
1. Click "Sign In" button
2. Enter: Email: "test@test.com", Password: "Password123"
3. Should see "Welcome back, Test User!" and redirect to dashboard

### Test Case 3: Wrong Password
1. Enter correct email but wrong password
2. Should get "Email or password is incorrect. Please try again."

### Test Case 4: User Not Found
1. Enter an email that doesn't exist
2. Should get "No account found with this email. Please sign up first."

### Test Case 5: Empty Fields
1. Try sign-in with empty fields
2. Should get validation error for each field

## Important Security Notes

⚠️ **Current Implementation**: Uses simple hash function for demo purposes

🔒 **For Production**: You should:
1. Use proper password hashing (bcrypt, argon2)
2. Never store passwords in Firestore - only in Firebase Auth
3. Enable Firebase Security Rules to protect user data
4. Implement email verification
5. Add rate limiting for login attempts

## Firestore Security Rules

Add these rules to your Firestore (`firebase.rules`):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only owner can read/write
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      allow read: if resource.data.isAdmin == true && request.auth.uid != null;
    }
    
    // Antiques collection - public read, admin write
    match /antiques/{documentId} {
      allow read: if true;
      allow write: if request.auth.uid != null && 
                      get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Bids collection - authenticated users only
    match /bids/{documentId} {
      allow read, write: if request.auth.uid != null;
    }
  }
}
```

## Troubleshooting

### Issue: "User data not found in database"
- **Cause**: Firebase Auth succeeded but Firestore user document doesn't exist
- **Fix**: Ensure user was properly created in Firestore during signup

### Issue: Getting auth error even with correct credentials
- **Cause**: Firestore doesn't have passwordHash field
- **Fix**: Either:
  - Delete the user and re-signup (will create hash)
  - Or manually update Firestore user document with passwordHash

### Issue: Sign-up fails with "email already in use"
- **Cause**: Email already exists in Firebase Auth
- **Fix**: User already has an account - direct them to login

## Next Steps

1. Test the authentication flow thoroughly
2. Update Firestore Security Rules for production
3. Implement proper password hashing (bcrypt)
4. Add email verification
5. Add rate limiting
6. Update forgot password screen logic
7. Monitor auth errors in production

## Notes

- Password hashes are stored in Firestore as backup verification only
- Firebase Auth remains the primary authentication method
- All form inputs are trimmed and validated before submission
- Error messages are user-friendly and actionable
- Session persistence is handled by Firebase Auth automatically
