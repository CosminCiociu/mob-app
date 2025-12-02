# Stream Chat Backend Server

A comprehensive Node.js backend for Flutter applications using Stream Chat and Firebase integration.

## Features

- 🔐 **Firebase Authentication** - Secure user authentication with JWT tokens
- 💬 **Stream Chat Integration** - Full server-side Stream Chat implementation
- 🗃️ **Firestore Database** - User profiles, conversations, and channel management
- 🛡️ **Security Middleware** - Rate limiting, CORS, helmet protection
- 📱 **RESTful API** - Complete API for mobile app integration
- 🔍 **Search & Discovery** - User and channel search capabilities
- 📊 **Analytics** - User activity and chat statistics
- ⚡ **Real-time Updates** - WebSocket support through Stream Chat

## Quick Start

### Prerequisites

- Node.js 16+ installed
- Firebase project with Firestore enabled
- Stream Chat account and API credentials
- Firebase service account key (for local development)

### Installation

1. **Clone or navigate to the backend directory:**

   ```bash
   cd C:\projects\mob-app\app\tool\backend_chat
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Configure environment variables:**

   ```bash
   cp .env.example .env
   ```

4. **Edit `.env` file with your credentials:**

   ```env
   # Server Configuration
   PORT=3000
   NODE_ENV=development

   # Firebase Configuration
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_SERVICE_ACCOUNT_PATH=path/to/serviceAccountKey.json

   # Stream Chat Configuration
   STREAM_API_KEY=your-stream-api-key
   STREAM_API_SECRET=your-stream-api-secret

   # JWT Configuration
   JWT_SECRET=your-super-secret-jwt-key
   JWT_EXPIRES_IN=7d

   # Optional: Default Admin User
   ADMIN_EMAIL=admin@yourapp.com
   ADMIN_PASSWORD=secure-admin-password
   ```

5. **Run the setup script:**

   ```bash
   node setup.js
   ```

6. **Start the server:**
   ```bash
   npm start
   ```

The server will be running at `http://localhost:3000`

## API Documentation

### Authentication Endpoints

#### POST `/api/auth/login`

Login with Firebase ID token

```json
{
  "idToken": "firebase_id_token"
}
```

#### POST `/api/auth/refresh-token`

Refresh JWT token

```json
{
  "refreshToken": "jwt_refresh_token"
}
```

#### GET `/api/auth/profile`

Get current user profile (requires auth)

#### POST `/api/auth/logout`

Logout user (requires auth)

#### POST `/api/auth/validate-token`

Validate JWT token

### User Management Endpoints

#### GET `/api/users/search?query=john&limit=10`

Search users by name or email

#### GET `/api/users/online`

Get list of online users

#### POST `/api/users/status`

Update user online status

```json
{
  "isOnline": true
}
```

#### GET `/api/users/stats`

Get user statistics

### Chat Management Endpoints

#### GET `/api/chat/conversations`

Get user's conversations

#### POST `/api/chat/dm`

Create direct message conversation

```json
{
  "recipientId": "user_id",
  "message": "Hello!"
}
```

#### POST `/api/chat/group`

Create group conversation

```json
{
  "name": "Group Name",
  "description": "Group description",
  "participants": ["user1", "user2"],
  "message": "Welcome message"
}
```

#### POST `/api/chat/conversations/:id/add-members`

Add members to group conversation

```json
{
  "userIds": ["user3", "user4"]
}
```

### Channel Management Endpoints

#### GET `/api/channels/public`

Get public channels

#### POST `/api/channels/:id/join`

Join a public channel

#### POST `/api/channels/:id/leave`

Leave a channel

#### GET `/api/channels/:id/members`

Get channel members

#### GET `/api/channels/search?q=channel_name`

Search channels

#### GET `/api/channels/trending`

Get trending channels

## Firebase Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create new project
3. Enable Firestore Database
4. Enable Authentication with Email/Password

### 2. Generate Service Account Key

1. Go to Project Settings > Service Accounts
2. Click "Generate new private key"
3. Download the JSON file
4. Update `FIREBASE_SERVICE_ACCOUNT_PATH` in `.env`

