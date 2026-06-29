# 📚 Assignment 3 & 4 - Complete Implementation Guide

## ✅ Assignment 3: Firebase Authentication

### Implemented Features:

#### 1. **Login** ✅
- **File:** `lib/ui/auth/login_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `signIn()`
- **Repository:** `lib/repository/auth_repository.dart` → `signIn()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `signInWithEmailAndPassword()`

**Flow:**
```
LoginScreen → AuthViewModel.signIn() → AuthRepository.signIn() → FirebaseAuthService.signInWithEmailAndPassword()
```

#### 2. **Signup** ✅
- **File:** `lib/ui/auth/signup_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `signUp()`
- **Repository:** `lib/repository/auth_repository.dart` → `signUp()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `signUpWithEmailAndPassword()`

**Flow:**
```
SignupScreen → AuthViewModel.signUp() → AuthRepository.signUp() → FirebaseAuthService.signUpWithEmailAndPassword()
```

#### 3. **Reset Password (Forgot Password)** ✅
- **File:** `lib/ui/auth/forgot_password_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `sendPasswordResetEmail()`
- **Repository:** `lib/repository/auth_repository.dart` → `sendPasswordResetEmail()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `sendPasswordResetEmail()`

**Flow:**
```
ForgotPasswordScreen → AuthViewModel.sendPasswordResetEmail() → AuthRepository.sendPasswordResetEmail() → FirebaseAuthService.sendPasswordResetEmail()
```

**Access:** Login Screen → "Forgot Password?" button → Enter email → Receive reset link

#### 4. **Change Password** ✅
- **File:** `lib/ui/auth/change_password_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `changePassword()`
- **Repository:** `lib/repository/auth_repository.dart` → `changePassword()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `changePassword()`

**Flow:**
```
ChangePasswordScreen → AuthViewModel.changePassword() → AuthRepository.changePassword() → FirebaseAuthService.changePassword()
```

**Access:** Profile Screen → "Change Password" → Enter current & new password

#### 5. **Logout** ✅
- **File:** `lib/ui/profile/profile_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `signOut()`
- **Repository:** `lib/repository/auth_repository.dart` → `signOut()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `signOut()`

**Flow:**
```
ProfileScreen → AuthViewModel.signOut() → AuthRepository.signOut() → FirebaseAuthService.signOut()
```

**Access:** Profile Screen → "Logout" button → Confirm → Sign out

#### 6. **Email Verification** ✅
- **File:** `lib/ui/profile/profile_screen.dart`
- **ViewModel:** `lib/view_models/auth_view_model.dart` → `sendEmailVerification()`, `checkEmailVerification()`
- **Repository:** `lib/repository/auth_repository.dart` → `sendEmailVerification()`, `isEmailVerified`, `reloadUser()`
- **Service:** `lib/data/services/firebase_auth_service.dart` → `sendEmailVerification()`, `isEmailVerified`, `reloadUser()`

**Flow:**
```
ProfileScreen → AuthViewModel.sendEmailVerification() → AuthRepository.sendEmailVerification() → FirebaseAuthService.sendEmailVerification()
```

**Access:** Profile Screen → "Email Verification" → Send verification email → Check status

---

## 🏗️ MVVM Architecture Implementation

### Model Layer
- **Location:** `lib/data/models/`
- **Files:**
  - `user_model.dart` - User data model
  - `antique_model.dart` - Antique/Product model
  - `bid_model.dart` - Bid data model

### View Layer
- **Location:** `lib/ui/`
- **Screens:**
  - `auth/` - Login, Signup, Forgot Password, Change Password
  - `home/` - Home screen with auctions
  - `antique/` - Antique detail screen
  - `profile/` - User profile
  - `dashboard/` - Main navigation

### ViewModel Layer
- **Location:** `lib/view_models/`
- **Files:**
  - `auth_view_model.dart` - Authentication logic
  - `antique_view_model.dart` - Antique management
  - `bid_view_model.dart` - Bidding logic
  - `profile_view_model.dart` - Profile management
  - `dashboard_view_model.dart` - Navigation

### Repository Layer
- **Location:** `lib/repository/`
- **Files:**
  - `auth_repository.dart` - Auth data layer
  - `antique_repository.dart` - Antique data layer
  - `bid_repository.dart` - Bid data layer

### Service Layer
- **Location:** `lib/data/services/`
- **Files:**
  - `firebase_auth_service.dart` - Firebase Auth integration
  - `firestore_service.dart` - Firestore operations
  - `storage_service.dart` - Firebase Storage

---

## 📦 State Management with GetX

### 1. **Observable State** (.obs)
```dart
final isLoading = false.obs;
final currentUser = Rx<UserModel?>(null);
final antiques = <AntiqueModel>[].obs;
```

