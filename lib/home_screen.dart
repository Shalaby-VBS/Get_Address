import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String currentAddress = "";

  @override
  void initState() {
    super.initState();
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initSettings =
        InitializationSettings(android: androidInitializationSettings);
    flutterLocalNotificationsPlugin.initialize(initSettings);
  }

  void getLocation(BuildContext context) async {
    LocationPermission permission;
    permission = await Geolocator.requestPermission();
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      developer.log("Denied");
    } else if (permission == LocationPermission.deniedForever) {
      developer.log("Denied Forever");
    }
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    setState(() {});
    await getAddressFromLatLng(position);
    sendNotification(currentAddress);
  }

  sendNotification(String body) async {
    var android = const AndroidNotificationDetails(
      'id',
      'channel',
      priority: Priority.high,
      importance: Importance.max,
    );
    var platform = NotificationDetails(android: android);
    await flutterLocalNotificationsPlugin
        .show(0, 'Users Address', body, platform, payload: '')
        .then((value) {
      developer.log("Notification received");
    });
  }

  Future<void> getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(position.latitude, position.longitude)
        .then((List<Placemark> placeMarks) {
      Placemark place = placeMarks[0];
      setState(() {
        currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
      developer.log("\x1B[32m Current Address: $currentAddress");
      debugPrint("Current Address: $currentAddress");
    }).catchError((e) {
      debugPrint("Error: $e");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xffad5389),
              Color(0xff3c1053),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGetAddressButton(() {
                getLocation(context);
              }),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "Current Location: $currentAddress",
                  style: const TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildGetAddressButton(Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 50,
        width: 160,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text(
            "Get Address",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