### 3. Configure Firestore Rules

Deploy the security rules:

```bash
firebase deploy --only firestore:rules
```

### 4. Create Firestore Indexes

Deploy the indexes:

```bash
firebase deploy --only firestore:indexes
```

## Stream Chat Setup

### 1. Create Stream Account

1. Go to [GetStream.io](https://getstream.io)
2. Create account and new chat application
3. Get API Key and Secret from dashboard

### 2. Configure API Credentials

Update your `.env` file with Stream Chat credentials:

```env
STREAM_API_KEY=your_api_key
STREAM_API_SECRET=your_api_secret
```

## Development

### Project Structure

```
backend_chat/
├── src/
│   ├── config/           # Configuration files
│   ├── middleware/       # Express middleware
│   ├── routes/          # API routes
│   └── services/        # Business logic services
├── .env.example         # Environment variables template
├── firestore.rules      # Firestore security rules
├── firestore.indexes.json # Firestore indexes
├── setup.js             # Setup script
└── server.js            # Main server file
```

### Available Scripts

```bash
npm start          # Start production server
npm run dev        # Start development server with nodemon
npm run setup      # Run setup script
npm test           # Run tests (when implemented)
```

### Environment Variables

- `PORT` - Server port (default: 3000)
- `NODE_ENV` - Environment (development/production)
- `FIREBASE_PROJECT_ID` - Firebase project ID
- `FIREBASE_SERVICE_ACCOUNT_PATH` - Path to service account JSON
- `STREAM_API_KEY` - Stream Chat API key
- `STREAM_API_SECRET` - Stream Chat API secret
- `JWT_SECRET` - JWT signing secret
- `JWT_EXPIRES_IN` - JWT expiration time

## Flutter Integration

### 1. Add HTTP Package

Add to your `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
```

### 2. Create API Service

```dart
class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<Map<String, dynamic>> login(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Login failed');
    }
  }
}
```

### 3. Handle Authentication

```dart
class AuthController extends GetxController {
  Future<void> loginWithFirebase() async {
    try {
      // Firebase authentication
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Get ID token
      String idToken = await credential.user!.getIdToken();

      // Login to backend
      final response = await ApiService.login(idToken);

      // Store JWT token
      await SharedPreferences.getInstance()
          .then((prefs) => prefs.setString('jwt_token', response['token']));

      // Navigate to chat
      Get.offAllNamed('/chat');
    } catch (e) {
      print('Login error: $e');
    }
  }
}
```

## Production Deployment

### Using PM2 (Recommended)

```bash
# Install PM2
npm install -g pm2

# Start application
pm2 start server.js --name "chat-backend"

# Save PM2 configuration
pm2 save
pm2 startup
```

### Using Docker

```dockerfile
FROM node:16-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000
CMD ["node", "server.js"]
```

### Environment Configuration

For production, ensure:

- `NODE_ENV=production`
- Strong `JWT_SECRET`
- Firestore security rules deployed
- CORS configured for your domain
- Rate limiting configured appropriately

## Security Considerations

1. **Environment Variables**: Never commit `.env` files
2. **JWT Secrets**: Use strong, randomly generated secrets
3. **Firestore Rules**: Deploy proper security rules
4. **Rate Limiting**: Configure appropriate limits
5. **CORS**: Restrict to your domains only
6. **HTTPS**: Use HTTPS in production
7. **Input Validation**: All inputs are validated
8. **Error Handling**: Sensitive information not exposed

## Troubleshooting

### Common Issues

**1. Firebase Connection Error**

- Check service account key path
- Verify project ID
- Ensure Firestore is enabled

**2. Stream Chat Error**

- Verify API key and secret
- Check Stream dashboard for usage limits
- Ensure proper user tokens

**3. Authentication Issues**

- Check JWT secret configuration
- Verify Firebase ID token validity
- Check user permissions

### Debug Mode

Set `NODE_ENV=development` for detailed error logs.

## Support

For issues and questions:

1. Check the troubleshooting section
2. Review Firebase/Stream Chat documentation
3. Check server logs for detailed error messages

## License

This project is part of the mob-app Flutter application.
