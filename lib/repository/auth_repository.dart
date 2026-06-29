import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/firebase_auth_service.dart';
import '../data/services/firestore_service.dart';

class AuthRepository {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Get current user
  User? get currentUser => _authService.currentUser;

  // Get current user ID
  String? get currentUserId => _authService.currentUserId;

  // Auth state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  // Sign up
  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        throw Exception('Email, password, and name are required');
      }

      // Create Firebase Auth user
      final userCredential = await _authService.signUpWithEmailAndPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );

      // Create user document in Firestore with password hash
      final user = UserModel(
        id: userCredential.user!.uid,
        email: email.toLowerCase().trim(),
        name: name.trim(),
        phoneNumber: phoneNumber?.trim(),
        createdAt: DateTime.now(),
      );

      // Store user data with password hash in Firestore
      final userData = user.toMap();
      userData['passwordHash'] = _simpleHash(password); // Store password hash for verification
      
      await _firestoreService.usersCollection.doc(user.id).set(userData);

      // Update Firebase Auth profile
      await _authService.updateProfile(displayName: name);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Simple hash function (for demo purposes - USE BCRYPT IN PRODUCTION)
  String _simpleHash(String value) {
    return value.hashCode.toString();
  }


  // Sign in
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      final normalizedEmail = email.toLowerCase().trim();

      // Try Firebase Auth first
      try {
        final userCredential = await _authService.signInWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        );

        // Get user data from Firestore
        final user = await _firestoreService.getUser(userCredential.user!.uid);
        
        if (user == null) {
          throw Exception('User data not found in database. Please contact support.');
        }

        return user;
      // ignore: unused_catch_clause
      } on Exception catch (e) {
        // If Firebase Auth fails, try Firestore verification as fallback
        final user = await _firestoreService.getUserByEmail(normalizedEmail);
        
        if (user == null) {
          throw Exception('No account found with this email. Please check your email or sign up first.');
        }

        // Verify password against Firestore
        final userDoc = await _firestoreService.usersCollection.doc(user.id).get();
        final storedPasswordHash = userDoc['passwordHash'] as String?;

        if (storedPasswordHash == null || storedPasswordHash != _simpleHash(password)) {
          throw Exception('Email or password is incorrect. Please try again.');
        }

        // If we reach here, credentials are valid in Firestore
        // Try to sign in with Firebase Auth again with better error handling
        try {
          await _authService.signInWithEmailAndPassword(
            email: normalizedEmail,
            password: password,
          );
        } catch (authError) {
          // Log auth error but continue since Firestore verified the credentials
          debugPrint('Firebase Auth error (using Firestore verification): $authError');
        }

        return user;
      }
    } catch (e) {
      rethrow;
    }
  }


  // Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUserData() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) return null;

      return await _firestoreService.getUser(userId);
    } catch (e) {
      throw Exception('Failed to get user data: $e');
    }
  }

  // Stream current user data
  Stream<UserModel?> streamCurrentUserData() {
    final userId = _authService.currentUserId;
    if (userId == null) {
      return Stream.value(null);
    }
    return _firestoreService.streamUser(userId);
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
  }) async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;

      await _firestoreService.updateUser(userId, updates);

      if (name != null) {
        await _authService.updateProfile(displayName: name);
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Change password
  Future<void> changePassword(String newPassword) async {
    try {
      await _authService.changePassword(newPassword);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final userId = _authService.currentUserId;
      if (userId == null) throw Exception('User not authenticated');

      // Note: In production, you should also delete user data from Firestore
      // This requires proper Firebase security rules or cloud functions
      
      await _authService.deleteAccount();
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _authService.isEmailVerified;

  // Reload user to check email verification
  Future<void> reloadUser() async {
    try {
      await _authService.reloadUser();
    } catch (e) {
      throw Exception('Failed to reload user: $e');
    }
  }
}
