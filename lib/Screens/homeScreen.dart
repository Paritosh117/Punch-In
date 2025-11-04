import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:punch_in/Modal/database.dart';

import '../Modal/PunchesModel.dart';
import 'historyScreen.dart';

class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  LatLng? currentLocation;
  final double designatedLat = 21.23456; // Example designated location
  final double designatedLng = 81.65432;
  bool canPunch = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are disabled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location services are disabled")),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Location permission denied")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Location permissions are permanently denied."),
        ),
      );
      return;
    }

    // Permissions granted, now get location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });

    // After location is fetched, check punch distance
    _checkLocation();
  }


  Future<void> _checkLocation() async {
    if (currentLocation == null) return; // safety check

    final distanceInMeters = Geolocator.distanceBetween(
      currentLocation!.latitude,
      currentLocation!.longitude,
      designatedLat,
      designatedLng,
    );

    print("Distance to designated location: $distanceInMeters meters");

    setState(() {
      canPunch = distanceInMeters <= 3000; // enable button if within 3 km
    });
  }

  void _punchIn() async {
    if (currentLocation == null) return;

    final now = DateTime.now();
    final punchString =
        "${now.toIso8601String()} | Lat: ${currentLocation!.latitude} | Lng: ${currentLocation!.longitude}";

    final punch = PunchesModel(time: punchString,latitude: currentLocation!.latitude,longitude: currentLocation!.longitude,address: '${currentLocation!.latitude}${currentLocation!.longitude}');

    await EmployeeDatabase.savePunch(punch); // Save in Hive

    print("Punch saved locally: $punchString");

    // Optional: show a confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Punch saved successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Punch Location"),
        backgroundColor: Colors.blueAccent,
        actions: [
          TextButton(onPressed: (){ Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PunchHistoryScreen()));}, child: Text("History",style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),)),
        ],
      ),
      body: Center(
        child: currentLocation == null
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
          onPressed: canPunch ? _punchIn : null, // disabled if !canPunch
          icon: const Icon(Icons.fingerprint),
          label: const Text(
            "Punch In",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        )

      ),
    );
  }
}
