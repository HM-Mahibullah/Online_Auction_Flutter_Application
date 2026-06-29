# Firestore Composite Indexes Setup Guide

## Problem Identified

Your app uses queries with **WHERE clause + ORDER BY**, which require composite indexes in Firestore.

### Queries Requiring Indexes:

**BIDS Collection:**
1. `where('userId', isEqualTo: X).orderBy('bidTime', descending: true)`
2. `where('antiqueId', isEqualTo: X).orderBy('bidTime', descending: true)`

**ANTIQUES Collection:**
3. `where('isActive', isEqualTo: true).orderBy('bidEndTime', descending: false)`
4. `where('sellerId', isEqualTo: X).orderBy('createdAt', descending: true)`

---

## Solution: Create Composite Indexes

### Method 1: Automatic (Easy via Error Link)

When you see the "Error loading bids" message, there's a link like:
```
https://console.firebase.google.com/v1/r/project/biddingsystem-a9d3c/firestore/indexes?create_composite=...
```

**Simply click that link** - it will take you directly to create the missing index!

---

### Method 2: Manual Creation in Firebase Console

1. **Go to Firebase Console**:
   - Open [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Navigate to: **Firestore Database → Indexes**

2. **Click "Add Index" button**

3. **Create Index 1 - User Bids**:
   - Collection ID: `bids`
   - Fields:
     - Field 1: `userId` (Ascending)
     - Field 2: `bidTime` (Descending)
   - Query scope: **Collection**
   - Click **Create Index**

4. **Create Index 2 - Antique Bids**:
   - Collection ID: `bids`
   - Fields:
     - Field 1: `antiqueId` (Ascending)
     - Field 2: `bidTime` (Descending)
   - Query scope: **Collection**
   - Click **Create Index**

5. **Create Index 3 - Active Antiques by End Time**:
   - Collection ID: `antiques`
   - Fields:
     - Field 1: `isActive` (Ascending)
     - Field 2: `bidEndTime` (Ascending)
   - Query scope: **Collection**
   - Click **Create Index**

6. **Create Index 4 - Seller Antiques**:
   - Collection ID: `antiques`
   - Fields:
     - Field 1: `sellerId` (Ascending)
     - Field 2: `createdAt` (Descending)
   - Query scope: **Collection**
   - Click **Create Index**

---

## Visual Reference

| Collection | Field 1 | Order 1 | Field 2 | Order 2 | Purpose |
|-----------|---------|--------|---------|--------|---------|
| bids | userId | Asc | bidTime | Desc | Get user's bids sorted by time |
| bids | antiqueId | Asc | bidTime | Desc | Get all bids for an antique |
| antiques | isActive | Asc | bidEndTime | Asc | Get active antiques by end time |
| antiques | sellerId | Asc | createdAt | Desc | Get seller's antiques by creation date |

---

## Building Process

After creating each index:
- **Building**: Will show "Building" status for a few seconds to minutes
- **Enabled**: When ready, status becomes "Enabled" (green checkmark)
- **Wait**: Don't retry the app until index is "Enabled"

---

## Updated Firestore Rules (Include with Indexes)

Make sure your Firestore Rules are also updated:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
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
    
    // Users Collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() && 
                      request.auth.uid == userId &&
                      request.resource.data.keys().hasAll(['email', 'name', 'createdAt']);
      allow update: if isOwner(userId);
      allow delete: if isAdmin();
    }
    
    // Antiques Collection
    match /antiques/{antiqueId} {
      allow read: if isAuthenticated();
      allow create: if isAdmin() && 
              request.resource.data.keys().hasAll(['title', 'description', 'basePrice', 'currentBid', 'bidEndTime', 'curatorId', 'isActive', 'totalBids']) &&
              request.resource.data.basePrice > 0 &&
              request.resource.data.currentBid == request.resource.data.basePrice &&
              request.resource.data.bidEndTime > request.time &&
              request.resource.data.totalBids == 0;
      allow update: if isAdmin();
      allow delete: if isAdmin();
    }
    
    // Bids Collection
    match /bids/{bidId} {
      allow read: if isAuthenticated();
      allow create: if isAuthenticated() &&
                      request.resource.data.keys().hasAll(['userId', 'antiqueId', 'bidAmount', 'bidTime']) &&
                      request.resource.data.userId == request.auth.uid &&
                      request.resource.data.bidAmount > 0 &&
                      request.resource.data.bidTime == request.time;
      allow update: if isAuthenticated() && 
                      (isOwner(resource.data.userId) || isAdmin());
      allow delete: if isAdmin();
    }
    
    // Notifications Collection
    match /notifications/{notificationId} {
      allow read: if isAuthenticated() && isOwner(resource.data.userId);
      allow create: if request.auth.uid == null && 
                       request.resource.data.keys().hasAll(['userId', 'message', 'createdAt']);
      allow update: if isAuthenticated() && isOwner(resource.data.userId);
      allow delete: if isAuthenticated() && isOwner(resource.data.userId);
    }
  }
}
```

---

## Troubleshooting

### Index Already Exists?
If you see "This index already exists", you have previously created it.
- Just refresh your app - it should work now

### Index Still Building?
- Wait a few minutes for it to finish building
- Don't retry queries while still building

### Still Getting Error?
1. Check index status is "**Enabled**" (not Building or Error)
2. Restart the app: 
   ```bash
   flutter clean
   flutter run
   ```
3. Check console logs for the exact error
4. Verify field names match exactly (case-sensitive!)

---

## Testing After Indexes Created

1. **Create user, sign up, and login**
2. **Create some antiques** (or get them from database)
3. **Place some bids**
4. **Navigate to "My Bids" tab**
5. ✅ Should see bids load without error
6. ✅ All queries should work smoothly

---

## Summary

| Collection | Index | Fields | Status |
|-----------|-------|--------|--------|
| bids | Index 1 | userId ↑, bidTime ↓ | ❌ Create |
| bids | Index 2 | antiqueId ↑, bidTime ↓ | ❌ Create |
| antiques | Index 3 | isActive ↑, bidEndTime ↑ | ❌ Create |
| antiques | Index 4 | sellerId ↑, createdAt ↓ | ❌ Create |

**Next Step**: Go to Firebase Console → Firestore → Indexes and create these 4 indexes!

---

## Notes

- **Why Composite Indexes?**: Firestore requires them for queries with WHERE + ORDER BY on different fields
- **Cost**: Indexes have minimal cost, only charged for writes
- **Time**: Each index takes a few seconds to minutes to build
- **Free Tier**: You get plenty of index quota on free tier
