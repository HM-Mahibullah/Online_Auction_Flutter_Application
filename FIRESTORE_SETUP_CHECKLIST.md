# Firestore Complete Setup Checklist

## ✅ Database Collections Structure

Your database should have these collections:

### 1. **users** Collection
```
Collection: users
├─ Documents: {userId}
   ├─ id: "firebase_uid"
   ├─ email: "user@test.com"
   ├─ name: "User Name"
   ├─ phoneNumber: "+923001234567"
   ├─ isAdmin: false
   ├─ createdAt: Timestamp(2024-04-10)
   ├─ totalBids: 0
   ├─ wonAuctions: 0
   └─ passwordHash: "hashcode"
```

### 2. **antiques** Collection
```
Collection: antiques
├─ Documents: {antiqueId}
   ├─ id: "unique_id"
   ├─ title: "Ancient Vase"
   ├─ description: "Beautiful ancient vase..."
   ├─ basePrice: 5000
   ├─ currentBid: 5000
   ├─ curatorId: "admin_user_id"
   ├─ sellerId: "seller_user_id"
   ├─ isActive: true
   ├─ totalBids: 5
   ├─ bidEndTime: Timestamp(2024-04-15)
   ├─ createdAt: Timestamp(2024-04-10)
   ├─ imageUrl: "https://..."
   └─ category: "Vases"
```

### 3. **bids** Collection
```
Collection: bids
├─ Documents: {bidId}
   ├─ id: "unique_bid_id"
   ├─ userId: "user_firebase_uid"
   ├─ antiqueId: "antique_id"
   ├─ bidAmount: 5500
   ├─ bidTime: Timestamp(2024-04-10)
   ├─ status: "active" or "lost" or "won"
   └─ transactionId: "optional_transaction_id"
```

### 4. **notifications** Collection
```
Collection: notifications
├─ Documents: {notificationId}
   ├─ userId: "user_firebase_uid"
   ├─ message: "Your bid was outbid!"
   ├─ createdAt: Timestamp(2024-04-10)
   ├─ type: "bid" or "auction" or "system"
   └─ read: false
```

---

## 🔑 Field Names (Case-Sensitive!)

⚠️ **IMPORTANT**: Field names must match EXACTLY!

| Collection | Field | Type | Required |
|-----------|-------|------|----------|
| **users** | id | String | ✅ |
| | email | String | ✅ |
| | name | String | ✅ |
| | phoneNumber | String | ❌ |
| | isAdmin | Boolean | ✅ |
| | createdAt | Timestamp | ✅ |
| | totalBids | Number | ❌ |
| | wonAuctions | Number | ❌ |
| | passwordHash | String | ✅ |
| **antiques** | id | String | ✅ |
| | title | String | ✅ |
| | description | String | ✅ |
| | basePrice | Number | ✅ |
| | currentBid | Number | ✅ |
| | curatorId | String | ✅ |
| | sellerId | String | ✅ |
| | isActive | Boolean | ✅ |
| | totalBids | Number | ✅ |
| | bidEndTime | Timestamp | ✅ |
| | createdAt | Timestamp | ✅ |
| | imageUrl | String | ❌ |
| | category | String | ❌ |
| **bids** | id | String | ✅ |
| | userId | String | ✅ |
| | antiqueId | String | ✅ |
| | bidAmount | Number | ✅ |
| | bidTime | Timestamp | ✅ |
| | status | String | ❌ |
| | transactionId | String | ❌ |
| **notifications** | userId | String | ✅ |
| | message | String | ✅ |
| | createdAt | Timestamp | ✅ |
| | type | String | ❌ |
| | read | Boolean | ❌ |

---

## 📑 Composite Indexes Needed

These indexes MUST be created for queries to work:

### Index 1: User Bids
```
Collection: bids
Field 1: userId (Ascending ↑)
Field 2: bidTime (Descending ↓)
Purpose: Query user's bids sorted by time
```

### Index 2: Antique Bids
```
Collection: bids
Field 1: antiqueId (Ascending ↑)
Field 2: bidTime (Descending ↓)
Purpose: Get all bids for an antique sorted by time
```

### Index 3: Active Antiques by End Time
```
Collection: antiques
Field 1: isActive (Ascending ↑)
Field 2: bidEndTime (Ascending ↑)
Purpose: Get active antiques sorted by end time
```

### Index 4: Seller Antiques
```
Collection: antiques
Field 1: sellerId (Ascending ↑)
Field 2: createdAt (Descending ↓)
Purpose: Get seller's antiques sorted by creation date
```

---

## 🔐 Security Rules

