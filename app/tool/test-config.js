// Simple test to verify Firebase connection
import dotenv from "dotenv";
import { fileURLToPath } from "url";
import { dirname, join } from "path";

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
dotenv.config({ path: join(__dirname, ".env") });

console.log("🔍 Checking Firebase configuration...");
console.log("Project ID:", process.env.FIREBASE_PROJECT_ID);
console.log("Storage Bucket:", process.env.FIREBASE_STORAGE_BUCKET);
console.log("API Key:", process.env.FIREBASE_API_KEY ? "Set" : "Not set");
console.log(
  "Client Email:",
  process.env.FIREBASE_CLIENT_EMAIL ? "Set" : "Not set"
);
console.log(
  "Private Key:",
  process.env.FIREBASE_PRIVATE_KEY ? "Set" : "Not set"
);

if (process.env.FIREBASE_PROJECT_ID === "clubbie-32937") {
  console.log("✅ Project ID matches your Firebase configuration");
} else {
  console.log("❌ Project ID mismatch - check your .env file");
}

console.log("\n📝 Next steps:");
console.log("1. Get your service account key from Firebase Console");
console.log("2. Update FIREBASE_CLIENT_EMAIL and FIREBASE_PRIVATE_KEY in .env");
console.log("3. Run: npm run seed:categories");
