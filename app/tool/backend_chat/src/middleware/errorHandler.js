/**
 * Custom error class for API errors
 */
class APIError extends Error {
  constructor(message, statusCode = 500, code = "INTERNAL_ERROR") {
    super(message);
    this.statusCode = statusCode;
    this.code = code;
    this.name = "APIError";
  }
}

/**
 * Error handler middleware
 */
const errorHandler = (err, req, res, next) => {
  let error = { ...err };
  error.message = err.message;

  // Log error
  console.error("Error Handler:", {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    body: req.body,
    user: req.user?.uid || "anonymous",
  });

  // Mongoose bad ObjectId
  if (err.name === "CastError") {
    const message = "Resource not found";
    error = new APIError(message, 404, "RESOURCE_NOT_FOUND");
  }

  // Mongoose duplicate key
  if (err.code === 11000) {
    const message = "Duplicate field value entered";
    error = new APIError(message, 400, "DUPLICATE_FIELD");
  }

  // Mongoose validation error
  if (err.name === "ValidationError") {
    const message = Object.values(err.errors).map((val) => val.message);
    error = new APIError(message.join(", "), 400, "VALIDATION_ERROR");
  }

  // JWT errors
  if (err.name === "JsonWebTokenError") {
    const message = "Invalid token";
    error = new APIError(message, 401, "TOKEN_INVALID");
  }

  if (err.name === "TokenExpiredError") {
    const message = "Token expired";
    error = new APIError(message, 401, "TOKEN_EXPIRED");
  }

  // Firebase errors
  if (err.code && err.code.startsWith("auth/")) {
    const message = getFirebaseErrorMessage(err.code);
    error = new APIError(message, 401, "FIREBASE_AUTH_ERROR");
  }

  // Stream Chat errors
  if (err.response && err.response.data) {
    const message = err.response.data.message || "Stream Chat error";
    error = new APIError(
      message,
      err.response.status || 500,
      "STREAM_CHAT_ERROR"
    );
  }

  // Default to 500 server error
  res.status(error.statusCode || 500).json({
    success: false,
    error: error.message || "Server Error",
    code: error.code || "INTERNAL_ERROR",
    ...(process.env.NODE_ENV === "development" && {
      stack: err.stack,
      details: err,
    }),
  });
};

/**
 * 404 Not Found handler
 */
const notFoundHandler = (req, res, next) => {
  const error = new APIError(
    `Route ${req.originalUrl} not found`,
    404,
    "ROUTE_NOT_FOUND"
  );
  next(error);
};

/**
 * Async error wrapper
 */
const asyncHandler = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next);

/**
 * Validation error handler
 */
const validationErrorHandler = (errors) => {
  const message = errors
    .array()
    .map((error) => `${error.param}: ${error.msg}`)
    .join(", ");

  return new APIError(message, 400, "VALIDATION_ERROR");
};

/**
 * Get Firebase error message
 */
function getFirebaseErrorMessage(errorCode) {
  const firebaseErrors = {
    "auth/invalid-id-token": "Invalid ID token",
    "auth/id-token-expired": "ID token has expired",
    "auth/id-token-revoked": "ID token has been revoked",
    "auth/user-not-found": "User not found",
    "auth/user-disabled": "User account has been disabled",
    "auth/invalid-uid": "Invalid user ID",
    "auth/uid-already-exists": "User ID already exists",
    "auth/email-already-exists": "Email already exists",
    "auth/invalid-email": "Invalid email address",
    "auth/invalid-password": "Invalid password",
    "auth/weak-password": "Password is too weak",
  };

  return firebaseErrors[errorCode] || "Firebase authentication error";
}

/**
 * Success response helper
 */
const successResponse = (
  res,
  data = null,
  message = "Success",
  statusCode = 200
) => {
  const response = {
    success: true,
    message,
    timestamp: new Date().toISOString(),
  };

  if (data !== null) {
    response.data = data;
  }

  return res.status(statusCode).json(response);
};

/**
 * Error response helper
 */
const errorResponse = (
  res,
  message,
  statusCode = 500,
  code = "INTERNAL_ERROR",
  details = null
) => {
  const response = {
    success: false,
    error: message,
    code,
    timestamp: new Date().toISOString(),
  };

  if (details && process.env.NODE_ENV === "development") {
    response.details = details;
  }

  return res.status(statusCode).json(response);
};

module.exports = {
  APIError,
  errorHandler,
  notFoundHandler,
  asyncHandler,
  validationErrorHandler,
  successResponse,
  errorResponse,
};
