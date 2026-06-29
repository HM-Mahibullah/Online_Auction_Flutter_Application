const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

/**
 * CRITICAL FIX #2: Automatic Winner/Loser Determination
 * 
 * This function runs every 5 minutes to check for ended auctions
 * and automatically marks winners and losers
 */
exports.finalizeEndedAuctions = functions.pubsub
  .schedule('every 5 minutes')
  .onRun(async (context) => {
    try {
      console.log('Starting auction finalization check...');
      
      const now = admin.firestore.Timestamp.now();
      
      // Get all active antiques that have ended
      const endedAuctionsSnapshot = await db.collection('antiques')
        .where('isActive', '==', true)
        .where('bidEndTime', '<=', now)
        .get();
      
      if (endedAuctionsSnapshot.empty) {
        console.log('No ended auctions to finalize');
        return null;
      }
      
      console.log(`Found ${endedAuctionsSnapshot.size} ended auctions to finalize`);
      
      const batch = db.batch();
      let processedCount = 0;
      
      for (const antiqueDoc of endedAuctionsSnapshot.docs) {
        const antique = antiqueDoc.data();
        const antiqueId = antiqueDoc.id;
        
        console.log(`Processing auction: ${antiqueId} - ${antique.title}`);
        
        // Mark antique as inactive
        batch.update(antiqueDoc.ref, {
          isActive: false
        });
        
        // Get all bids for this antique
        const bidsSnapshot = await db.collection('bids')
          .where('antiqueId', '==', antiqueId)
          .get();
        
        if (bidsSnapshot.empty) {
          console.log(`No bids for auction ${antiqueId}`);
          continue;
        }
        
        // Update bid statuses
        if (antique.currentBidderUserId) {
          // There is a winner
          bidsSnapshot.forEach((bidDoc) => {
            const bid = bidDoc.data();
            
            if (bid.userId === antique.currentBidderUserId) {
              // Winner
              batch.update(bidDoc.ref, {
                status: 'won',
                isWinningBid: true
              });
            } else {
              // Losers
              batch.update(bidDoc.ref, {
                status: 'lost',
                isWinningBid: false
              });
            }
          });
          
          // Increment winner's won auctions count
          const winnerRef = db.collection('users').doc(antique.currentBidderUserId);
          batch.update(winnerRef, {
            wonAuctions: admin.firestore.FieldValue.increment(1)
          });
          
          console.log(`Marked winner: ${antique.currentBidderName}`);
        } else {
          // No winner - all bids are lost
          bidsSnapshot.forEach((bidDoc) => {
            batch.update(bidDoc.ref, {
              status: 'lost',
              isWinningBid: false
            });
          });
          
          console.log('No winner for this auction');
        }
        
        processedCount++;
      }
      
      // Commit all changes
      await batch.commit();
      
      console.log(`Successfully finalized ${processedCount} auctions`);
      return { processed: processedCount };
      
    } catch (error) {
      console.error('Error finalizing auctions:', error);
      throw error;
    }
  });

/**
 * CRITICAL FIX #5: Notification System - Outbid Alert
 * 
 * Triggers when a bid is created and notifies the previous highest bidder
 */
