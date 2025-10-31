import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/utils/dimensions.dart';
import '../../../core/utils/my_color.dart';
import '../../../core/utils/my_strings.dart';
import '../../widgets/component/card/event_member_card.dart';
import '../../../data/controller/event_members_controller.dart';

class EventMembersScreen extends StatelessWidget {
  const EventMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get controller
    final controller = Get.find<EventMembersController>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: MyColor.getScreenBgColor(),
        appBar: AppBar(
          title: Text(MyStrings.eventMembers),
          backgroundColor: MyColor.getAppBarColor(),
          foregroundColor: MyColor.getPrimaryTextColor(),
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildEventHeader(controller),
            _buildTabBar(controller),
            Expanded(
              child: _buildTabBarView(controller),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventHeader(EventMembersController controller) {
    return Container(
      padding: const EdgeInsets.all(Dimensions.space15),
      margin: const EdgeInsets.all(Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardColor(),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        boxShadow: [
          BoxShadow(
            color: MyColor.lShadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Dimensions.space12),
              color: MyColor.primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.event,
              color: MyColor.primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(width: Dimensions.space15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Event Members', // Static title for now
                  style: TextStyle(
                    fontSize: Dimensions.fontLarge,
                    fontWeight: FontWeight.w600,
                    color: MyColor.getPrimaryTextColor(),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: Dimensions.space5),
                Obx(() => Text(
                      '${controller.totalMembersCount} ${MyStrings.totalMembers}',
                      style: TextStyle(
                        fontSize: Dimensions.fontSmall,
                        color: MyColor.getSecondaryTextColor(),
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(EventMembersController controller) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.space15),
      decoration: BoxDecoration(
        color: MyColor.getCardColor(),
        borderRadius: BorderRadius.circular(Dimensions.space12),
        border: Border.all(
          color: MyColor.cardBorderColor,
          width: 1,
        ),
      ),
      child: TabBar(
        indicator: BoxDecoration(
          borderRadius: BorderRadius.circular(Dimensions.space12),
          color: MyColor.primaryColor,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: MyColor.getSecondaryTextColor(),
        labelStyle: const TextStyle(
          fontSize: Dimensions.fontDefault,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: Dimensions.fontDefault,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(MyStrings.confirmed),
                    const SizedBox(width: Dimensions.space5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space8,
                        vertical: Dimensions.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Dimensions.space12),
                      ),
                      child: Text(
                        '${controller.confirmedMembers.length}',
                        style: const TextStyle(
                          fontSize: Dimensions.fontSmall,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
          Tab(
            child: Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(MyStrings.pending),
                    const SizedBox(width: Dimensions.space5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.space8,
                        vertical: Dimensions.space2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Dimensions.space12),
                      ),
                      child: Text(
                        '${controller.pendingMembers.length}',
                        style: const TextStyle(
                          fontSize: Dimensions.fontSmall,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView(EventMembersController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      return TabBarView(
        children: [
          _buildConfirmedMembersList(controller),
          _buildPendingMembersList(controller),
        ],
      );
    });
  }

  Widget _buildConfirmedMembersList(EventMembersController controller) {
    return Obx(() {
      if (controller.confirmedMembers.isEmpty) {
        return _buildEmptyState(MyStrings.noConfirmedMembers);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(
          top: Dimensions.space15,
          bottom: Dimensions.space30,
        ),
        itemCount: controller.confirmedMembers.length,
        itemBuilder: (context, index) {
          final member = controller.confirmedMembers[index];
          return EventMemberCard(
            userId: member['id'] ?? '',
            userEmail: member['email'] ?? '',
            userDisplayName: member['displayName'],
            userPhotoUrl: member['photoUrl'],
            isConfirmed: true,
            onMessage: () => controller.messageMember(member),
          );
        },
      );
    });
  }

  Widget _buildPendingMembersList(EventMembersController controller) {
    return Obx(() {
      if (controller.pendingMembers.isEmpty) {
        return _buildEmptyState(MyStrings.noPendingRequests);
      }

      return ListView.builder(
        padding: const EdgeInsets.only(
          top: Dimensions.space15,
          bottom: Dimensions.space30,
        ),
        itemCount: controller.pendingMembers.length,
        itemBuilder: (context, index) {
          final member = controller.pendingMembers[index];
          DateTime? pendingTimestamp;

          // Try to parse timestamp if it exists
          if (member['pendingTimestamp'] != null) {
            try {
              pendingTimestamp = DateTime.fromMillisecondsSinceEpoch(
                member['pendingTimestamp'] * 1000,
              );
            } catch (e) {
              pendingTimestamp = DateTime.now();
            }
          }

          return EventMemberCard(
            userId: member['id'] ?? '',
            userEmail: member['email'] ?? '',
            userDisplayName: member['displayName'],
            userPhotoUrl: member['photoUrl'],
            pendingTimestamp: pendingTimestamp,
            isConfirmed: false,
            onAccept: () => controller.acceptMember(member['id'] ?? ''),
            onDecline: () => controller.declineMember(member['id'] ?? ''),
            onMessage: () => controller.messageMember(member),
          );
        },
      );
    });
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: MyColor.getSecondaryTextColor().withOpacity(0.5),
          ),
          const SizedBox(height: Dimensions.space20),
          Text(
            message,
            style: TextStyle(
              fontSize: Dimensions.fontLarge,
              color: MyColor.getSecondaryTextColor(),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
