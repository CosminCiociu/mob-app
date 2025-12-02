const { StreamChat } = require("stream-chat");

let streamChatClient = null;

/**
 * Initialize Stream Chat client
 */
async function initializeStreamChat() {
  try {
    if (streamChatClient) {
      console.log("Stream Chat already initialized");
      return streamChatClient;
    }

    const apiKey = process.env.STREAM_CHAT_API_KEY;
    const secret = process.env.STREAM_CHAT_SECRET;

    if (!apiKey || !secret) {
      throw new Error("Stream Chat API_KEY and SECRET are required");
    }

    // Initialize Stream Chat client
    streamChatClient = StreamChat.getInstance(apiKey, secret);

    console.log("✅ Stream Chat client initialized successfully");
    return streamChatClient;
  } catch (error) {
    console.error("❌ Stream Chat initialization failed:", error);
    throw error;
  }
}

/**
 * Get Stream Chat client instance
 */
function getStreamChatClient() {
  if (!streamChatClient) {
    throw new Error(
      "Stream Chat not initialized. Call initializeStreamChat() first."
    );
  }
  return streamChatClient;
}

/**
 * Create or update a user in Stream Chat
 */
async function upsertStreamUser(userId, userData) {
  try {
    const client = getStreamChatClient();

    const streamUserData = {
      id: userId,
      name: userData.name || userData.displayName || "Unknown User",
      image: userData.image || userData.photoURL || "",
      ...userData,
    };

    // Upsert user in Stream Chat
    const response = await client.upsertUser(streamUserData);
    console.log(`✅ Stream user ${userId} upserted successfully`);

    return response;
  } catch (error) {
    console.error(`❌ Failed to upsert Stream user ${userId}:`, error);
    throw error;
  }
}

/**
 * Generate Stream Chat token for a user
 */
function generateStreamToken(userId, options = {}) {
  try {
    const client = getStreamChatClient();

    // Generate token with optional expiration
    const token = client.createToken(userId, options.exp);

    console.log(`✅ Stream token generated for user: ${userId}`);
    return token;
  } catch (error) {
    console.error(`❌ Failed to generate Stream token for ${userId}:`, error);
    throw error;
  }
}

/**
 * Delete a user from Stream Chat
 */
async function deleteStreamUser(userId, options = {}) {
  try {
    const client = getStreamChatClient();

    // Default options for user deletion
    const deleteOptions = {
      mark_messages_deleted: true,
      hard_delete: false,
      ...options,
    };

    await client.deleteUser(userId, deleteOptions);
    console.log(`✅ Stream user ${userId} deleted successfully`);
  } catch (error) {
    console.error(`❌ Failed to delete Stream user ${userId}:`, error);
    throw error;
  }
}

/**
 * Get Stream Chat user
 */
async function getStreamUser(userId) {
  try {
    const client = getStreamChatClient();

    const response = await client.queryUsers({ id: userId });

    if (response.users && response.users.length > 0) {
      return response.users[0];
    }

    return null;
  } catch (error) {
    console.error(`❌ Failed to get Stream user ${userId}:`, error);
    throw error;
  }
}

/**
 * Create a channel between users
 */
async function createChannel(channelType, channelId, creatorId, options = {}) {
  try {
    const client = getStreamChatClient();

    const channel = client.channel(channelType, channelId, {
      created_by_id: creatorId,
      ...options,
    });

    await channel.create();
    console.log(`✅ Channel ${channelId} created successfully`);

    return channel;
  } catch (error) {
    console.error(`❌ Failed to create channel ${channelId}:`, error);
    throw error;
  }
}

/**
 * Query user channels
 */
async function getUserChannels(userId, options = {}) {
  try {
    const client = getStreamChatClient();

    const defaultOptions = {
      filter_conditions: { members: { $in: [userId] } },
      sort: { last_message_at: -1 },
      limit: 30,
      ...options,
    };

    const response = await client.queryChannels(
      defaultOptions.filter_conditions,
      defaultOptions.sort,
      { limit: defaultOptions.limit }
    );

    console.log(`✅ Retrieved ${response.length} channels for user ${userId}`);
    return response;
  } catch (error) {
    console.error(`❌ Failed to get channels for user ${userId}:`, error);
    throw error;
  }
}

/**
 * Add members to a channel
 */
async function addChannelMembers(channelType, channelId, memberIds) {
  try {
    const client = getStreamChatClient();

    const channel = client.channel(channelType, channelId);
    await channel.addMembers(memberIds);

    console.log(
      `✅ Added members ${memberIds.join(", ")} to channel ${channelId}`
    );
    return true;
  } catch (error) {
    console.error(`❌ Failed to add members to channel ${channelId}:`, error);
    throw error;
  }
}

/**
 * Remove members from a channel
 */
async function removeChannelMembers(channelType, channelId, memberIds) {
  try {
    const client = getStreamChatClient();

    const channel = client.channel(channelType, channelId);
    await channel.removeMembers(memberIds);

    console.log(
      `✅ Removed members ${memberIds.join(", ")} from channel ${channelId}`
    );
    return true;
  } catch (error) {
    console.error(
      `❌ Failed to remove members from channel ${channelId}:`,
      error
    );
    throw error;
  }
}

module.exports = {
  initializeStreamChat,
  getStreamChatClient,
  upsertStreamUser,
  generateStreamToken,
  deleteStreamUser,
  getStreamUser,
  createChannel,
  getUserChannels,
  addChannelMembers,
  removeChannelMembers,
};
