


import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:attendance_app/view/widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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
        title: TextWidget(text: "Attendance History".tr, color: kWhite),
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
                  child: Obx(
                    () => CustomDropDown(
                      hint: 'Sort'.tr,
                      labelText: 'Sort Order'.tr,
                      items: controller.recentOptions,
                      selectedValue:
                          controller.recentOptions.contains(
                            controller.selectedRecent.value,
                          )
                          ? controller.selectedRecent.value
                          : null,
                      onChanged: controller.onRecentChanged,
                      width: double.infinity,
                      marginBottom: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Month
                Expanded(
                  child: Obx(
                    () => CustomDropDown(
                      hint: 'Month'.tr,
                      labelText: 'Month'.tr,
                      items: controller.monthOptions,
                      selectedValue:
                          controller.monthOptions.contains(
                            controller.selectedMonth.value,
                          )
                          ? controller.selectedMonth.value
                          : null,
                      onChanged: controller.onMonthChanged,
                      width: double.infinity,
                      marginBottom: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Date
                Expanded(
                  child: Obx(
                    () => IgnorePointer(
                      ignoring: controller.selectedMonth.value == null,
                      child: Opacity(
                        opacity: controller.selectedMonth.value == null
                            ? 0.5
                            : 1.0,
                        child: CustomDropDown(
                          hint: 'Date'.tr,
                          labelText: 'Date'.tr,
                          items: controller.dateOptions,
                          selectedValue:
                              controller.dateOptions.contains(
                                controller.selectedDate.value,
                              )
                              ? controller.selectedDate.value
                              : null,
                          onChanged: controller.onDateChanged,
                          width: double.infinity,
                          marginBottom: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // History list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: kPrimaryColor),
                );
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
                        text:
                            "for ${controller.selectedDate.value ?? (controller.selectedMonth.value ?? 'today')}"
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

class AttendanceCard extends StatefulWidget {
  final AttendanceLog log;
  final int position;

  const AttendanceCard({super.key, required this.log, required this.position});

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  Timer? _timer;
  String _duration = '';

  @override
  void initState() {
    super.initState();
    _updateDuration();
    if (widget.log.clockOutTime == null) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _updateDuration();
        });
      }
    });
  }

  void _updateDuration() {
    if (widget.log.clockInTime == null) {
      _duration = "N/A".tr;
      return;
    }

    // Don't convert - times are already in correct timezone
    final now = DateTime.now();
    // Remove the 'Z' marker by treating as local time
    final clockIn = DateTime.parse(widget.log.clockInTime!.toIso8601String().replaceAll('Z', ''));
    final endTime = widget.log.clockOutTime != null 
        ? DateTime.parse(widget.log.clockOutTime!.toIso8601String().replaceAll('Z', ''))
        : now;

    // Calculate duration
    final duration = endTime.difference(clockIn);

    final totalSeconds = duration.inSeconds;
    if (totalSeconds < 0) {
      _duration = '0 secs';
      return;
    }

    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    // Build duration string - only show non-zero parts
    List<String> parts = [];
    
    if (hours > 0) {
      parts.add('$hours ${hours == 1 ? 'hour' : 'hours'}');
    }
    if (minutes > 0) {
      parts.add('$minutes ${minutes == 1 ? 'min' : 'mins'}');
    }
    if (seconds >= 0) {  // Always show seconds
      parts.add('$seconds ${seconds == 1 ? 'sec' : 'secs'}');
    }

    _duration = parts.join(' ');

    // Debug prints (remove after testing)
    debugPrint('AttendanceCard #${widget.position}:');
    debugPrint('  Clock In UTC: ${widget.log.clockInTime}');
    debugPrint('  Clock In Local: $clockIn');
    debugPrint('  Now Local: $now');
    debugPrint('  Total Seconds: $totalSeconds');
    debugPrint('  Duration: $_duration');
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy');
    final timeFormat = DateFormat('hh:mm a');

    // Convert UTC times to local time for display
    final localClockIn = widget.log.clockInTime != null
        ? DateTime.parse(widget.log.clockInTime!.toIso8601String().replaceAll('Z', ''))
        : null;
    final localClockOut = widget.log.clockOutTime != null
        ? DateTime.parse(widget.log.clockOutTime!.toIso8601String().replaceAll('Z', ''))
        : null;

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
          // Position
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextWidget(
              text: "#${widget.position}".tr,
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
                text: localClockIn != null ? dateFormat.format(localClockIn) : " ",
              ),
            ],
          ),
          // Clock In
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Clock In:".tr),
              TextWidget(
                text: localClockIn != null
                    ? timeFormat.format(localClockIn)
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
                text: localClockOut != null
                    ? timeFormat.format(localClockOut)
                    : "Still Clocked In".tr,
              ),
            ],
          ),
          // Duration
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextWidget(text: "Duration:".tr),
              TextWidget(text: _duration),
            ],
          ),
        ],
      ),
    );
  }
}