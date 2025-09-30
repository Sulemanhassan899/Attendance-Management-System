import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:attendance_app/view/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/history_controller.dart';
import '../../../models/attendance_log_models.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HistoryController());

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: TextWidget(
          text: "Attendance History".tr,
          color: kWhite,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Recent
                Expanded(
                  child: Obx(() => CustomDropDown(
                        hint: 'Select Sort'.tr,
                        labelText: 'Sort Order'.tr,
                        items: controller.recentOptions,
                        selectedValue:
                            controller.recentOptions.contains(controller.selectedRecent.value)
                                ? controller.selectedRecent.value
                                : null,
                        onChanged: controller.onRecentChanged,
                        width: double.infinity,
                        marginBottom: 0,
                      )),
                ),
                const SizedBox(width: 10),

                // Month
                Expanded(
                  child: Obx(() => CustomDropDown(
                        hint: 'Select Month'.tr,
                        labelText: 'Month'.tr,
                        items: controller.monthOptions,
                        selectedValue:
                            controller.monthOptions.contains(controller.selectedMonth.value)
                                ? controller.selectedMonth.value
                                : null,
                        onChanged: controller.onMonthChanged,
                        width: double.infinity,
                        marginBottom: 0,
                      )),
                ),
                const SizedBox(width: 10),

                // Date
                Expanded(
                  child: Obx(() => IgnorePointer(
                        ignoring: controller.selectedMonth.value == null,
                        child: Opacity(
                          opacity: controller.selectedMonth.value == null ? 0.5 : 1.0,
                          child: CustomDropDown(
                            hint: 'Select Date'.tr,
                            labelText: 'Date'.tr,
                            items: controller.dateOptions,
                            selectedValue:
                                controller.dateOptions.contains(controller.selectedDate.value)
                                    ? controller.selectedDate.value
                                    : null,
                            onChanged: controller.onDateChanged,
                            width: double.infinity,
                            marginBottom: 0,
                          ),
                        ),
                      )),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: kPrimaryColor));
              } else if (controller.logs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.history, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      TextWidget(
                        text: "No attendance records found".tr,
                        size: 16,
                        color: Colors.grey[600],
                        weight: FontWeight.w500,
                      ),
                      const SizedBox(height: 8),
                      TextWidget(
                        text: "for ${controller.selectedDate.value ?? (controller.selectedMonth.value ?? 'today')}"
                            .tr,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: controller.fetchHistory,
                  color: kPrimaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.logs.length,
                    itemBuilder: (context, index) {
                      return AttendanceCard(
                        log: controller.logs[index],
                        position: index + 1,
                      );
                    },
                  ),
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}

class AttendanceCard extends StatelessWidget {
  final AttendanceLog log;
  final int position;

  const AttendanceCard({super.key, required this.log, required this.position});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final timeFormat = DateFormat('hh:mm a');

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // position
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextWidget(
              text: "#$position".tr,
              size: 14,
              color: kPrimaryColor,
              weight: FontWeight.bold,
            ),
          ),
          // Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Date:".tr),
              TextWidget(
                text: log.clockInTime != null
                    ? dateFormat.format(log.clockInTime!)
                    : " ",
              ),
            ],
          ),
          // Clock In
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Clock In:".tr),
              TextWidget(
                text: log.clockInTime != null
                    ? timeFormat.format(log.clockInTime!)
                    : "N/A".tr,
              ),
            ],
          ),
          // Clock Out
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Clock Out:".tr),
              TextWidget(
                text: log.clockOutTime != null
                    ? timeFormat.format(log.clockOutTime!)
                    : "Still Clocked In".tr,
              ),
            ],
          ),
          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Duration:".tr),
              TextWidget(
                text: "${log.durationMinutes ?? "Shown when clocked out".tr}",
              ),
            ],
          ),
          // Status
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //   children: [
          //     TextWidget(text: "Status:".tr),
          //     TextWidget(text: log.status ?? "No Status".tr),
          //   ],
          // ),
        ],
      ),
    );
  }
}
