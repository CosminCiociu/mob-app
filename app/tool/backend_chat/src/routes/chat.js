const express = require("express");
const { body, query, validationResult } = require("express-validator");
const router = express.Router();

const { verifyFirebaseToken } = require("../middleware/auth");
const {
  asyncHandler,
  successResponse,
  errorResponse,
  validationErrorHandler,
} = require("../middleware/errorHandler");
const ChatService = require("../services/ChatService");

// Initialize chat service
const chatService = new ChatService();
chatService.initialize();

/**
 * @route GET /api/chat/conversations
 * @desc Get user's conversations/channels
 * @access Private (Firebase Auth required)
 */
router.get(
  "/conversations",
  verifyFirebaseToken,
  [
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("includeStream").optional().isBoolean(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const userId = req.user.uid;
    const { limit, includeStream } = req.query;

    try {
      const conversations = await chatService.getUserConversations(userId, {
        limit: parseInt(limit) || 30,
        includeStream: includeStream !== "false",
      });

      return successResponse(
        res,
        {
          conversations,
          total: conversations.length,
        },
        "Conversations retrieved successfully"
      );
    } catch (error) {
      console.error("Get conversations error:", error);
      return errorResponse(res, error.message, 500, "CONVERSATIONS_ERROR");
    }
  })
);

/**
 * @route POST /api/chat/dm
 * @desc Create or get direct message channel
 * @access Private (Firebase Auth required)
 */
router.post(
  "/dm",
  verifyFirebaseToken,
  [
    body("otherUserId").isString().trim().isLength({ min: 1 }),
    body("message").optional().trim().isLength({ max: 1000 }),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const userId = req.user.uid;
    const { otherUserId, message } = req.body;

    try {
      if (userId === otherUserId) {
        return errorResponse(
          res,
          "Cannot create DM with yourself",
          400,
          "INVALID_DM_USERS"
        );
      }

      const channel = await chatService.createDirectMessage(
        userId,
        otherUserId,
        {
          initialMessage: message,
        }
      );

      return successResponse(
        res,
        channel,
        "Direct message channel created successfully"
      );
    } catch (error) {
      console.error("Create DM error:", error);
      return errorResponse(res, error.message, 500, "CREATE_DM_ERROR");
    }
  })
);

/**
 * @route POST /api/chat/group
 * @desc Create a group channel
 * @access Private (Firebase Auth required)
 */
router.post(
  "/group",
  verifyFirebaseToken,
  [
    body("name").trim().isLength({ min: 1, max: 100 }),
    body("description").optional().trim().isLength({ max: 500 }),
    body("members").isArray({ min: 1 }),
    body("members.*").isString().trim(),
    body("isPrivate").optional().isBoolean(),
    body("allowMemberInvites").optional().isBoolean(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const creatorId = req.user.uid;
    const { name, description, members, isPrivate, allowMemberInvites } =
      req.body;

    try {
      // Validate members (ensure they don't include creator)
      const uniqueMembers = [...new Set(members)].filter(
        (id) => id !== creatorId
      );

      const channel = await chatService.createGroupChannel(
        creatorId,
        uniqueMembers,
        name,
        {
          description,
          isPrivate: isPrivate || false,
          allowMemberInvites: allowMemberInvites !== false,
        }
      );

      return successResponse(
        res,
        channel,
        "Group channel created successfully"
      );
    } catch (error) {
      console.error("Create group error:", error);
      return errorResponse(res, error.message, 500, "CREATE_GROUP_ERROR");
    }
  })
);

/**
 * @route GET /api/chat/channel/:channelId
 * @desc Get channel details
 * @access Private (Firebase Auth required)
 */
router.get(
  "/channel/:channelId",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { channelId } = req.params;
    const userId = req.user.uid;

    try {
      const channel = await chatService.getChannelFromFirestore(channelId);

      if (!channel) {
        return errorResponse(
          res,
          "Channel not found",
          404,
          "CHANNEL_NOT_FOUND"
        );
      }

      // Check if user is member of the channel
      if (!channel.members.includes(userId)) {
        return errorResponse(res, "Access denied", 403, "ACCESS_DENIED");
      }

      return successResponse(
        res,
        channel,
        "Channel details retrieved successfully"
      );
    } catch (error) {
      console.error("Get channel error:", error);
      return errorResponse(res, error.message, 500, "GET_CHANNEL_ERROR");
    }
  })
);

