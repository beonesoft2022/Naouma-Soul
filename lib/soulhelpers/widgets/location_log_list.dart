import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationLogList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: SharedPreferences.getInstance(),
      builder:
          (BuildContext context, AsyncSnapshot<SharedPreferences> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }
        SharedPreferences prefs = snapshot.data;
        if (prefs == null) {
          // Handle the null value
          return CircularProgressIndicator();
        }
        List<String> logs = prefs.getStringList('location_logs') ?? [];
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(logs[index]),
            );
          },
        );
      },
    );
  }
}
