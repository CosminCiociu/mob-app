const express = require("express");
const { body, validationResult } = require("express-validator");
const router = express.Router();

const { verifyFirebaseToken } = require("../middleware/auth");
const {
  asyncHandler,
  successResponse,
  errorResponse,
  validationErrorHandler,
} = require("../middleware/errorHandler");
const UserService = require("../services/UserService");

// Initialize user service
const userService = new UserService();
userService.initialize();

/**
 * @route POST /api/auth/login
 * @desc Authenticate user and generate Stream Chat token
 * @access Private (Firebase Auth required)
 */
router.post(
  "/login",
  verifyFirebaseToken,
  [
    body("userData").optional().isObject(),
    body("tokenOptions").optional().isObject(),
  ],
  asyncHandler(async (req, res) => {
    // Check validation errors
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { userData = {}, tokenOptions = {} } = req.body;
    const firebaseUid = req.user.uid;

    try {
      // Get or create user in all systems
      const user = await userService.getOrCreateUser(firebaseUid, {
        name: userData.name || req.user.name,
        image: userData.image || req.user.picture,
        email: req.user.email,
        ...userData,
      });

      // Generate Stream Chat token
      const tokenData = await userService.generateUserToken(
        firebaseUid,
        tokenOptions
      );

      return successResponse(
        res,
        {
          user: {
            uid: firebaseUid,
            email: user.firebase.email,
            name: user.stream.name,
            image: user.stream.image,
            profile: user.firestore,
          },
          streamChat: {
            token: tokenData.token,
            apiKey: process.env.STREAM_CHAT_API_KEY,
            expires: tokenData.expires,
          },
        },
        "Login successful"
      );
    } catch (error) {
      console.error("Login error:", error);
      return errorResponse(res, error.message, 500, "LOGIN_ERROR");
    }
  })
);

/**
 * @route POST /api/auth/refresh-token
 * @desc Refresh Stream Chat token
 * @access Private (Firebase Auth required)
 */
router.post(
  "/refresh-token",
  verifyFirebaseToken,
  [body("tokenOptions").optional().isObject()],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { tokenOptions = {} } = req.body;
    const firebaseUid = req.user.uid;

    try {
      // Generate new Stream Chat token
      const tokenData = await userService.generateUserToken(
        firebaseUid,
        tokenOptions
      );

      return successResponse(
        res,
        {
          token: tokenData.token,
          apiKey: process.env.STREAM_CHAT_API_KEY,
          expires: tokenData.expires,
          user: tokenData.user,
        },
        "Token refreshed successfully"
      );
    } catch (error) {
      console.error("Token refresh error:", error);
      return errorResponse(res, error.message, 500, "TOKEN_REFRESH_ERROR");
    }
  })
);

/**
 * @route GET /api/auth/profile
 * @desc Get user profile
 * @access Private (Firebase Auth required)
 */
router.get(
  "/profile",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const firebaseUid = req.user.uid;

    try {
      const profile = await userService.getUserProfile(firebaseUid);

      return successResponse(
        res,
        {
          uid: firebaseUid,
          email: profile.firebase.email,
          name: profile.firebase.displayName,
          image: profile.firebase.photoURL,
          emailVerified: profile.firebase.emailVerified,
          profile: profile.profile,
          streamUser: profile.stream,
        },
        "Profile retrieved successfully"
      );
    } catch (error) {
      console.error("Profile retrieval error:", error);
      return errorResponse(res, error.message, 500, "PROFILE_ERROR");
    }
  })
);

/**
 * @route PUT /api/auth/profile
 * @desc Update user profile
 * @access Private (Firebase Auth required)
 */
router.put(
  "/profile",
  verifyFirebaseToken,
  [
    body("name").optional().trim().isLength({ min: 1, max: 100 }),
    body("image").optional().isURL(),
    body("bio").optional().trim().isLength({ max: 500 }),
    body("preferences").optional().isObject(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const firebaseUid = req.user.uid;
    const updates = req.body;

    try {
      const updatedProfile = await userService.updateUserProfile(
        firebaseUid,
        updates
      );

      return successResponse(
        res,
        updatedProfile,
        "Profile updated successfully"
      );
    } catch (error) {
      console.error("Profile update error:", error);
      return errorResponse(res, error.message, 500, "PROFILE_UPDATE_ERROR");
    }
  })
);

/**
 * @route DELETE /api/auth/account
 * @desc Delete user account
 * @access Private (Firebase Auth required)
 */
router.delete(
  "/account",
  verifyFirebaseToken,
  [
    body("confirmDelete").isBoolean().equals(true),
    body("deleteOptions").optional().isObject(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const firebaseUid = req.user.uid;
    const { deleteOptions = {} } = req.body;

    try {
      await userService.deleteUser(firebaseUid, deleteOptions);

      return successResponse(res, null, "Account deleted successfully");
    } catch (error) {
      console.error("Account deletion error:", error);
      return errorResponse(res, error.message, 500, "ACCOUNT_DELETE_ERROR");
    }
  })
);

/**
 * @route POST /api/auth/logout
 * @desc Logout user (mainly for logging purposes)
 * @access Private (Firebase Auth required)
 */
router.post(
  "/logout",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const firebaseUid = req.user.uid;

    try {
      // Update user status in Firestore
      await userService.updateUserProfile(firebaseUid, {
        online: false,
        lastSeenAt: new Date(),
      });

      return successResponse(res, null, "Logout successful");
    } catch (error) {
      console.error("Logout error:", error);
      return errorResponse(res, error.message, 500, "LOGOUT_ERROR");
    }
  })
);

/**
 * @route GET /api/auth/validate-token
 * @desc Validate current Firebase token
 * @access Private (Firebase Auth required)
 */
router.get(
  "/validate-token",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    return successResponse(
      res,
      {
        valid: true,
        user: {
          uid: req.user.uid,
          email: req.user.email,
          name: req.user.name,
          emailVerified: req.user.emailVerified,
        },
      },
      "Token is valid"
    );
  })
);

module.exports = router;