/**
 * @route PUT /api/chat/channel/:channelId
 * @desc Update channel
 * @access Private (Firebase Auth required)
 */
router.put(
  "/channel/:channelId",
  verifyFirebaseToken,
  [
    body("name").optional().trim().isLength({ min: 1, max: 100 }),
    body("description").optional().trim().isLength({ max: 500 }),
    body("settings").optional().isObject(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const userId = req.user.uid;
    const updates = req.body;

    try {
      const result = await chatService.updateChannel(
        channelId,
        updates,
        userId
      );

      return successResponse(res, result, "Channel updated successfully");
    } catch (error) {
      console.error("Update channel error:", error);
      return errorResponse(res, error.message, 500, "UPDATE_CHANNEL_ERROR");
    }
  })
);

/**
 * @route DELETE /api/chat/channel/:channelId
 * @desc Delete/archive channel
 * @access Private (Firebase Auth required)
 */
router.delete(
  "/channel/:channelId",
  verifyFirebaseToken,
  [body("hardDelete").optional().isBoolean()],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const userId = req.user.uid;
    const { hardDelete } = req.body;

    try {
      const result = await chatService.deleteChannel(channelId, userId, {
        hardDelete: hardDelete || false,
      });

      return successResponse(
        res,
        result,
        hardDelete
          ? "Channel deleted permanently"
          : "Channel archived successfully"
      );
    } catch (error) {
      console.error("Delete channel error:", error);
      return errorResponse(res, error.message, 500, "DELETE_CHANNEL_ERROR");
    }
  })
);

/**
 * @route POST /api/chat/channel/:channelId/members
 * @desc Add members to channel
 * @access Private (Firebase Auth required)
 */
router.post(
  "/channel/:channelId/members",
  verifyFirebaseToken,
  [
    body("memberIds").isArray({ min: 1 }),
    body("memberIds.*").isString().trim(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const userId = req.user.uid;
    const { memberIds } = req.body;

    try {
      // Remove duplicates
      const uniqueMemberIds = [...new Set(memberIds)];

      const result = await chatService.addMembersToChannel(
        channelId,
        uniqueMemberIds,
        userId
      );

      return successResponse(res, result, "Members added successfully");
    } catch (error) {
      console.error("Add members error:", error);
      return errorResponse(res, error.message, 500, "ADD_MEMBERS_ERROR");
    }
  })
);

/**
 * @route DELETE /api/chat/channel/:channelId/members
 * @desc Remove members from channel
 * @access Private (Firebase Auth required)
 */
router.delete(
  "/channel/:channelId/members",
  verifyFirebaseToken,
  [
    body("memberIds").isArray({ min: 1 }),
    body("memberIds.*").isString().trim(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const userId = req.user.uid;
    const { memberIds } = req.body;

    try {
      // Remove duplicates
      const uniqueMemberIds = [...new Set(memberIds)];

      const result = await chatService.removeMembersFromChannel(
        channelId,
        uniqueMemberIds,
        userId
      );

      return successResponse(res, result, "Members removed successfully");
    } catch (error) {
      console.error("Remove members error:", error);
      return errorResponse(res, error.message, 500, "REMOVE_MEMBERS_ERROR");
    }
  })
);

/**
 * @route GET /api/chat/channel/:channelId/analytics
 * @desc Get channel analytics
 * @access Private (Firebase Auth required)
 */
router.get(
  "/channel/:channelId/analytics",
  verifyFirebaseToken,
  [
    query("startDate").optional().isISO8601(),
    query("endDate").optional().isISO8601(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const userId = req.user.uid;
    const { startDate, endDate } = req.query;

    try {
      // First check if user has access to this channel
      const channel = await chatService.getChannelFromFirestore(channelId);

      if (!channel) {
        return errorResponse(
          res,
          "Channel not found",
          404,
          "CHANNEL_NOT_FOUND"
        );
      }

      if (!channel.members.includes(userId)) {
        return errorResponse(res, "Access denied", 403, "ACCESS_DENIED");
      }

      const analytics = await chatService.getChannelAnalytics(channelId, {
        startDate: startDate ? new Date(startDate) : undefined,
        endDate: endDate ? new Date(endDate) : undefined,
      });

      return successResponse(
        res,
        analytics,
        "Channel analytics retrieved successfully"
      );
    } catch (error) {
      console.error("Get analytics error:", error);
      return errorResponse(res, error.message, 500, "ANALYTICS_ERROR");
    }
  })
);

module.exports = router;
