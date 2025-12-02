const express = require("express");
const { query, validationResult } = require("express-validator");
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
 * @route GET /api/users/search
 * @desc Search for users
 * @access Private (Firebase Auth required)
 */
router.get(
  "/search",
  verifyFirebaseToken,
  [
    query("q").optional().trim().isLength({ min: 1, max: 100 }),
    query("limit").optional().isInt({ min: 1, max: 50 }),
    query("role").optional().isIn(["user", "admin", "moderator"]),
    query("online").optional().isBoolean(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { q: query, limit, role, online } = req.query;
    const currentUserId = req.user.uid;

    try {
      const filters = {};
      if (role) filters.role = role;
      if (online !== undefined) filters.online = online === "true";

      const users = await userService.searchUsers(
        query || "",
        filters,
        parseInt(limit) || 20
      );

      // Filter out current user from results
      const filteredUsers = users
        .filter((user) => user.uid !== currentUserId)
        .map((user) => ({
          uid: user.uid,
          name: user.name,
          image: user.image,
          email: user.email,
          online: user.online,
          role: user.role,
          lastSeenAt: user.lastSeenAt,
        }));

      return successResponse(
        res,
        {
          users: filteredUsers,
          total: filteredUsers.length,
          query: query || "",
          filters,
        },
        "Users retrieved successfully"
      );
    } catch (error) {
      console.error("Search users error:", error);
      return errorResponse(res, error.message, 500, "SEARCH_USERS_ERROR");
    }
  })
);

/**
 * @route GET /api/users/:userId
 * @desc Get user profile by ID
 * @access Private (Firebase Auth required)
 */
router.get(
  "/:userId",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const currentUserId = req.user.uid;

    try {
      const profile = await userService.getUserProfile(userId);

      if (!profile) {
        return errorResponse(res, "User not found", 404, "USER_NOT_FOUND");
      }

      // Return limited info if not viewing own profile
      const isOwnProfile = userId === currentUserId;

      const userInfo = {
        uid: userId,
        name: profile.firebase?.displayName || profile.profile?.name,
        image: profile.firebase?.photoURL || profile.profile?.image,
        online: profile.profile?.online,
        lastSeenAt: profile.profile?.lastSeenAt,
        role: profile.profile?.role,
      };

      // Add additional info if viewing own profile
      if (isOwnProfile) {
        userInfo.email = profile.firebase?.email;
        userInfo.emailVerified = profile.firebase?.emailVerified;
        userInfo.bio = profile.profile?.bio;
        userInfo.preferences = profile.profile?.preferences;
        userInfo.createdAt = profile.profile?.createdAt;
      }

      return successResponse(
        res,
        userInfo,
        "User profile retrieved successfully"
      );
    } catch (error) {
      console.error("Get user profile error:", error);
      return errorResponse(res, error.message, 500, "GET_USER_ERROR");
    }
  })
);

/**
 * @route GET /api/users/:userId/conversations
 * @desc Get conversations between current user and specified user
 * @access Private (Firebase Auth required)
 */
router.get(
  "/:userId/conversations",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const currentUserId = req.user.uid;

    try {
      if (userId === currentUserId) {
        return errorResponse(
          res,
          "Cannot get conversations with yourself",
          400,
          "INVALID_USER"
        );
      }

      // This would typically get shared conversations between two users
      // For now, we'll check if there's a DM channel between them
      const ChatService = require("../services/ChatService");
      const chatService = new ChatService();
      await chatService.initialize();

      const dmChannelId = chatService.generateDMChannelId(
        currentUserId,
        userId
      );
      const dmChannel = await chatService.getChannelFromFirestore(dmChannelId);

      const conversations = dmChannel ? [dmChannel] : [];

      return successResponse(
        res,
        {
          conversations,
          total: conversations.length,
          otherUser: userId,
        },
        "Conversations retrieved successfully"
      );
    } catch (error) {
      console.error("Get user conversations error:", error);
      return errorResponse(
        res,
        error.message,
        500,
        "GET_USER_CONVERSATIONS_ERROR"
      );
    }
  })
);

