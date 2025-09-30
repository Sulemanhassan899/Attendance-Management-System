import 'package:attendance_app/constants/app_colors.dart';
import 'package:attendance_app/view/widgets/text_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/geo_fence_model.dart';
import '../../../services/superbase_services.dart';

class GeofenceScreen extends StatelessWidget {
  final SupabaseService _supabaseService = Get.find<SupabaseService>();
  final RxList<Geofence> _geofences = <Geofence>[].obs;
  final RxBool _isLoading = true.obs;

  GeofenceScreen() {
    _fetchGeofences();
  }

  Future<void> _fetchGeofences() async {
    final geos = await _supabaseService.getGeofences();
    _geofences.assignAll(geos);
    _isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kPrimaryColor,
        title: TextWidget(text: "Geofence Locations", color: kWhite),
      ),
      body: Obx(
        () => _isLoading.value
            ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
            : ListView.builder(
                padding: EdgeInsets.all(8),
                physics: BouncingScrollPhysics(),
                shrinkWrap: true,
                itemCount: _geofences.length,
                itemBuilder: (context, index) {
                  return GeofenceCard(geofence: _geofences[index]);
                },
              ),
      ),
    );
  }
}

class GeofenceCard extends StatelessWidget {
  final Geofence geofence;

  GeofenceCard({required this.geofence});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: kWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextWidget(text: 'Name: ${geofence.name ?? "Unnamed"}'),
          TextWidget(text: 'Latitude: ${geofence.latitude}'),
          TextWidget(text: 'Longitude: ${geofence.longitude}'),
          TextWidget(text: 'Radius: ${geofence.radius} meters'),
        ],
      ),
    );
  }
}
