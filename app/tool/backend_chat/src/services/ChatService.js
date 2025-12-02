const { getFirestore } = require("../config/firebase");
const {
  createChannel,
  getUserChannels,
  addChannelMembers,
  removeChannelMembers,
  getStreamChatClient,
} = require("../config/streamChat");

/**
 * Chat service for managing conversations and channels
 */
class ChatService {
  constructor() {
    this.db = null;
  }

  /**
   * Initialize the service
   */
  async initialize() {
    this.db = getFirestore();
  }

  /**
   * Create a direct message channel between two users
   */
  async createDirectMessage(userId1, userId2, options = {}) {
    try {
      // Validate users exist
      if (userId1 === userId2) {
        throw new Error("Cannot create DM channel with yourself");
      }

      // Create consistent channel ID
      const channelId = this.generateDMChannelId(userId1, userId2);

      // Check if channel already exists
      const existingChannel = await this.getChannelFromFirestore(channelId);
      if (existingChannel) {
        return existingChannel;
      }

      // Create channel in Stream Chat
      const streamChannel = await createChannel(
        "messaging",
        channelId,
        userId1,
        {
          members: [userId1, userId2],
          name: `${userId1}_${userId2}`,
          ...options,
        }
      );

      // Store channel info in Firestore
      const channelData = {
        id: channelId,
        type: "direct_message",
        members: [userId1, userId2],
        createdBy: userId1,
        createdAt: new Date(),
        updatedAt: new Date(),
        lastMessageAt: null,
        messageCount: 0,
        streamChannelId: channelId,
      };

      await this.saveChannelToFirestore(channelId, channelData);

      return {
        ...channelData,
        streamChannel,
      };
    } catch (error) {
      console.error("Error creating direct message:", error);
      throw error;
    }
  }

  /**
   * Create a group channel
   */
  async createGroupChannel(creatorId, members, channelName, options = {}) {
    try {
      // Generate unique channel ID
      const channelId = `group_${Date.now()}_${Math.random()
        .toString(36)
        .substr(2, 9)}`;

      // Ensure creator is in members list
      const allMembers = Array.from(new Set([creatorId, ...members]));

      // Create channel in Stream Chat
      const streamChannel = await createChannel("team", channelId, creatorId, {
        name: channelName,
        members: allMembers,
        ...options,
      });

      // Store channel info in Firestore
      const channelData = {
        id: channelId,
        type: "group",
        name: channelName,
        description: options.description || "",
        members: allMembers,
        admins: [creatorId],
        createdBy: creatorId,
        createdAt: new Date(),
        updatedAt: new Date(),
        lastMessageAt: null,
        messageCount: 0,
        streamChannelId: channelId,
        settings: {
          allowMemberInvites: options.allowMemberInvites !== false,
          isPrivate: options.isPrivate || false,
          ...options.settings,
        },
      };

      await this.saveChannelToFirestore(channelId, channelData);

      return {
        ...channelData,
        streamChannel,
      };
    } catch (error) {
      console.error("Error creating group channel:", error);
      throw error;
    }
  }

  /**
   * Get user's conversations/channels
   */
  async getUserConversations(userId, options = {}) {
    try {
      const defaultOptions = {
        limit: 30,
        includeStream: true,
        ...options,
      };

      // Get channels from Stream Chat
      let streamChannels = [];
      if (defaultOptions.includeStream) {
        streamChannels = await getUserChannels(userId, {
          limit: defaultOptions.limit,
        });
      }

      // Get channel details from Firestore
      const firestoreChannels = [];

      if (streamChannels.length > 0) {
        const channelIds = streamChannels.map((ch) => ch.id);
        const snapshot = await this.db
          .collection("channels")
          .where("id", "in", channelIds)
          .get();

        snapshot.forEach((doc) => {
          firestoreChannels.push({
            id: doc.id,
            ...doc.data(),
          });
        });
      }

      // Combine Stream and Firestore data
      const conversations = streamChannels.map((streamChannel) => {
        const firestoreData =
          firestoreChannels.find((fc) => fc.id === streamChannel.id) || {};

        return {
          ...firestoreData,
          streamChannel,
          lastMessage: streamChannel.state?.last_message_at || null,
          unreadCount: streamChannel.state?.unread_count || 0,
          members: streamChannel.state?.members || {},
        };
      });

      // Sort by last message time
      conversations.sort((a, b) => {
        const aTime = new Date(a.lastMessage || 0);
        const bTime = new Date(b.lastMessage || 0);
        return bTime - aTime;
      });

      return conversations;
    } catch (error) {
      console.error("Error getting user conversations:", error);
      throw error;
    }
  }

  /**
   * Add members to a channel
   */
  async addMembersToChannel(channelId, memberIds, addedBy) {
    try {
      // Get channel from Firestore
      const channel = await this.getChannelFromFirestore(channelId);
      if (!channel) {
        throw new Error("Channel not found");
      }

      // Check permissions
      if (channel.type === "group" && !channel.admins.includes(addedBy)) {
        if (!channel.settings?.allowMemberInvites) {
          throw new Error("Only admins can add members to this channel");
        }
      }

      // Add members to Stream Chat
      await addChannelMembers(
        channel.type === "group" ? "team" : "messaging",
        channelId,
        memberIds
      );

      // Update Firestore
      const updatedMembers = Array.from(
        new Set([...channel.members, ...memberIds])
      );
      await this.updateChannelInFirestore(channelId, {
        members: updatedMembers,
        updatedAt: new Date(),
      });

      return {
        success: true,
        channelId,
        addedMembers: memberIds,
        totalMembers: updatedMembers.length,
      };
    } catch (error) {
      console.error("Error adding members to channel:", error);
      throw error;
    }
  }

