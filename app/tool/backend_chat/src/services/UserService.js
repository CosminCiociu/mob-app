const { getFirestore, getFirebaseUser } = require("../config/firebase");
const {
  upsertStreamUser,
  generateStreamToken,
  getStreamUser,
  deleteStreamUser,
} = require("../config/streamChat");

/**
 * User service for managing users across Firebase and Stream Chat
 */
class UserService {
  constructor() {
    this.db = null;
  }

  /**
   * Initialize the service
   */
  async initialize() {
    this.db = getFirestore();
  }

  /**
   * Get or create user in both Firebase and Stream Chat
   */
  async getOrCreateUser(firebaseUid, userData = {}) {
    try {
      // Get Firebase user data
      const firebaseUser = await getFirebaseUser(firebaseUid);
      if (!firebaseUser) {
        throw new Error("Firebase user not found");
      }

      // Get user from Firestore
      let firestoreUser = await this.getFirestoreUser(firebaseUid);

      // Prepare user data for Stream Chat
      const streamUserData = {
        id: firebaseUid,
        name:
          userData.name ||
          firebaseUser.displayName ||
          firebaseUser.email ||
          "Unknown User",
        image: userData.image || firebaseUser.photoURL || "",
        email: firebaseUser.email,
        role: userData.role || "user",
        online: true,
        ...userData,
      };

      // Create or update user in Stream Chat
      await upsertStreamUser(firebaseUid, streamUserData);

      // Update Firestore user
      if (!firestoreUser) {
        firestoreUser = await this.createFirestoreUser(firebaseUid, {
          ...streamUserData,
          createdAt: new Date(),
          updatedAt: new Date(),
        });
      } else {
        firestoreUser = await this.updateFirestoreUser(firebaseUid, {
          ...streamUserData,
          updatedAt: new Date(),
        });
      }

      return {
        firebase: firebaseUser,
        firestore: firestoreUser,
        stream: streamUserData,
      };
    } catch (error) {
      console.error("Error in getOrCreateUser:", error);
      throw error;
    }
  }

  /**
   * Generate Stream Chat token for user
   */
  async generateUserToken(firebaseUid, options = {}) {
    try {
      // Ensure user exists in Stream Chat
      const streamUser = await getStreamUser(firebaseUid);
      if (!streamUser) {
        throw new Error(
          "User not found in Stream Chat. Please create user first."
        );
      }

      // Generate token
      const token = generateStreamToken(firebaseUid, options);

      // Update last login time in Firestore
      await this.updateFirestoreUser(firebaseUid, {
        lastLoginAt: new Date(),
        lastTokenGeneratedAt: new Date(),
      });

      return {
        token,
        user: streamUser,
        expires: options.exp ? new Date(options.exp * 1000) : null,
      };
    } catch (error) {
      console.error("Error generating user token:", error);
      throw error;
    }
  }

  /**
   * Get user profile (combined data from all sources)
   */
  async getUserProfile(firebaseUid) {
    try {
      const [firebaseUser, firestoreUser, streamUser] = await Promise.all([
        getFirebaseUser(firebaseUid),
        this.getFirestoreUser(firebaseUid),
        getStreamUser(firebaseUid),
      ]);

      if (!firebaseUser) {
        throw new Error("User not found");
      }

      return {
        uid: firebaseUid,
        firebase: firebaseUser,
        profile: firestoreUser,
        stream: streamUser,
      };
    } catch (error) {
      console.error("Error getting user profile:", error);
      throw error;
    }
  }

  /**
   * Update user profile
   */
  async updateUserProfile(firebaseUid, updates) {
    try {
      const updateData = {
        ...updates,
        updatedAt: new Date(),
      };

      // Update in Firestore
      const firestoreUser = await this.updateFirestoreUser(
        firebaseUid,
        updateData
      );

      // Update in Stream Chat if relevant fields changed
      const streamFields = ["name", "image", "role"];
      const streamUpdates = {};

      for (const field of streamFields) {
        if (updates[field] !== undefined) {
          streamUpdates[field] = updates[field];
        }
      }

      if (Object.keys(streamUpdates).length > 0) {
        await upsertStreamUser(firebaseUid, streamUpdates);
      }

      return firestoreUser;
    } catch (error) {
      console.error("Error updating user profile:", error);
      throw error;
    }
  }