/**
 * @route GET /api/users/online
 * @desc Get online users
 * @access Private (Firebase Auth required)
 */
router.get(
  "/online",
  verifyFirebaseToken,
  [query("limit").optional().isInt({ min: 1, max: 100 })],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { limit } = req.query;
    const currentUserId = req.user.uid;

    try {
      const onlineUsers = await userService.searchUsers(
        "",
        {
          online: true,
        },
        parseInt(limit) || 50
      );

      // Filter out current user and limit returned data
      const filteredUsers = onlineUsers
        .filter((user) => user.uid !== currentUserId)
        .map((user) => ({
          uid: user.uid,
          name: user.name,
          image: user.image,
          role: user.role,
          lastSeenAt: user.lastSeenAt,
        }));

      return successResponse(
        res,
        {
          users: filteredUsers,
          total: filteredUsers.length,
        },
        "Online users retrieved successfully"
      );
    } catch (error) {
      console.error("Get online users error:", error);
      return errorResponse(res, error.message, 500, "GET_ONLINE_USERS_ERROR");
    }
  })
);

/**
 * @route POST /api/users/batch-update
 * @desc Batch update users (admin only)
 * @access Private (Firebase Auth + Admin required)
 */
router.post(
  "/batch-update",
  verifyFirebaseToken,
  // TODO: Add admin role check middleware
  asyncHandler(async (req, res) => {
    const { updates } = req.body;

    if (!Array.isArray(updates)) {
      return errorResponse(
        res,
        "Updates must be an array",
        400,
        "INVALID_INPUT"
      );
    }

    try {
      const result = await userService.batchUpdateUsers(updates);

      return successResponse(
        res,
        {
          success: result,
          updatedCount: updates.length,
        },
        "Batch update completed successfully"
      );
    } catch (error) {
      console.error("Batch update users error:", error);
      return errorResponse(res, error.message, 500, "BATCH_UPDATE_ERROR");
    }
  })
);

/**
 * @route GET /api/users/stats
 * @desc Get user statistics (admin only)
 * @access Private (Firebase Auth + Admin required)
 */
router.get(
  "/stats",
  verifyFirebaseToken,
  // TODO: Add admin role check middleware
  asyncHandler(async (req, res) => {
    try {
      // This would typically aggregate user statistics
      // For now, return basic stats
      const stats = {
        totalUsers: 0,
        onlineUsers: 0,
        newUsersToday: 0,
        // Add more stats as needed
      };

      return successResponse(
        res,
        stats,
        "User statistics retrieved successfully"
      );
    } catch (error) {
      console.error("Get user stats error:", error);
      return errorResponse(res, error.message, 500, "GET_STATS_ERROR");
    }
  })
);

/**
 * @route PUT /api/users/:userId/status
 * @desc Update user online status
 * @access Private (Firebase Auth required - own status only)
 */
router.put(
  "/:userId/status",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { userId } = req.params;
    const currentUserId = req.user.uid;
    const { online, lastSeenAt } = req.body;

    try {
      // Users can only update their own status
      if (userId !== currentUserId) {
        return errorResponse(
          res,
          "Can only update your own status",
          403,
          "ACCESS_DENIED"
        );
      }

      const updateData = {};
      if (typeof online === "boolean") {
        updateData.online = online;
      }
      if (lastSeenAt) {
        updateData.lastSeenAt = new Date(lastSeenAt);
      }

      if (Object.keys(updateData).length === 0) {
        return errorResponse(
          res,
          "No valid status updates provided",
          400,
          "INVALID_INPUT"
        );
      }

      const updatedUser = await userService.updateUserProfile(
        userId,
        updateData
      );

      return successResponse(
        res,
        {
          uid: userId,
          online: updatedUser.online,
          lastSeenAt: updatedUser.lastSeenAt,
        },
        "Status updated successfully"
      );
    } catch (error) {
      console.error("Update user status error:", error);
      return errorResponse(res, error.message, 500, "UPDATE_STATUS_ERROR");
    }
  })
);

module.exports = router;
