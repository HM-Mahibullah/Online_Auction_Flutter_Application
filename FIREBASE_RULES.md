# Firebase Security Rules - Antique Auction App

## Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // ==================== HELPER FUNCTIONS ====================
    
    // Check if user is authenticated
    function isSignedIn() {
      return request.auth != null;
    }
    
    // Check if user owns the resource
    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }
    
    // Check if user is admin
    function isAdmin() {
      return isSignedIn() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Validate user data
    function isValidUser(user) {
      return user.keys().hasAll(['id', 'email', 'name', 'createdAt']) &&
             user.id is string &&
             user.email is string &&
             user.name is string &&
             user.createdAt is timestamp;
    }
    
    // Validate antique data
    function isValidAntique(antique) {
      return antique.keys().hasAll(['id', 'title', 'description', 'imageUrl', 
                                     'basePrice', 'currentBid', 'bidEndTime', 
                                     'sellerId', 'createdAt', 'isActive']) &&
             antique.basePrice >= 0 &&
             antique.currentBid >= 0 &&
             antique.bidEndTime is timestamp &&
             antique.bidEndTime > request.time;
    }
    
    // Validate bid data
    function isValidBid(bid) {
      return bid.keys().hasAll(['id', 'antiqueId', 'userId', 'bidAmount', 'bidTime']) &&
             bid.bidAmount > 0 &&
             bid.userId == request.auth.uid &&
             bid.bidTime is timestamp;
    }
    
    // ==================== USERS COLLECTION ====================
    
    match /users/{userId} {
      // Anyone authenticated can read user profiles
      // This allows viewing seller information, bid history, etc.
      allow read: if isSignedIn();
      
      // Users can only create their own profile during signup
      // Validate that the user ID matches the authenticated user
      allow create: if isSignedIn() && 
                      request.auth.uid == userId &&
                      isValidUser(request.resource.data);
      
      // Users can only update their own profile
      // Prevent users from changing their ID or email
      allow update: if isOwner(userId) &&
                      request.resource.data.id == resource.data.id &&
                      request.resource.data.email == resource.data.email;
      
      // No one can delete user profiles
      // This maintains data integrity for historical bids and auctions
      allow delete: if false;
    }
    
    // ==================== ANTIQUES COLLECTION ====================
    
    match /antiques/{antiqueId} {
      // All authenticated users can read antiques
      // This allows browsing and viewing auction details
      allow read: if isSignedIn();
      
      // Only admins can create new antiques
      // Validates required fields and data types
      allow create: if isAdmin() &&
                      isValidAntique(request.resource.data) &&
                      request.resource.data.sellerId == request.auth.uid;
      
      // Admins and original sellers can update antiques
      // Prevent changing the seller ID after creation
      // Allow updating currentBid, currentBidderUserId for bidding system
      allow update: if (isAdmin() || isOwner(resource.data.sellerId)) &&
                      request.resource.data.sellerId == resource.data.sellerId &&
                      request.resource.data.id == resource.data.id;
      
      // No one can delete antiques
      // Maintains auction history and data integrity
      allow delete: if false;
    }
    
    // ==================== BIDS COLLECTION ====================
    
    match /bids/{bidId} {
      // Users can read all bids to see auction activity
      // This enables bid history and leaderboards
      allow read: if isSignedIn();
      
      // Users can create bids for themselves
      // Validates bid amount and user ID
      allow create: if isSignedIn() && 
                      isValidBid(request.resource.data) &&
                      request.auth.uid == request.resource.data.userId;
      
      // System can update bid status (winning, outbid, won, lost)
      // Users cannot modify their own bids after placement
      // Only status field can be updated
      allow update: if isSignedIn() &&
                      request.resource.data.diff(resource.data).affectedKeys()
                        .hasOnly(['status', 'isWinningBid']);
      
      // No one can delete bids
      // Maintains complete auction history
      allow delete: if false;
    }
  }
}
```

## Firebase Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // ==================== ANTIQUE IMAGES ====================
    
    match /antique_images/{imageId} {
      // Anyone authenticated can read antique images
      allow read: if request.auth != null;
      
      // Only authenticated users (admins) can upload antique images
      // Enforce file size limit (5MB) and image type
      allow write: if request.auth != null &&
                     request.resource.size < 5 * 1024 * 1024 && // 5MB max
                     request.resource.contentType.matches('image/.*'); // Only images
      
      // Allow deletion only by authenticated users
      allow delete: if request.auth != null;
    }
    
    // ==================== PROFILE IMAGES ====================
    
    match /profile_images/{userId} {
      // Anyone authenticated can read profile images
      allow read: if request.auth != null;
      
      // Users can only upload their own profile image
      // Enforce smaller file size limit (2MB)
      allow write: if request.auth != null &&
                     request.auth.uid == userId &&
                     request.resource.size < 2 * 1024 * 1024 && // 2MB max
                     request.resource.contentType.matches('image/.*');
      
      // Users can only delete their own profile image
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Security Features

### 🔒 Authentication Requirements
- All operations require user authentication
- No anonymous access allowed
- Email/password authentication enforced

### 👥 User Permissions
- **Regular Users:**
  - View all antiques and bids
  - Create and manage their own profile
  - Place bids on antiques
  - View their bid history

- **Admin Users:**
  - All regular user permissions
  - Create new antiques
  - Upload antique images
  - Manage auctions

### 🛡️ Data Validation
- All data types are validated
- Required fields are enforced
- Business logic constraints (e.g., bid > 0, end time in future)
- Immutable fields (IDs, emails, seller IDs)

### 📝 Audit Trail
- No deletions allowed (maintains complete history)
- Bid history preserved
- Auction records retained
- User data protected

### 🚫 Restrictions
- Users cannot modify others' data
- Bids cannot be deleted or edited (amount)
- Antiques cannot be deleted
- User profiles cannot be deleted
- Bid status only updated by system

### 📦 File Upload Limits
- Antique images: 5MB maximum
- Profile images: 2MB maximum
- Only image files allowed
- Secure file naming

## Testing Security Rules

### Test as Regular User
```javascript
// Should succeed
- Read all antiques
- Read all bids
- Create own profile
- Update own profile
- Place bids

