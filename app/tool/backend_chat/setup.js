const admin = require("firebase-admin");
const { StreamChat } = require("stream-chat");

// Setup script for initializing the backend chat system
class BackendSetup {
  constructor() {
    this.firebase = null;
    this.streamChat = null;
  }

  async initialize() {
    console.log("🚀 Starting backend chat setup...");

    try {
      // Initialize Firebase
      await this.initializeFirebase();

      // Initialize Stream Chat
      await this.initializeStreamChat();

      // Create initial collections and indexes
      await this.setupFirestoreCollections();

      // Create default admin user if needed
      await this.createDefaultAdmin();

      console.log("✅ Backend setup completed successfully!");
      return true;
    } catch (error) {
      console.error("❌ Setup failed:", error.message);
      return false;
    }
  }

  async initializeFirebase() {
    console.log("📱 Initializing Firebase...");

    if (!process.env.FIREBASE_PROJECT_ID) {
      throw new Error("FIREBASE_PROJECT_ID environment variable is required");
    }

    // Initialize Firebase Admin with service account or default credentials
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const serviceAccount = require(process.env.FIREBASE_SERVICE_ACCOUNT_PATH);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
    } else {
      // Use default credentials (for deployed environments)
      admin.initializeApp({
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
    }

    this.firebase = admin.firestore();
    console.log("✅ Firebase initialized successfully");
  }

  async initializeStreamChat() {
    console.log("💬 Initializing Stream Chat...");

    if (!process.env.STREAM_API_KEY || !process.env.STREAM_API_SECRET) {
      throw new Error("Stream Chat API credentials are required");
    }

    this.streamChat = StreamChat.getInstance(
      process.env.STREAM_API_KEY,
      process.env.STREAM_API_SECRET
    );

    // Test connection
    await this.streamChat.getAppSettings();
    console.log("✅ Stream Chat initialized successfully");
  }

  async setupFirestoreCollections() {
    console.log("🗃️ Setting up Firestore collections...");

    try {
      // Create users collection with sample structure
      const usersRef = this.firebase.collection("users");
      await usersRef.doc("_structure").set({
        _description: "Users collection structure",
        fields: {
          uid: "string - Firebase Auth UID",
          streamChatId: "string - Stream Chat User ID",
          name: "string - Display name",
          email: "string - Email address",
          image: "string - Profile image URL",
          isOnline: "boolean - Online status",
          lastSeen: "timestamp - Last activity",
          searchName: "string - Lowercase name for search",
          role: "string - User role (user/admin)",
          createdAt: "timestamp - Account creation",
          updatedAt: "timestamp - Last update",
        },
      });

      // Create conversations collection
      const conversationsRef = this.firebase.collection("conversations");
      await conversationsRef.doc("_structure").set({
        _description: "Conversations collection structure",
        fields: {
          type: "string - direct/group",
          participants: "array - User IDs",
          streamChannelId: "string - Stream Chat channel ID",
          name: "string - Group name (optional)",
          image: "string - Group image (optional)",
          createdBy: "string - Creator user ID",
          lastMessage: "object - Last message info",
          lastMessageAt: "timestamp - Last message time",
          unreadCounts: "map - Unread counts per user",
          createdAt: "timestamp - Creation time",
          updatedAt: "timestamp - Last update",
        },
      });

      // Create channels collection
      const channelsRef = this.firebase.collection("channels");
      await channelsRef.doc("_structure").set({
        _description: "Channels collection structure",
        fields: {
          name: "string - Channel name",
          description: "string - Channel description",
          streamChannelId: "string - Stream Chat channel ID",
          isPrivate: "boolean - Private channel flag",
          members: "array - Member user IDs",
          admins: "array - Admin user IDs",
          createdBy: "string - Creator user ID",
          lastActivityAt: "timestamp - Last activity",
          memberCount: "number - Total members",
          messageCount: "number - Total messages",
          createdAt: "timestamp - Creation time",
          updatedAt: "timestamp - Last update",
        },
      });

      // Create stats collection
      const statsRef = this.firebase.collection("stats");
      await statsRef.doc("system").set({
        totalUsers: 0,
        totalConversations: 0,
        totalChannels: 0,
        totalMessages: 0,
        onlineUsers: 0,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("✅ Firestore collections setup completed");
    } catch (error) {
      console.error("Error setting up collections:", error);
      throw error;
    }
  }

  async createDefaultAdmin() {
    console.log("👤 Creating default admin user...");

    try {
      const adminEmail = process.env.ADMIN_EMAIL;
      const adminPassword = process.env.ADMIN_PASSWORD;

      if (!adminEmail || !adminPassword) {
        console.log(
          "⚠️ Admin credentials not provided, skipping admin creation"
        );
        return;
      }

      // Check if admin user already exists
      try {
        const existingUser = await admin.auth().getUserByEmail(adminEmail);
        console.log("ℹ️ Admin user already exists:", existingUser.uid);
        return;
      } catch (error) {
        // User doesn't exist, create it
      }

      // Create Firebase Auth user
      const userRecord = await admin.auth().createUser({
        email: adminEmail,
        password: adminPassword,
        displayName: "System Administrator",
        emailVerified: true,
      });

      // Create Stream Chat user
      const streamUserId = `admin_${userRecord.uid}`;
      await this.streamChat.upsertUser({
        id: streamUserId,
        name: "System Administrator",
        role: "admin",
        email: adminEmail,
      });

      // Create Firestore user document
      await this.firebase.collection("users").doc(userRecord.uid).set({
        uid: userRecord.uid,
        streamChatId: streamUserId,
        name: "System Administrator",
        email: adminEmail,
        image: null,
        isOnline: false,
        lastSeen: admin.firestore.FieldValue.serverTimestamp(),
        searchName: "system administrator",
        role: "admin",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("✅ Default admin user created:", userRecord.uid);
    } catch (error) {
      console.error("Error creating admin user:", error);
      // Don't throw here, admin creation is optional
    }
  }

  async testConnections() {
    console.log("🧪 Testing connections...");

    try {
      // Test Firebase
      await this.firebase.collection("stats").doc("system").get();
      console.log("✅ Firebase connection: OK");

      // Test Stream Chat
      await this.streamChat.getAppSettings();
      console.log("✅ Stream Chat connection: OK");

      return true;
    } catch (error) {
      console.error("❌ Connection test failed:", error.message);
      return false;
    }
  }

  async cleanup() {
    console.log("🧹 Cleaning up test data...");

    try {
      // Remove structure documents
      const collections = ["users", "conversations", "channels"];

      for (const collection of collections) {
        await this.firebase.collection(collection).doc("_structure").delete();
      }

      console.log("✅ Cleanup completed");
    } catch (error) {
      console.error("Error during cleanup:", error);
    }
  }
}

// Run setup if called directly
if (require.main === module) {
  require("dotenv").config();

  const setup = new BackendSetup();

  const runSetup = async () => {
    const success = await setup.initialize();

    if (success) {
      console.log("\n🎉 Setup completed! Your backend is ready to use.");
      console.log("\nNext steps:");
      console.log("1. Start the server: npm start");
      console.log("2. Test the API endpoints");
      console.log("3. Configure your Flutter app to use this backend");

      // Test connections
      await setup.testConnections();

      // Optional cleanup of structure documents
      if (process.argv.includes("--cleanup")) {
        await setup.cleanup();
      }
    } else {
      console.log(
        "\n❌ Setup failed. Please check your configuration and try again."
      );
      process.exit(1);
    }

    process.exit(0);
  };

  runSetup().catch((error) => {
    console.error("Fatal error during setup:", error);
    process.exit(1);
  });
}

module.exports = BackendSetup;