### 2. **State Updates**
```dart
isLoading.value = true;
currentUser.value = user;
antiques.value = data;
```

### 3. **Reactive UI** (Obx)
```dart
Obx(() {
  return authViewModel.isLoading.value
    ? CircularProgressIndicator()
    : ElevatedButton();
});
```

### Files Using State Management:
- ✅ `auth_view_model.dart`
- ✅ `antique_view_model.dart`
- ✅ `bid_view_model.dart`
- ✅ `profile_view_model.dart`
- ✅ `dashboard_view_model.dart`

---

## 💉 Dependency Injection with GetX

### Bindings:
- **Location:** `lib/bindings/`
- **Files:**
  - `auth_binding.dart` - Injects AuthViewModel
  - `antique_binding.dart` - Injects AntiqueViewModel
  - `dashboard_binding.dart` - Injects DashboardViewModel

### Example:
```dart
class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthViewModel>(() => AuthViewModel());
  }
}
```

### Usage in Routes:
```dart
GetPage(
  name: AppRoutes.login,
  page: () => const LoginScreen(),
  binding: AuthBinding(), // DI here
),
```

---

## 🗺️ Named Routing with GetX

### Route Configuration:
- **File:** `lib/routes/app_routes.dart`

### Defined Routes:
```dart
// Auth Routes
static const String login = '/login';
static const String signup = '/signup';
static const String forgotPassword = '/forgot-password';
static const String changePassword = '/change-password';

// Main Routes
static const String dashboard = '/dashboard';
static const String home = '/home';
static const String antiqueDetail = '/antique-detail';
static const String addAntique = '/add-antique';
static const String editAntique = '/edit-antique';
```

### Navigation Examples:
```dart
// Navigate to login
Get.toNamed(AppRoutes.login);

// Navigate and remove all previous routes
Get.offAllNamed(AppRoutes.dashboard);

// Navigate with arguments
Get.toNamed(AppRoutes.antiqueDetail, arguments: antiqueId);

// Go back
Get.back();
```

---

## ✅ Assignment 4: Firestore Implementation

### Main Entity: **Antique (Product)**

#### 1. **CREATE Operation** ✅
- **File:** `lib/view_models/antique_view_model.dart` → `createAntique()`
- **Repository:** `lib/repository/antique_repository.dart` → `createAntique()`
- **Service:** `lib/data/services/firestore_service.dart` → `createAntique()`

**Code:**
```dart
await _firestoreService.antiquesCollection.doc(antiqueId).set(antique.toMap());
```

#### 2. **READ Operations** ✅

**Single Read:**
```dart
Future<AntiqueModel?> getAntique(String antiqueId) async {
  final doc = await _firestore.collection('antiques').doc(antiqueId).get();
  return AntiqueModel.fromSnapshot(doc);
}
```

**Query with Filters:**
```dart
Future<List<AntiqueModel>> getActiveAntiques() async {
  final snapshot = await _firestore
      .collection('antiques')
      .where('isActive', isEqualTo: true)
      .orderBy('createdAt', descending: true)
      .get();
  return snapshot.docs.map((doc) => AntiqueModel.fromSnapshot(doc)).toList();
}
```

**Stream (Real-time):**
```dart
Stream<List<AntiqueModel>> streamActiveAntiques() {
  return _firestore
      .collection('antiques')
      .where('isActive', isEqualTo: true)
      .snapshots()
      .map((snapshot) => 
        snapshot.docs.map((doc) => AntiqueModel.fromSnapshot(doc)).toList()
      );
}
```

#### 3. **UPDATE Operation** ✅
- **File:** `lib/view_models/antique_view_model.dart` → `updateAntiqueDetails()`
- **Repository:** `lib/repository/antique_repository.dart` → `updateAntique()`
- **Service:** `lib/data/services/firestore_service.dart` → `updateAntique()`

**Code:**
```dart
await _firestoreService.updateAntique(antiqueId, {
  'title': title,
  'description': description,
  'basePrice': basePrice,
});
```

#### 4. **DELETE Operation** ✅
- **File:** `lib/view_models/antique_view_model.dart` → `deleteAntique()`
- **Repository:** `lib/repository/antique_repository.dart` → `deleteAntique()`

**Code:**
```dart
await _firestoreService.updateAntique(antiqueId, {
  'isActive': false,
  'bidEndTime': DateTime.now(),
});
```

---

## 🔍 Firestore Queries Implemented

### 1. **Simple Query**
```dart
.where('isActive', isEqualTo: true)
```

### 2. **Ordering**
```dart
.orderBy('createdAt', descending: true)
```

### 3. **Filtering by Seller**
```dart
.where('sellerId', isEqualTo: userId)
```

### 4. **Filtering by Category**
```dart
.where('category', isEqualTo: selectedCategory)
```

