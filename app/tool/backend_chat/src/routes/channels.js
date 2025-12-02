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
const ChatService = require("../services/ChatService");
const { getStreamChatClient } = require("../config/streamChat");

// Initialize chat service
const chatService = new ChatService();
chatService.initialize();

/**
 * @route GET /api/channels/public
 * @desc Get public channels that user can join
 * @access Private (Firebase Auth required)
 */
router.get(
  "/public",
  verifyFirebaseToken,
  [
    query("limit").optional().isInt({ min: 1, max: 50 }),
    query("search").optional().trim().isLength({ min: 1, max: 100 }),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { limit, search } = req.query;
    const userId = req.user.uid;

    try {
      // Query public channels from Stream Chat
      const client = getStreamChatClient();

      const filter = {
        type: "team",
        // Add search filter if provided
        ...(search && { name: { $autocomplete: search } }),
      };

      const sort = { last_message_at: -1 };
      const options = {
        limit: parseInt(limit) || 20,
        presence: true,
      };

      const channels = await client.queryChannels(filter, sort, options);

      // Filter to only show public channels user is not already member of
      const publicChannels = channels
        .filter((channel) => {
          const channelData = channel.data;
          return (
            !channelData.private &&
            !Object.keys(channel.state.members).includes(userId)
          );
        })
        .map((channel) => ({
          id: channel.id,
          name: channel.data.name,
          description: channel.data.description,
          memberCount: Object.keys(channel.state.members).length,
          lastMessageAt: channel.state.last_message_at,
          image: channel.data.image,
          createdBy: channel.data.created_by_id,
        }));

      return successResponse(
        res,
        {
          channels: publicChannels,
          total: publicChannels.length,
          search: search || null,
        },
        "Public channels retrieved successfully"
      );
    } catch (error) {
      console.error("Get public channels error:", error);
      return errorResponse(
        res,
        error.message,
        500,
        "GET_PUBLIC_CHANNELS_ERROR"
      );
    }
  })
);

/**
 * @route POST /api/channels/:channelId/join
 * @desc Join a public channel
 * @access Private (Firebase Auth required)
 */
router.post(
  "/:channelId/join",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { channelId } = req.params;
    const userId = req.user.uid;

    try {
      // Get channel details from Stream Chat
      const client = getStreamChatClient();
      const channel = client.channel("team", channelId);

      // Check if channel exists and is public
      await channel.query();

      if (channel.data.private) {
        return errorResponse(
          res,
          "Cannot join private channel",
          403,
          "PRIVATE_CHANNEL"
        );
      }

      // Add user to channel
      await channel.addMembers([userId]);

      // Update Firestore if channel exists there
      try {
        await chatService.addMembersToChannel(channelId, [userId], userId);
      } catch (firestoreError) {
        // Channel might not exist in Firestore, that's ok for public channels
        console.warn("Channel not found in Firestore:", channelId);
      }

      return successResponse(
        res,
        {
          channelId,
          joined: true,
          memberCount: Object.keys(channel.state.members).length,
        },
        "Successfully joined channel"
      );
    } catch (error) {
      console.error("Join channel error:", error);
      return errorResponse(res, error.message, 500, "JOIN_CHANNEL_ERROR");
    }
  })
);

/**
 * @route POST /api/channels/:channelId/leave
 * @desc Leave a channel
 * @access Private (Firebase Auth required)
 */
router.post(
  "/:channelId/leave",
  verifyFirebaseToken,
  asyncHandler(async (req, res) => {
    const { channelId } = req.params;
    const userId = req.user.uid;

    try {
      // Remove user from Stream Chat channel
      const client = getStreamChatClient();
      const channel = client.channel("team", channelId);

      await channel.removeMembers([userId]);

      // Update Firestore if channel exists there
      try {
        await chatService.removeMembersFromChannel(channelId, [userId], userId);
      } catch (firestoreError) {
        console.warn("Channel not found in Firestore:", channelId);
      }

      return successResponse(
        res,
        {
          channelId,
          left: true,
        },
        "Successfully left channel"
      );
    } catch (error) {
      console.error("Leave channel error:", error);
      return errorResponse(res, error.message, 500, "LEAVE_CHANNEL_ERROR");
    }
  })
);

/**
 * @route GET /api/channels/:channelId/members
 * @desc Get channel members
 * @access Private (Firebase Auth required)
 */
router.get(
  "/:channelId/members",
  verifyFirebaseToken,
  [
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("offset").optional().isInt({ min: 0 }),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const { limit, offset } = req.query;
    const userId = req.user.uid;

    try {
      // Get channel from Stream Chat
      const client = getStreamChatClient();
      const channel = client.channel("team", channelId);

      await channel.query();

      // Check if user is member of the channel
      if (!Object.keys(channel.state.members).includes(userId)) {
        return errorResponse(res, "Access denied", 403, "ACCESS_DENIED");
      }

      // Get members with pagination
      const allMembers = Object.values(channel.state.members);
      const startIndex = parseInt(offset) || 0;
      const limitNum = parseInt(limit) || 50;
      const members = allMembers.slice(startIndex, startIndex + limitNum);

      const membersList = members.map((member) => ({
        uid: member.user_id,
        name: member.user.name,
        image: member.user.image,
        role: member.role,
        joinedAt: member.created_at,
        online: member.user.online,
      }));

      return successResponse(
        res,
        {
          members: membersList,
          total: allMembers.length,
          offset: startIndex,
          limit: limitNum,
          channelId,
        },
        "Channel members retrieved successfully"
      );
    } catch (error) {
      console.error("Get channel members error:", error);
      return errorResponse(res, error.message, 500, "GET_MEMBERS_ERROR");
    }
  })
);