  /**
   * Delete user from all systems
   */
  async deleteUser(firebaseUid, options = {}) {
    try {
      const deleteOptions = {
        markMessagesDeleted: true,
        hardDelete: false,
        ...options,
      };

      // Delete from Stream Chat
      await deleteStreamUser(firebaseUid, {
        mark_messages_deleted: deleteOptions.markMessagesDeleted,
        hard_delete: deleteOptions.hardDelete,
      });

      // Soft delete in Firestore (mark as deleted)
      await this.updateFirestoreUser(firebaseUid, {
        deleted: true,
        deletedAt: new Date(),
        updatedAt: new Date(),
      });

      console.log(`✅ User ${firebaseUid} deleted successfully`);
      return true;
    } catch (error) {
      console.error("Error deleting user:", error);
      throw error;
    }
  }

  /**
   * Search users
   */
  async searchUsers(query, filters = {}, limit = 20) {
    try {
      let firestoreQuery = this.db.collection("users");

      // Apply filters
      if (filters.role) {
        firestoreQuery = firestoreQuery.where("role", "==", filters.role);
      }

      if (filters.online !== undefined) {
        firestoreQuery = firestoreQuery.where("online", "==", filters.online);
      }

      // Exclude deleted users
      firestoreQuery = firestoreQuery.where("deleted", "!=", true);

      // Apply limit
      firestoreQuery = firestoreQuery.limit(limit);

      const snapshot = await firestoreQuery.get();
      const users = [];

      snapshot.forEach((doc) => {
        const userData = doc.data();

        // Simple text search (in production, use a proper search service)
        if (query) {
          const searchText = query.toLowerCase();
          const name = (userData.name || "").toLowerCase();
          const email = (userData.email || "").toLowerCase();

          if (!name.includes(searchText) && !email.includes(searchText)) {
            return;
          }
        }

        users.push({
          uid: doc.id,
          ...userData,
        });
      });

      return users;
    } catch (error) {
      console.error("Error searching users:", error);
      throw error;
    }
  }

  /**
   * Get Firestore user
   */
  async getFirestoreUser(firebaseUid) {
    try {
      const doc = await this.db.collection("users").doc(firebaseUid).get();

      if (!doc.exists) {
        return null;
      }

      return {
        uid: firebaseUid,
        ...doc.data(),
      };
    } catch (error) {
      console.error("Error getting Firestore user:", error);
      throw error;
    }
  }

  /**
   * Create Firestore user
   */
  async createFirestoreUser(firebaseUid, userData) {
    try {
      const userRef = this.db.collection("users").doc(firebaseUid);

      await userRef.set({
        ...userData,
        createdAt: new Date(),
        updatedAt: new Date(),
      });

      return {
        uid: firebaseUid,
        ...userData,
      };
    } catch (error) {
      console.error("Error creating Firestore user:", error);
      throw error;
    }
  }

  /**
   * Update Firestore user
   */
  async updateFirestoreUser(firebaseUid, updates) {
    try {
      const userRef = this.db.collection("users").doc(firebaseUid);

      await userRef.update({
        ...updates,
        updatedAt: new Date(),
      });

      // Return updated user
      return await this.getFirestoreUser(firebaseUid);
    } catch (error) {
      console.error("Error updating Firestore user:", error);
      throw error;
    }
  }

  /**
   * Batch update users
   */
  async batchUpdateUsers(updates) {
    try {
      const batch = this.db.batch();

      for (const update of updates) {
        const userRef = this.db.collection("users").doc(update.uid);
        batch.update(userRef, {
          ...update.data,
          updatedAt: new Date(),
        });
      }

      await batch.commit();
      console.log(`✅ Batch updated ${updates.length} users`);

      return true;
    } catch (error) {
      console.error("Error in batch update users:", error);
      throw error;
    }
  }
}

module.exports = UserService;
