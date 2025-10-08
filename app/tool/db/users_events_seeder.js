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

// Sample users events data
const sampleEvents = [
  {
    eventName: "Tech Meetup Brașov",
    details:
      "Join us for an exciting tech meetup discussing the latest trends in AI and robotics. Network with fellow developers and innovators.",
    categoryId: "technology_gaming",
    subcategoryId: "robotics_ai",
    dateTime: "2025-10-15T18:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 50,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Centrul Vechi, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Centrul Vechi",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.64268, 25.588725),
      lat: 45.64268,
      lng: 25.588725,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Cooking Class: Italian Cuisine",
    details:
      "Learn to cook authentic Italian dishes with our professional chef. All ingredients and equipment provided.",
    categoryId: "food_drink",
    subcategoryId: "cooking_classes",
    dateTime: "2025-10-16T19:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 20,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Strada Republicii, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Strada Republicii",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6427, 25.5887),
      lat: 45.6427,
      lng: 25.5887,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Mountain Hiking Adventure",
    details:
      "Explore the beautiful Carpathian Mountains. Suitable for intermediate hikers. Bring your own equipment.",
    categoryId: "sports_fitness",
    subcategoryId: "hiking_climbing",
    dateTime: "2025-10-17T09:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 15,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Piața Sfatului, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Piața Sfatului",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6426, 25.5889),
      lat: 45.6426,
      lng: 25.5889,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Art Gallery Opening",
    details:
      "Join us for the opening of a contemporary art exhibition featuring local artists. Wine and refreshments will be served.",
    categoryId: "arts_culture",
    subcategoryId: "visual_arts",
    dateTime: "2025-10-18T18:30:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 100,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Strada George Barițiu, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Strada George Barițiu",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6425, 25.589),
      lat: 45.6425,
      lng: 25.589,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Business Networking Event",
    details:
      "Connect with local entrepreneurs and business professionals. Expand your network and discover new opportunities.",
    categoryId: "business_professional",
    subcategoryId: "networking",
    dateTime: "2025-10-19T17:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 75,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Strada Mureșenilor, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Strada Mureșenilor",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6428, 25.5885),
      lat: 45.6428,
      lng: 25.5885,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Live Jazz Concert",
    details:
      "Enjoy an evening of smooth jazz with renowned local musicians. Great atmosphere and quality music guaranteed.",
    categoryId: "entertainment",
    subcategoryId: "live_music",
    dateTime: "2025-10-20T20:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 60,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthgueFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Strada Postăvarului, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Strada Postăvarului",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6424, 25.5891),
      lat: 45.6424,
      lng: 25.5891,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Photography Workshop",
    details:
      "Learn professional photography techniques with hands-on practice. Suitable for beginners and intermediate photographers.",
    categoryId: "learning_workshops",
    subcategoryId: "creative_workshops",
    dateTime: "2025-10-21T14:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: 25,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Bulevardul Eroilor, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Bulevardul Eroilor",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.643, 25.5883),
      lat: 45.643,
      lng: 25.5883,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
  {
    eventName: "Community Volunteer Day",
    details:
      "Join us in giving back to the community. Various volunteer activities available for all ages and abilities.",
    categoryId: "social_community",
    subcategoryId: "volunteer_work",
    dateTime: "2025-10-22T10:00:00.000",
    timezone: "Europe/Bucharest",
    status: "active",
    maxAttendees: null,
    imageUrl: "",
    attendees: ["gqWoufXp4JfthguFNenqO0dveUA3"],
    createdBy: "gqWoufXp4JfthguFNenqO0dveUA3",
    location: {
      address: {
        administrativeArea: "Județul Brașov",
        country: "Romania",
        fullAddress: "Parcul Central, Brașov, Județul Brașov, Romania",
        locality: "Brașov",
        name: "Parcul Central",
      },
      geohash: "u845wkcpu",
      geopoint: new admin.firestore.GeoPoint(45.6423, 25.5892),
      lat: 45.6423,
      lng: 25.5892,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    },
  },
];

async function seedEventsData() {
  try {
    console.log("🚀 Starting users_events seeding...");

    const batch = db.batch();

    for (const eventData of sampleEvents) {
      // Add server timestamp for createdAt
      const eventWithTimestamp = {
        ...eventData,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      };

      // Create a new document reference with auto-generated ID
      const eventRef = db.collection("users_events").doc();
      batch.set(eventRef, eventWithTimestamp);

      console.log(`📅 Adding event: ${eventData.eventName}`);
    }

    // Commit the batch
    await batch.commit();

    console.log("✅ Successfully seeded users_events collection!");
    console.log(`📊 Total events created: ${sampleEvents.length}`);

    // Verify the data
    const eventsSnapshot = await db.collection("users_events").get();
    console.log(
      `🔍 Verification: Found ${eventsSnapshot.size} events in collection`
    );

    // Display sample of created events
    console.log("\n📋 Sample of created events:");
    eventsSnapshot.docs.slice(0, 3).forEach((doc, index) => {
      const data = doc.data();
      console.log(
        `${index + 1}. ${data.eventName} - ${data.categoryId}/${
          data.subcategoryId
        }`
      );
    });
  } catch (error) {
    console.error("❌ Error seeding events data:", error);
  } finally {
    console.log("🏁 Seeding process completed");
    process.exit(0);
  }
}

// Run the seeder
seedEventsData();
