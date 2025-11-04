import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:punch_in/Modal/database.dart';

import '../Modal/PunchesModel.dart';

class PunchHistoryScreen extends StatefulWidget {
  const PunchHistoryScreen({super.key});

  @override
  State<PunchHistoryScreen> createState() => _PunchHistoryScreenState();
}

class _PunchHistoryScreenState extends State<PunchHistoryScreen> {
  List<PunchesModel> recentPunches = [];
  Set<Marker> markers = {};
  Set<Polyline> polylines = {}; // 🔹 Added for polyline
  GoogleMapController? mapController;
  LatLng? currentLocation;
  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadRecentPunches();
  }

  Future<void> _loadRecentPunches() async {
    final box = await Hive.openBox<PunchesModel>('Employee');
    final allPunches = box.values.toList();

    final now = DateTime.now();
    final fiveDaysAgo = now.subtract(const Duration(days: 5));

    // Filter punches from last 5 days
    recentPunches = allPunches.where((p) {
      try {
        final dateTimePart = p.time.split('|')[0].trim();
        final dateTime = DateTime.parse(dateTimePart);
        return dateTime.isAfter(fiveDaysAgo);
      } catch (_) {
        return false;
      }
    }).toList();

    // 🔹 Sort by oldest to newest
    recentPunches.sort((a, b) {
      final dateA =
          DateTime.tryParse(a.time.split('|')[0].trim()) ?? DateTime.now();
      final dateB =
          DateTime.tryParse(b.time.split('|')[0].trim()) ?? DateTime.now();
      return dateA.compareTo(dateB);
    });

    // Create map markers and polyline points
    markers.clear();
    List<LatLng> polylinePoints = [];

    for (var punch in recentPunches) {
      final parts = punch.time.split('|');
      if (parts.length >= 3) {
        final latString = parts[1].replaceAll("Lat:", "").trim();
        final lngString = parts[2].replaceAll("Lng:", "").trim();

        final latitude = double.tryParse(latString);
        final longitude = double.tryParse(lngString);

        if (latitude != null && longitude != null) {
          final position = LatLng(latitude, longitude);

          markers.add(
            Marker(
              markerId: MarkerId("${latitude}_${longitude}_${parts[0]}"),
              position: position,
              infoWindow: InfoWindow(
                title: "Punch Location",
                snippet: parts[0].trim(),
              ),
            ),
          );
          polylinePoints.add(position);
          setState(() {
            // Update markers and recentPunches
          });

// Animate camera after state updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _moveCameraToInitialPosition();
          });// 🔹 Collect points for polyline
        }
      }
    }

    // 🔹 Add polyline connecting all points
    polylines.clear();
    if (polylinePoints.length > 1) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId("punch_path"),
          points: polylinePoints,
          color: Colors.blue,
          width: 4,
        ),
      );
    }

    setState(() {});
  }
  void _moveCameraToInitialPosition() {
    if (mapController != null) {
      if (recentPunches.isNotEmpty && markers.isNotEmpty) {
        // Center on the first punch location
        final firstMarker = markers.first.position;
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: firstMarker, zoom: 12),
          ),
        );
      } else if (currentLocation != null) {
        // No punches, center on current location
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLocation!, zoom: 12),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }
  @override
  Widget build(BuildContext context) {
    final hasData = markers.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Punch History"),
        actions: [
          TextButton(
              onPressed: () {
                EmployeeDatabase.clearPunches();
              },
              child: Text("Clear"))
        ],
      ),
      body:Column(
    children: [
    // 🔹 Map at the top
    SizedBox(
    height: 300, // adjust as needed
      child:
      GoogleMap(
        initialCameraPosition: CameraPosition(
          target: currentLocation ?? const LatLng(20.5937, 78.9629),
          zoom: 12,
        ),
        markers: markers,
        polylines: polylines,
        myLocationEnabled: true,
        onMapCreated: (controller) {
          mapController = controller;
          _moveCameraToInitialPosition(); // ensure proper centering
        },
      )

    ),

    const SizedBox(height: 10),

    // 🔹 Punch list below
    Expanded(
    child: recentPunches.isEmpty
    ? const Center(
    child: Text(
    "No Punches Recorded",
    style: TextStyle(fontSize: 16),
    ),
    )
        : ListView.builder(
    itemCount: recentPunches.length,
    itemBuilder: (context, index) {
    final punch = recentPunches[index];
    final parts = punch.time.split('|');
    final dateTimePart = parts[0].trim();
    final latPart = parts.length > 1
    ? parts[1].replaceAll("Lat:", "").trim()
        : "";
    final lngPart = parts.length > 2
    ? parts[2].replaceAll("Lng:", "").trim()
        : "";

    DateTime? parsedDate;
    try {
    parsedDate = DateTime.parse(dateTimePart);
    } catch (_) {}

    final date = parsedDate != null
    ? "${parsedDate.day}-${parsedDate.month}-${parsedDate.year}"
        : dateTimePart;
    final time = parsedDate != null
    ? "${parsedDate.hour}:${parsedDate.minute.toString().padLeft(2, '0')}"
        : "";

    return Card(
    margin:
    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: ListTile(
    leading:
    const Icon(Icons.location_on, color: Colors.blue),
    title: Text(
    "Date: $date  |  Time: $time",
    style: const TextStyle(fontWeight: FontWeight.bold),
    ),
    subtitle: Text("Lat: $latPart, Lng: $lngPart"),
    ),
    );
    },
    ),
    ),
    ],
    ),
    );
  }

  LatLng _getInitialPosition() {
    // Default position (India) if no punches
    if (markers.isEmpty) return const LatLng(20.5937, 78.9629);

    // Use the first punch as map center
    final firstMarker = markers.first.position;
    return LatLng(firstMarker.latitude, firstMarker.longitude);
  }
}
