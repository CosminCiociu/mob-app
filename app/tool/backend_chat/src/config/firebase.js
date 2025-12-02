const admin = require("firebase-admin");
const path = require("path");

let firebaseApp = null;
let firestoreDb = null;

/**
 * Initialize Firebase Admin SDK
 */
async function initializeFirebase() {
  try {
    if (firebaseApp) {
      console.log("Firebase already initialized");
      return firebaseApp;
    }

    // Try to initialize with service account file first
    if (process.env.FIREBASE_SERVICE_ACCOUNT_PATH) {
      const serviceAccountPath = path.resolve(
        process.env.FIREBASE_SERVICE_ACCOUNT_PATH
      );

      try {
        const serviceAccount = require(serviceAccountPath);
        firebaseApp = admin.initializeApp({
          credential: admin.credential.cert(serviceAccount),
          projectId: process.env.FIREBASE_PROJECT_ID,
        });
      } catch (fileError) {
        console.warn(
          "Service account file not found, trying environment variables..."
        );
      }
    }

    // Fallback to environment variables
    if (
      !firebaseApp &&
      process.env.FIREBASE_PROJECT_ID &&
      process.env.FIREBASE_CLIENT_EMAIL &&
      process.env.FIREBASE_PRIVATE_KEY
    ) {
      const serviceAccount = {
        projectId: process.env.FIREBASE_PROJECT_ID,
        clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
        privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n"),
      };

      firebaseApp = admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
    }

    if (!firebaseApp) {
      throw new Error(
        "Firebase configuration not found. Please provide either FIREBASE_SERVICE_ACCOUNT_PATH or Firebase environment variables."
      );
    }

    // Initialize Firestore
    firestoreDb = admin.firestore();

    // Test connection
    await firestoreDb.collection("_test").limit(1).get();

    console.log("✅ Firebase Admin SDK initialized successfully");
    return firebaseApp;
  } catch (error) {
    console.error("❌ Firebase initialization failed:", error);
    throw error;
  }
}

/**
 * Get Firebase Admin instance
 */
function getFirebaseAdmin() {
  if (!firebaseApp) {
    throw new Error(
      "Firebase not initialized. Call initializeFirebase() first."
    );
  }
  return firebaseApp;
}

/**
 * Get Firestore database instance
 */
function getFirestore() {
  if (!firestoreDb) {
    throw new Error(
      "Firestore not initialized. Call initializeFirebase() first."
    );
  }
  return firestoreDb;
}

/**
 * Verify Firebase ID Token
 */
async function verifyIdToken(idToken) {
  try {
    const decodedToken = await admin.auth().verifyIdToken(idToken);
    return decodedToken;
  } catch (error) {
    console.error("Token verification failed:", error);
    throw new Error("Invalid Firebase token");
  }
}

/**
 * Get user by UID
 */
async function getFirebaseUser(uid) {
  try {
    const userRecord = await admin.auth().getUser(uid);
    return userRecord;
  } catch (error) {
    console.error("Failed to get Firebase user:", error);
    return null;
  }
}

/**
 * Create custom token for a user
 */
async function createCustomToken(uid, additionalClaims = {}) {
  try {
    const customToken = await admin
      .auth()
      .createCustomToken(uid, additionalClaims);
    return customToken;
  } catch (error) {
    console.error("Failed to create custom token:", error);
    throw error;
  }
}

module.exports = {
  initializeFirebase,
  getFirebaseAdmin,
  getFirestore,
  verifyIdToken,
  getFirebaseUser,
  createCustomToken,
};