Your Firestore Security Rules should be:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isAdmin() {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.get('isAdmin', false) == true;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.auth.uid == userId &&
                      request.resource.data.keys().hasAll(['email', 'name', 'createdAt']);
      allow update: if isOwner(userId);
      allow delete: if isAdmin();
    }
    
    // Antiques
    match /antiques/{antiqueId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && 
              request.resource.data.keys().hasAll(['title', 'description', 'basePrice', 'currentBid', 'bidEndTime', 'curatorId', 'isActive', 'totalBids']);
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Bids
    match /bids/{bidId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
                      request.resource.data.keys().hasAll(['userId', 'antiqueId', 'bidAmount', 'bidTime']) &&
                      request.resource.data.userId == request.auth.uid;
      allow update: if isAuthenticated() && 
                      (isOwner(resource.data.userId) || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Notifications
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if request.auth.uid == null;
      allow update: if isAuthenticated() && isOwner(resource.data.userId);
      allow delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
  }
}
```

---

## 🚀 Complete Setup Steps

### Phase 1: Database Structure
- [ ] Create **users** collection
- [ ] Create **antiques** collection
- [ ] Create **bids** collection
- [ ] Create **notifications** collection

### Phase 2: Field Names Verification
- [ ] Verify all field names match exactly (case-sensitive)
- [ ] Verify field types are correct (String, Number, Timestamp, Boolean)

### Phase 3: Composite Indexes
- [ ] Create Index 1: bids (userId ↑, bidTime ↓)
- [ ] Create Index 2: bids (antiqueId ↑, bidTime ↓)
- [ ] Create Index 3: antiques (isActive ↑, bidEndTime ↑)
- [ ] Create Index 4: antiques (sellerId ↑, createdAt ↓)
- [ ] Wait for all indexes to show "Enabled" ✅

### Phase 4: Security Rules
- [ ] Go to Firestore → Rules
- [ ] Update with all rules above
- [ ] Click "Publish"

### Phase 5: Test Application
- [ ] Run: `flutter clean && flutter run`
- [ ] Create account (test user created in Firestore)
- [ ] Create antiques (if admin)
- [ ] Place bids
- [ ] Check "My Bids" tab
- [ ] Verify no errors

---

## 📊 Data Flow in App

```
Sign Up
  ↓
User Document Created in Firestore
  ↓
Sign In
  ↓
Load User Data
  ↓
Browse Antiques
  ↓
Query: antiques (isActive=true, orderBy bidEndTime)
  └─→ Needs Index 3
  ↓
Place Bid
  ↓
Bid Document Created in bids Collection
  ↓
View My Bids
  ↓
Query: bids (userId=currentUser, orderBy bidTime)
  └─→ Needs Index 1
  ↓
View Antique Bids
  ↓
Query: bids (antiqueId=X, orderBy bidTime)
  └─→ Needs Index 2
```

---

## 🔍 Verification Queries

These queries will happen in your app:

### From bid_view_model.dart:
```dart
// Index 1 required
bidsCollection
  .where('userId', isEqualTo: userId)
  .orderBy('bidTime', descending: true)

// Index 2 required
bidsCollection
  .where('antiqueId', isEqualTo: antiqueId)
  .orderBy('bidTime', descending: true)
```

### From antique_view_model.dart (or similar):
```dart
// Index 3 required
antiquesCollection
  .where('isActive', isEqualTo: true)
  .orderBy('bidEndTime', descending: false)

// Index 4 required
antiquesCollection
  .where('sellerId', isEqualTo: sellerId)
  .orderBy('createdAt', descending: true)
```

---

## ✅ Final Testing

After everything is set up:

```bash
flutter clean
flutter pub get
flutter run
```

**Expected Results:**
- ✅ Signup works → user created in Firestore
- ✅ Login works → user data loaded
- ✅ Browse antiques → no errors
- ✅ Place bid → bid created in Firestore
- ✅ View "My Bids" → loads instantly without index error
- ✅ All queries execute quickly

---

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| "Query requires index error" | Create missing composite index |
| "Permission denied" | Check Firestore Security Rules |
| "Field does not exist" | Verify field names exactly match |
| "Index building" | Wait 2-5 minutes for index to build |
| Empty results | Verify data exists in Firestore |
| Slow queries | Ensure all indexes are "Enabled" |

---

## 📞 Quick Reference

**Collections**: users, antiques, bids, notifications
**Indexes**: 4 composite indexes needed
**Rules**: Provided above
**Fields**: Case-sensitive - check spelling!

**Documentation**:
- [QUICK_INDEX_SETUP.md](QUICK_INDEX_SETUP.md) - Fast index creation
- [FIRESTORE_INDEXES_GUIDE.md](FIRESTORE_INDEXES_GUIDE.md) - Detailed index info
- [AUTH_FIX_GUIDE.md](AUTH_FIX_GUIDE.md) - Authentication setup

---

**🎯 Next Step**: Create the 4 composite indexes in Firebase Console!