### 5. **Complex Query**
```dart
_firestore
  .collection('antiques')
  .where('isActive', isEqualTo: true)
  .where('category', isEqualTo: category)
  .orderBy('currentBid', descending: true)
  .limit(5)
```

---

## 📊 Firestore Streams (Real-time Updates)

### Implementation Files:
1. **firestore_service.dart** - Stream methods
2. **antique_view_model.dart** - Stream listeners
3. **home_screen.dart** - UI updates

### Example:
```dart
void loadAntiques() {
  _antiqueRepository.streamActiveAntiques().listen((data) {
    activeAntiques.value = data; // Automatic UI update
  });
}
```

### Features Using Streams:
- ✅ Real-time auction updates
- ✅ Live bid notifications
- ✅ Automatic UI refresh
- ✅ Featured carousel updates
- ✅ Analytics dashboard updates

---

## 📁 Complete Project Structure

```
lib/
├── data/
│   ├── models/              # Data models
│   │   ├── user_model.dart
│   │   ├── antique_model.dart
│   │   └── bid_model.dart
│   └── services/            # Firebase services
│       ├── firebase_auth_service.dart
│       ├── firestore_service.dart
│       └── storage_service.dart
├── repository/              # Data repositories
│   ├── auth_repository.dart
│   ├── antique_repository.dart
│   └── bid_repository.dart
├── view_models/             # Business logic
│   ├── auth_view_model.dart
│   ├── antique_view_model.dart
│   ├── bid_view_model.dart
│   └── profile_view_model.dart
├── ui/                      # User interface
│   ├── auth/
│   │   ├── login_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   └── change_password_screen.dart
│   ├── home/
│   ├── antique/
│   ├── profile/
│   └── widgets/
├── routes/
│   └── app_routes.dart      # Named routes
├── bindings/                # Dependency injection
│   ├── auth_binding.dart
│   ├── antique_binding.dart
│   └── dashboard_binding.dart
└── theme/                   # App styling
    ├── app_colors.dart
    └── app_theme.dart
```

---

## 🎯 Assignment Checklist

### Assignment 3: ✅ Complete
- [x] Login
- [x] Signup
- [x] Reset Password (Forgot Password)
- [x] Change Password
- [x] Logout
- [x] Email Verification
- [x] MVVM Architecture
- [x] State Management (GetX)
- [x] Dependency Injection (GetX)
- [x] Named Routing (GetX)

### Assignment 4: ✅ Complete
- [x] Firestore CREATE (Admin add antique)
- [x] Firestore READ (Get antiques)
- [x] Firestore UPDATE (Edit antique)
- [x] Firestore DELETE (Delete antique)
- [x] Firestore Queries (Filter, Sort)
- [x] Firestore Streams (Real-time)
- [x] Main Entity: Antique ✅

---

## 🔥 Quiz 4 Preparation

### Topics Covered:

1. **CRUD Operations** ✅
   - Create: `createAntique()`
   - Read: `getAntique()`, `streamAntiques()`
   - Update: `updateAntique()`
   - Delete: `deleteAntique()`

2. **Queries** ✅
   - Where clause: `.where('isActive', isEqualTo: true)`
   - OrderBy: `.orderBy('createdAt', descending: true)`
   - Limit: `.limit(10)`
   - Multiple conditions

3. **Streams** ✅
   - Real-time updates: `.snapshots()`
   - Listen to changes: `.listen((data) {})`
   - Automatic UI refresh with Obx()

---

## 📱 Demo Flow for Viva

### 1. Authentication Demo:
1. Open app → Shows login screen
2. Click "Forgot Password" → Enter email → Show success
3. Click "Sign Up" → Create account
4. Login with new account
5. Go to Profile → "Change Password" → Change it
6. Go to Profile → "Email Verification" → Send email
7. Logout

### 2. Firestore Demo:
1. Login as Admin
2. Click FAB → "Add Auction" (CREATE)
3. Home screen shows real-time list (READ + STREAM)
4. Click auction → Click Edit (UPDATE)
5. Save changes → See instant update
6. Delete auction → Confirm (DELETE)
7. Show filtering by category (QUERY)
8. Show analytics updating in real-time (STREAM)

---

## 💡 Key Points for Sir

1. **Clean Architecture**: Clear separation of concerns (Model-View-ViewModel)
2. **GetX Ecosystem**: State management, DI, Routing - all using GetX
3. **Firebase Integration**: Auth + Firestore + Storage
4. **Real-time Updates**: Firestore streams for live data
5. **Professional UI**: Material Design with custom theme
6. **Complete CRUD**: All operations on main entity (Antique)
7. **Advanced Queries**: Filtering, sorting, limiting
8. **Error Handling**: Try-catch blocks with user feedback

---

**Project Status: ✅ Ready for Demo & Viva**