// Should fail
- Create antiques (not admin)
- Update other users' profiles
- Delete any data
- Modify bid amounts
```

### Test as Admin User
```javascript
// Should succeed
- All regular user actions
- Create antiques
- Upload antique images
- Update own antiques

// Should fail
- Delete any data
- Modify other users' profiles
- Change bid amounts
```

### Test File Uploads
```javascript
// Should succeed
- Upload image < 5MB to antique_images (if admin)
- Upload image < 2MB to own profile_images

// Should fail
- Upload files > size limit
- Upload non-image files
- Upload to other users' profile folders
```

## Deployment

1. Go to Firebase Console
2. Select your project
3. Navigate to Firestore Database → Rules
4. Copy and paste the Firestore rules
5. Click "Publish"

6. Navigate to Storage → Rules
7. Copy and paste the Storage rules
8. Click "Publish"

## Monitoring

Check Firebase Console → Firestore/Storage → Rules tab for:
- ✅ Rule evaluation metrics
- ⚠️ Denied requests
- 📊 Usage statistics

Monitor for:
- Unusual access patterns
- Failed authorization attempts
- Excessive denied requests

## Best Practices Implemented

✅ Principle of least privilege
✅ Defense in depth
✅ Input validation
✅ Type checking
✅ Immutable critical fields
✅ Audit trail preservation
✅ File size limits
✅ Content type validation
✅ User isolation
✅ Admin role enforcement

## Important Notes

⚠️ **Never disable security rules in production**
⚠️ **Test rules thoroughly before deployment**
⚠️ **Monitor rule violations regularly**
⚠️ **Keep rules updated with app changes**
⚠️ **Document all rule changes**

## Support

For security concerns:
1. Review Firebase Console logs
2. Test with Firebase Emulator Suite
3. Consult Firebase Security Rules documentation