  /**
   * Remove members from a channel
   */
  async removeMembersFromChannel(channelId, memberIds, removedBy) {
    try {
      // Get channel from Firestore
      const channel = await this.getChannelFromFirestore(channelId);
      if (!channel) {
        throw new Error("Channel not found");
      }

      // Check permissions
      if (channel.type === "group" && !channel.admins.includes(removedBy)) {
        throw new Error("Only admins can remove members from this channel");
      }

      // Remove members from Stream Chat
      await removeChannelMembers(
        channel.type === "group" ? "team" : "messaging",
        channelId,
        memberIds
      );

      // Update Firestore
      const updatedMembers = channel.members.filter(
        (id) => !memberIds.includes(id)
      );
      await this.updateChannelInFirestore(channelId, {
        members: updatedMembers,
        updatedAt: new Date(),
      });

      return {
        success: true,
        channelId,
        removedMembers: memberIds,
        totalMembers: updatedMembers.length,
      };
    } catch (error) {
      console.error("Error removing members from channel:", error);
      throw error;
    }
  }

  /**
   * Update channel information
   */
  async updateChannel(channelId, updates, updatedBy) {
    try {
      // Get channel from Firestore
      const channel = await this.getChannelFromFirestore(channelId);
      if (!channel) {
        throw new Error("Channel not found");
      }

      // Check permissions for group channels
      if (channel.type === "group" && !channel.admins.includes(updatedBy)) {
        throw new Error("Only admins can update this channel");
      }

      // Update Stream Chat channel if needed
      const streamUpdates = {};
      if (updates.name) streamUpdates.name = updates.name;
      if (updates.description) streamUpdates.description = updates.description;

      if (Object.keys(streamUpdates).length > 0) {
        const client = getStreamChatClient();
        const streamChannel = client.channel(
          channel.type === "group" ? "team" : "messaging",
          channelId
        );
        await streamChannel.update(streamUpdates);
      }

      // Update Firestore
      const updateData = {
        ...updates,
        updatedAt: new Date(),
        updatedBy,
      };

      await this.updateChannelInFirestore(channelId, updateData);

      return {
        success: true,
        channelId,
        updates: updateData,
      };
    } catch (error) {
      console.error("Error updating channel:", error);
      throw error;
    }
  }

  /**
   * Delete/archive a channel
   */
  async deleteChannel(channelId, deletedBy, options = {}) {
    try {
      // Get channel from Firestore
      const channel = await this.getChannelFromFirestore(channelId);
      if (!channel) {
        throw new Error("Channel not found");
      }

      // Check permissions
      if (
        channel.createdBy !== deletedBy &&
        !channel.admins?.includes(deletedBy)
      ) {
        throw new Error(
          "Only channel creator or admins can delete this channel"
        );
      }

      const deleteOptions = {
        hardDelete: false,
        ...options,
      };

      if (deleteOptions.hardDelete) {
        // Hard delete from Stream Chat
        const client = getStreamChatClient();
        const streamChannel = client.channel(
          channel.type === "group" ? "team" : "messaging",
          channelId
        );
        await streamChannel.delete();

        // Delete from Firestore
        await this.db.collection("channels").doc(channelId).delete();
      } else {
        // Soft delete (archive)
        await this.updateChannelInFirestore(channelId, {
          deleted: true,
          deletedAt: new Date(),
          deletedBy,
          updatedAt: new Date(),
        });
      }

      return {
        success: true,
        channelId,
        hardDeleted: deleteOptions.hardDelete,
      };
    } catch (error) {
      console.error("Error deleting channel:", error);
      throw error;
    }
  }

  /**
   * Generate consistent DM channel ID
   */
  generateDMChannelId(userId1, userId2) {
    // Sort to ensure consistent ID regardless of order
    const sortedIds = [userId1, userId2].sort();
    return `dm_${sortedIds[0]}_${sortedIds[1]}`;
  }

  /**
   * Get channel from Firestore
   */
  async getChannelFromFirestore(channelId) {
    try {
      const doc = await this.db.collection("channels").doc(channelId).get();

      if (!doc.exists) {
        return null;
      }

      return {
        id: channelId,
        ...doc.data(),
      };
    } catch (error) {
      console.error("Error getting channel from Firestore:", error);
      throw error;
    }
  }

  /**
   * Save channel to Firestore
   */
  async saveChannelToFirestore(channelId, channelData) {
    try {
      await this.db.collection("channels").doc(channelId).set(channelData);
      console.log(`✅ Channel ${channelId} saved to Firestore`);
    } catch (error) {
      console.error("Error saving channel to Firestore:", error);
      throw error;
    }
  }

  /**
   * Update channel in Firestore
   */
  async updateChannelInFirestore(channelId, updates) {
    try {
      await this.db
        .collection("channels")
        .doc(channelId)
        .update({
          ...updates,
          updatedAt: new Date(),
        });

      console.log(`✅ Channel ${channelId} updated in Firestore`);
    } catch (error) {
      console.error("Error updating channel in Firestore:", error);
      throw error;
    }
  }

  /**
   * Get channel analytics
   */
  async getChannelAnalytics(channelId, dateRange = {}) {
    try {
      const { startDate, endDate } = dateRange;

      // This would typically query message analytics
      // For now, return basic channel info
      const channel = await this.getChannelFromFirestore(channelId);

      if (!channel) {
        throw new Error("Channel not found");
      }

      return {
        channelId,
        type: channel.type,
        memberCount: channel.members?.length || 0,
        messageCount: channel.messageCount || 0,
        createdAt: channel.createdAt,
        lastMessageAt: channel.lastMessageAt,
        // Add more analytics as needed
      };
    } catch (error) {
      console.error("Error getting channel analytics:", error);
      throw error;
    }
  }
}

module.exports = ChatService;