exports.onBidCreated = functions.firestore
  .document('bids/{bidId}')
  .onCreate(async (snapshot, context) => {
    try {
      const newBid = snapshot.data();
      const antiqueId = newBid.antiqueId;
      
      // Get the antique
      const antiqueDoc = await db.collection('antiques').doc(antiqueId).get();
      if (!antiqueDoc.exists) {
        return null;
      }
      
      const antique = antiqueDoc.data();
      
      // Find previous bids from other users that were winning
      const previousBidsSnapshot = await db.collection('bids')
        .where('antiqueId', '==', antiqueId)
        .where('status', '==', 'winning')
        .where('userId', '!=', newBid.userId)
        .get();
      
      // Create notifications for outbid users
      const batch = db.batch();
      
      previousBidsSnapshot.forEach((bidDoc) => {
        const previousBid = bidDoc.data();
        
        // Create notification document
        const notificationRef = db.collection('notifications').doc();
        batch.set(notificationRef, {
          userId: previousBid.userId,
          type: 'outbid',
          title: 'You have been outbid!',
          message: `Someone bid $${newBid.bidAmount.toFixed(2)} on "${antique.title}"`,
          antiqueId: antiqueId,
          antiqueName: antique.title,
          antiqueImageUrl: antique.imageUrl || '',
          read: false,
          createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
      });
      
      await batch.commit();
      
      console.log(`Created outbid notifications for ${previousBidsSnapshot.size} users`);
      return null;
      
    } catch (error) {
      console.error('Error creating outbid notification:', error);
      return null;
    }
  });

/**
 * CRITICAL FIX #5: Notification System - Auction Won/Lost
 * 
 * Triggers when an antique's isActive changes to false
 */
exports.onAuctionEnded = functions.firestore
  .document('antiques/{antiqueId}')
  .onUpdate(async (change, context) => {
    try {
      const beforeData = change.before.data();
      const afterData = change.after.data();
      
      // Check if auction just ended
      if (beforeData.isActive === true && afterData.isActive === false) {
        const antiqueId = context.params.antiqueId;
        
        // Get all bids for this auction
        const bidsSnapshot = await db.collection('bids')
          .where('antiqueId', '==', antiqueId)
          .get();
        
        if (bidsSnapshot.empty) {
          return null;
        }
        
        const batch = db.batch();
        
        // Create notifications for all bidders
        bidsSnapshot.forEach((bidDoc) => {
          const bid = bidDoc.data();
          
          const isWinner = bid.userId === afterData.currentBidderUserId;
          
          const notificationRef = db.collection('notifications').doc();
          batch.set(notificationRef, {
            userId: bid.userId,
            type: isWinner ? 'auction_won' : 'auction_lost',
            title: isWinner ? '🎉 Congratulations! You won!' : 'Auction Ended',
            message: isWinner 
              ? `You won the auction for "${afterData.title}" with your bid of $${afterData.currentBid.toFixed(2)}!`
              : `The auction for "${afterData.title}" has ended. Better luck next time!`,
            antiqueId: antiqueId,
            antiqueName: afterData.title,
            antiqueImageUrl: afterData.imageUrl || '',
            read: false,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
          });
        });
        
        await batch.commit();
        
        console.log(`Created auction end notifications for ${bidsSnapshot.size} users`);
      }
      
      return null;
      
    } catch (error) {
      console.error('Error creating auction end notifications:', error);
      return null;
    }
  });

/**
 * Helper function to manually trigger auction finalization
 * Can be called via HTTP for testing or manual triggers
 */
exports.manualFinalizeAuctions = functions.https.onCall(async (data, context) => {
  // Check if user is admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated to call this function'
    );
  }
  
  const userDoc = await db.collection('users').doc(context.auth.uid).get();
  const userData = userDoc.data();
  
  if (!userData || !userData.isAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can manually finalize auctions'
    );
  }
  
  // Call the scheduled function logic
  try {
    const now = admin.firestore.Timestamp.now();
    
    const endedAuctionsSnapshot = await db.collection('antiques')
      .where('isActive', '==', true)
      .where('bidEndTime', '<=', now)
      .get();
    
    if (endedAuctionsSnapshot.empty) {
      return { success: true, processed: 0, message: 'No ended auctions to finalize' };
    }
    
    const batch = db.batch();
    let processedCount = 0;
    
    for (const antiqueDoc of endedAuctionsSnapshot.docs) {
      const antique = antiqueDoc.data();
      const antiqueId = antiqueDoc.id;
      
      batch.update(antiqueDoc.ref, { isActive: false });
      
      const bidsSnapshot = await db.collection('bids')
        .where('antiqueId', '==', antiqueId)
        .get();
      
      if (!bidsSnapshot.empty) {
        if (antique.currentBidderUserId) {
          bidsSnapshot.forEach((bidDoc) => {
            const bid = bidDoc.data();
            batch.update(bidDoc.ref, {
              status: bid.userId === antique.currentBidderUserId ? 'won' : 'lost',
              isWinningBid: bid.userId === antique.currentBidderUserId
            });
          });
          
          const winnerRef = db.collection('users').doc(antique.currentBidderUserId);
          batch.update(winnerRef, {
            wonAuctions: admin.firestore.FieldValue.increment(1)
          });
        } else {
          bidsSnapshot.forEach((bidDoc) => {
            batch.update(bidDoc.ref, {
              status: 'lost',
              isWinningBid: false
            });
          });
        }
        
        processedCount++;
      }
    }
    
    await batch.commit();
    
    return { 
      success: true, 
      processed: processedCount,
      message: `Successfully finalized ${processedCount} auctions`
    };
    
  } catch (error) {
    console.error('Error in manual finalization:', error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to finalize auctions: ' + error.message
    );
  }
});
