const jwt = require("jsonwebtoken");
const { verifyIdToken } = require("../config/firebase");

/**
 * Validate API Key middleware
 */
const validateApiKey = (req, res, next) => {
  const apiKey = req.headers["x-api-key"];

  // In development, allow requests without API key
  if (process.env.NODE_ENV === "development" && !apiKey) {
    return next();
  }

  // For production, you should implement proper API key validation
  // For now, we'll just check if it exists
  if (!apiKey) {
    return res.status(401).json({
      success: false,
      error: "API key required",
      code: "API_KEY_MISSING",
    });
  }

  // TODO: Implement actual API key validation against your database
  next();
};

/**
 * Verify Firebase ID Token middleware
 */
const verifyFirebaseToken = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        error: "Authorization token required",
        code: "TOKEN_MISSING",
      });
    }

    const idToken = authHeader.split(" ")[1];

    // Verify the Firebase ID token
    const decodedToken = await verifyIdToken(idToken);

    // Add user info to request
    req.user = {
      uid: decodedToken.uid,
      email: decodedToken.email,
      name: decodedToken.name,
      picture: decodedToken.picture,
      emailVerified: decodedToken.email_verified,
      firebase: decodedToken,
    };

    next();
  } catch (error) {
    console.error("Firebase token verification failed:", error);
    return res.status(401).json({
      success: false,
      error: "Invalid or expired token",
      code: "TOKEN_INVALID",
    });
  }
};

/**
 * Verify JWT token middleware (for internal API communication)
 */
const verifyJWT = (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith("Bearer ")) {
      return res.status(401).json({
        success: false,
        error: "JWT token required",
        code: "JWT_MISSING",
      });
    }

    const token = authHeader.split(" ")[1];
    const secret = process.env.JWT_SECRET;

    if (!secret) {
      throw new Error("JWT_SECRET not configured");
    }

    // Verify JWT
    const decoded = jwt.verify(token, secret);
    req.user = decoded;

    next();
  } catch (error) {
    console.error("JWT verification failed:", error);
    return res.status(401).json({
      success: false,
      error: "Invalid JWT token",
      code: "JWT_INVALID",
    });
  }
};

/**
 * Generate JWT token for internal use
 */
const generateJWT = (payload, options = {}) => {
  const secret = process.env.JWT_SECRET;
  if (!secret) {
    throw new Error("JWT_SECRET not configured");
  }

  const defaultOptions = {
    expiresIn: process.env.JWT_EXPIRES_IN || "7d",
    issuer: "ovo-meet-chat-backend",
    ...options,
  };

  return jwt.sign(payload, secret, defaultOptions);
};

/**
 * Optional Firebase token verification (doesn't fail if no token)
 */
const optionalFirebaseAuth = async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith("Bearer ")) {
      const idToken = authHeader.split(" ")[1];
      const decodedToken = await verifyIdToken(idToken);

      req.user = {
        uid: decodedToken.uid,
        email: decodedToken.email,
        name: decodedToken.name,
        picture: decodedToken.picture,
        emailVerified: decodedToken.email_verified,
        firebase: decodedToken,
      };
    }

    next();
  } catch (error) {
    // Don't fail on optional auth
    console.warn("Optional Firebase auth failed:", error.message);
    next();
  }
};

/**
 * Check if user has required permissions
 */
const requirePermissions = (permissions = []) => {
  return (req, res, next) => {
    if (!req.user) {
      return res.status(401).json({
        success: false,
        error: "Authentication required",
        code: "AUTH_REQUIRED",
      });
    }

    // Check if user has required permissions
    const userPermissions = req.user.permissions || [];
    const hasPermission = permissions.every((permission) =>
      userPermissions.includes(permission)
    );

    if (!hasPermission) {
      return res.status(403).json({
        success: false,
        error: "Insufficient permissions",
        code: "PERMISSIONS_INSUFFICIENT",
      });
    }

    next();
  };
};

module.exports = {
  validateApiKey,
  verifyFirebaseToken,
  verifyJWT,
  generateJWT,
  optionalFirebaseAuth,
  requirePermissions,
};
