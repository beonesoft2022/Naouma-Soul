import 'package:flutter/material.dart';
import '../services/LocationService.txt';
import '../widgets/location_log_list.dart';

class LocationScreen extends StatelessWidget {
  final LocationService locationService = LocationService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Tracker'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () async {
              await locationService.startLocationTracking();
            },
            child: Text('Start Tracking'),
          ),
          ElevatedButton(
            onPressed: () async {
              await locationService.stopLocationTracking();
            },
            child: Text('Stop Tracking'),
          ),
          Expanded(
            child: LocationLogList(),
          ),
        ],
      ),
    );
  }
}