/**
 * @route GET /api/channels/:channelId/messages
 * @desc Get channel messages
 * @access Private (Firebase Auth required)
 */
router.get(
  "/:channelId/messages",
  verifyFirebaseToken,
  [
    query("limit").optional().isInt({ min: 1, max: 100 }),
    query("before").optional().isISO8601(),
    query("after").optional().isISO8601(),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { channelId } = req.params;
    const { limit, before, after } = req.query;
    const userId = req.user.uid;

    try {
      // Get channel from Stream Chat
      const client = getStreamChatClient();
      const channel = client.channel("team", channelId);

      await channel.query();

      // Check if user is member of the channel
      if (!Object.keys(channel.state.members).includes(userId)) {
        return errorResponse(res, "Access denied", 403, "ACCESS_DENIED");
      }

      // Build query options
      const queryOptions = {
        limit: parseInt(limit) || 30,
      };

      if (before) {
        queryOptions.id_lt = before;
      }
      if (after) {
        queryOptions.id_gt = after;
      }

      // Get messages
      const response = await channel.query({
        messages: queryOptions,
      });

      const messages = response.messages.map((message) => ({
        id: message.id,
        text: message.text,
        user: {
          id: message.user.id,
          name: message.user.name,
          image: message.user.image,
        },
        createdAt: message.created_at,
        updatedAt: message.updated_at,
        attachments: message.attachments,
        type: message.type,
      }));

      return successResponse(
        res,
        {
          messages,
          total: messages.length,
          channelId,
        },
        "Channel messages retrieved successfully"
      );
    } catch (error) {
      console.error("Get channel messages error:", error);
      return errorResponse(res, error.message, 500, "GET_MESSAGES_ERROR");
    }
  })
);

/**
 * @route GET /api/channels/search
 * @desc Search channels
 * @access Private (Firebase Auth required)
 */
router.get(
  "/search",
  verifyFirebaseToken,
  [
    query("q").isString().trim().isLength({ min: 1, max: 100 }),
    query("limit").optional().isInt({ min: 1, max: 50 }),
    query("type").optional().isIn(["team", "messaging"]),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { q: searchQuery, limit, type } = req.query;
    const userId = req.user.uid;

    try {
      const client = getStreamChatClient();

      const filter = {
        members: { $in: [userId] },
        ...(type && { type }),
        $or: [
          { name: { $autocomplete: searchQuery } },
          { description: { $autocomplete: searchQuery } },
        ],
      };

      const sort = { last_message_at: -1 };
      const options = {
        limit: parseInt(limit) || 20,
      };

      const channels = await client.queryChannels(filter, sort, options);

      const searchResults = channels.map((channel) => ({
        id: channel.id,
        type: channel.type,
        name: channel.data.name,
        description: channel.data.description,
        memberCount: Object.keys(channel.state.members).length,
        lastMessageAt: channel.state.last_message_at,
        unreadCount: channel.state.unread_count,
      }));

      return successResponse(
        res,
        {
          channels: searchResults,
          total: searchResults.length,
          query: searchQuery,
        },
        "Channel search completed successfully"
      );
    } catch (error) {
      console.error("Search channels error:", error);
      return errorResponse(res, error.message, 500, "SEARCH_CHANNELS_ERROR");
    }
  })
);

/**
 * @route GET /api/channels/trending
 * @desc Get trending/popular channels
 * @access Private (Firebase Auth required)
 */
router.get(
  "/trending",
  verifyFirebaseToken,
  [
    query("limit").optional().isInt({ min: 1, max: 50 }),
    query("timeframe").optional().isIn(["24h", "7d", "30d"]),
  ],
  asyncHandler(async (req, res) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      throw validationErrorHandler(errors);
    }

    const { limit, timeframe } = req.query;
    const userId = req.user.uid;

    try {
      // Calculate time threshold based on timeframe
      const now = new Date();
      let timeThreshold;

      switch (timeframe) {
        case "24h":
          timeThreshold = new Date(now - 24 * 60 * 60 * 1000);
          break;
        case "7d":
          timeThreshold = new Date(now - 7 * 24 * 60 * 60 * 1000);
          break;
        case "30d":
        default:
          timeThreshold = new Date(now - 30 * 24 * 60 * 60 * 1000);
      }

      const client = getStreamChatClient();

      const filter = {
        type: "team",
        last_message_at: { $gte: timeThreshold.toISOString() },
      };

      const sort = { last_message_at: -1 };
      const options = {
        limit: parseInt(limit) || 20,
      };

      const channels = await client.queryChannels(filter, sort, options);

      // Filter out private channels and channels user is already in
      const trendingChannels = channels
        .filter(
          (channel) =>
            !channel.data.private &&
            !Object.keys(channel.state.members).includes(userId)
        )
        .map((channel) => ({
          id: channel.id,
          name: channel.data.name,
          description: channel.data.description,
          memberCount: Object.keys(channel.state.members).length,
          lastMessageAt: channel.state.last_message_at,
          image: channel.data.image,
        }));

      return successResponse(
        res,
        {
          channels: trendingChannels,
          total: trendingChannels.length,
          timeframe: timeframe || "30d",
        },
        "Trending channels retrieved successfully"
      );
    } catch (error) {
      console.error("Get trending channels error:", error);
      return errorResponse(res, error.message, 500, "GET_TRENDING_ERROR");
    }
  })
);

module.exports = router;
