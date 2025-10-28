import "dotenv/config";
import admin from "firebase-admin";

// Initialize Firebase Admin SDK
if (!admin.apps.length) {
  admin.initializeApp({
    credential: admin.credential.cert({
      type: "service_account",
      project_id: process.env.FIREBASE_PROJECT_ID,
      private_key_id: process.env.FIREBASE_PRIVATE_KEY_ID,
      private_key: process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, "\n"),
      client_email: process.env.FIREBASE_CLIENT_EMAIL,
      client_id: process.env.FIREBASE_CLIENT_ID,
      auth_uri: "https://accounts.google.com/o/oauth2/auth",
      token_uri: "https://oauth2.googleapis.com/token",
      auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
      client_x509_cert_url: process.env.FIREBASE_CLIENT_CERT_URL,
    }),
    databaseURL: `https://${process.env.FIREBASE_PROJECT_ID}-default-rtdb.firebaseio.com/`,
  });
}

const db = admin.firestore();

async function verifySeederData() {
  try {
    console.log("🔍 Verifying seeder data...\n");

    // Check users
    const usersSnapshot = await db.collection("users").get();
    console.log(`👥 Total users in database: ${usersSnapshot.size}`);

    // Check events
    const eventsSnapshot = await db.collection("users_events").get();
    console.log(`🎉 Total events in database: ${eventsSnapshot.size}`);

    // Check categories
    const categoriesSnapshot = await db.collection("categories").get();
    console.log(
      `📋 Total categories in database: ${categoriesSnapshot.size}\n`
    );

    // Verify events per user
    console.log("📊 Events per user:");
    const userEventCounts = {};

    eventsSnapshot.forEach((doc) => {
      const eventData = doc.data();
      const createdBy = eventData.createdBy;
      userEventCounts[createdBy] = (userEventCounts[createdBy] || 0) + 1;
    });

    // Get user names
    const users = {};
    usersSnapshot.forEach((doc) => {
      const userData = doc.data();
      users[doc.id] = `${userData.firstName || "Unknown"} ${
        userData.lastName || "User"
      }`;
    });

    Object.entries(userEventCounts).forEach(([userId, count]) => {
      console.log(`  👤 ${users[userId] || userId}: ${count} events`);
    });

    // Verify categories are being used
    console.log("\n📈 Events by category:");
    const categoryEventCounts = {};

    eventsSnapshot.forEach((doc) => {
      const eventData = doc.data();
      const categoryId = eventData.categoryId;
      categoryEventCounts[categoryId] =
        (categoryEventCounts[categoryId] || 0) + 1;
    });

    Object.entries(categoryEventCounts).forEach(([categoryId, count]) => {
      console.log(`  📊 ${categoryId}: ${count} events`);
    });

    // Sample event details
    console.log("\n📅 Sample event details:");
    const sampleEvents = eventsSnapshot.docs.slice(0, 3);
    sampleEvents.forEach((doc, index) => {
      const eventData = doc.data();
      console.log(`  ${index + 1}. ${eventData.eventName}`);
      console.log(
        `     Category: ${eventData.categoryId}/${eventData.subcategoryId}`
      );
      console.log(`     Date: ${eventData.dateTime}`);
      console.log(`     Created by: ${users[eventData.createdBy]}`);
      console.log(
        `     Max attendees: ${eventData.maxAttendees || "Unlimited"}`
      );
      console.log("");
    });

    console.log("✅ Verification completed!");
  } catch (error) {
    console.error("❌ Error verifying data:", error);
  } finally {
    process.exit(0);
  }
}

verifySeederData();
