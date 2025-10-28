# Database Seeder for Mob App

This directory contains database seeding scripts for the Mob App Firebase project.

## 🚀 Quick Start

### Prerequisites

1. Firebase project setup with environment variables configured
2. Node.js 16+ installed
3. Firebase Admin SDK credentials

### Environment Setup

Make sure you have a `.env` file in the tool directory with:

```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

## 📊 Available Commands

### Categories Seeding

```bash
npm run seed:categories      # Seed categories data
npm run verify:categories    # Verify categories
npm run cleanup:categories   # Clean up categories
```

### Users & Events Seeding

```bash
npm run seed:events          # Seed 10 users × 3 events each (30 total events)
npm run cleanup:events       # Clean up events only
npm run cleanup:users        # Clean up users only
npm run full-seed:events     # Complete reset + seed (users & events)
```

### Complete Database Operations

```bash
npm run seed:all             # Seed categories + events
npm run cleanup:all          # Clean up everything
npm run full-seed:all        # Complete reset + seed everything
```

## 🎯 Users & Events Seeder Features

The `users_events_seeder.js` script creates a comprehensive test dataset:

### What it creates:

- **Exactly 10 users** with realistic Romanian names
- **Exactly 3 events per user** (30 total events)
- **Dynamic category fetching** from Firebase categories collection
- **Realistic event data** with proper locations, dates, and details

### Key Features:

1. **Smart User Management**:

   - Uses existing users if available
   - Creates additional users to reach exactly 10
   - Realistic Romanian names and locations

2. **Category Integration**:

   - Fetches categories dynamically from Firebase
   - Supports both active and inactive categories
   - Maps events to proper category/subcategory structure

3. **Event Generation**:

   - 8 category-specific event templates
   - Future dates spread over 1-30+ days
   - Realistic attendee limits and age ranges
   - Proper location data with Romanian cities

4. **Data Quality**:
   - Proper Firebase timestamps
   - Consistent data structure
   - Validation and error handling

## 📁 Event Categories Supported

The seeder includes event templates for:

- **Sports**: Football, Basketball, Tennis, Running, Yoga
- **Outdoor & Adventure**: Hiking, Camping, Rock Climbing, Cycling, Kayaking
- **Arts & Culture**: Gallery openings, Photography, Theater, Music, Painting
- **Food & Drink**: Coffee meetups, Wine tasting, Cooking classes, Restaurant tours
- **Technology & Gaming**: Coding bootcamps, Gaming tournaments, AI meetups, VR experiences
- **Education & Learning**: Language exchange, Book clubs, Study groups, Science workshops
- **Social & Community**: Volunteer work, Networking, Cultural exchange, Community projects
- **Entertainment & Leisure**: Movie nights, Karaoke, Board games, Comedy shows, Trivia
- **Travel & Trips**: City tours, Day trips, Road trips, Winery tours

## 🔍 Verification

Run the verification script to check seeded data:

```bash
node verify_seeder.js
```

This will show:

- Total users, events, and categories
- Events per user breakdown
- Category distribution
- Sample event details

## 📝 Sample Output

```
🚀 Starting users_events seeding for 10 users with 3 events each...
📋 Fetching categories from Firebase...
✅ Found 9 categories to use for events
👥 Fetching users from database...
✅ Found 1 users in database
📝 Creating 9 additional users to reach 10 total...

📊 Final Results:
  👥 Users created/used: 10
  🎉 Events created: 30
🔍 Verification: Found 30 total events in collection

📋 Events created per user:
👤 Maria Popescu: 3/3 events
👤 Alex Ionescu: 3/3 events
👤 Diana Stan: 3/3 events
...
```

## 🛠 Customization

### Modify Event Templates

Edit the `eventTemplates` object in `users_events_seeder.js` to add/modify event types.

### Adjust User Count

Change the target user count by modifying the `fetchUsers()` function.

### Location Data

Update the `sampleLocations` array to use different cities/locations.

## ⚠️ Important Notes

1. **Clean Start**: Use `full-seed:events` for a completely fresh start
2. **Categories First**: Always seed categories before events
3. **Firebase Limits**: The seeder respects Firestore batch size limits (500 operations)
4. **Error Handling**: Comprehensive error handling with detailed logging

## 🔧 Troubleshooting

### Common Issues:

1. **No categories found**: Run `npm run seed:categories` first
2. **Firebase permissions**: Check your service account credentials
3. **Network issues**: Verify Firebase project connectivity

### Debug Mode:

The seeder includes detailed logging at each step to help diagnose issues.
