


import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/generated/assets.dart';
import 'package:attendance_app/services/notification_service.dart';
import 'package:attendance_app/view/widgets/common_image_view_widget.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final RxList<NotificationRecord> notifications = <NotificationRecord>[].obs;

  @override
  void initState() {
    super.initState();
    _loadNotifications(); // Load notifications on screen initialization
  }

  Future<void> _loadNotifications() async {
    final loadedNotifications = await NotificationService.getNotifications('All');
    notifications.assignAll(loadedNotifications);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: TextWidget(text: "Notifications".tr, color: kWhite, size: 20),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kWhite),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() => notifications.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_all, color: kWhite),
                  tooltip: "Clear All",
                  onPressed: () async {
                    await NotificationService.clearAllNotifications();
                    notifications.clear(); // Update UI
                  },
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => notifications.isEmpty
                  ? Center(
                      child: TextWidget(
                        text: "No notifications found".tr,
                        size: 16,
                        color: kGreyColor,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Slidable(
                          key: ValueKey(notification.id), // Unique key for each notification
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            extentRatio: 0.3,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: GestureDetector(
                                  onTap: () async {
                                    // Delete notification and refresh list
                                    await NotificationService.deleteNotification(notification.id);
                                    await _loadNotifications(); // Refresh UI
                                  },
                                  child: CommonImageView(
                                    imagePath: Assets.imagesTrash,
                                    height: 60,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          child: Card(
                            color: kWhite,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: TextWidget(
                                text: notification.title.tr,
                                size: 16,
                                weight: FontWeight.bold,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextWidget(
                                    text: notification.body.tr,
                                    size: 14,
                                    color: kGreyColor,
                                  ),
                                  const SizedBox(height: 4),
                                  TextWidget(
                                    text: DateFormat(
                                      'MMM dd, yyyy HH:mm',
                                    ).format(notification.timestamp),
                                    size: 12,
                                    color: kGreyColor,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}