import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:url_launcher/url_launcher.dart';

import 'change_notification.dart';
import 'change_settings.dart';
import 'enable_in_background.dart';
import 'get_location.dart';
import 'listen_location.dart';
import 'permission_status.dart';
import 'service_enabled.dart';

const _url = 'https://github.com/Lyokone/flutterlocation';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Location',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyHomePage(title: 'Flutter Location Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});
  final String? title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Location _location = Location();

  late bool _serviceEnabled;
  late PermissionStatus _permissionGranted;
  late LocationData _locationData;

  Future<void> _showInfoDialog() {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Demo Application'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Created by Amali Krigger'),
                InkWell(
                  child: const Text(
                    _url,
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTap: () => launchUrl(Uri.parse(_url)),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> initializeBackgroundLocation() async {
    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _locationData = await _location.getLocation();
    _location.enableBackgroundMode(enable: true);

    _location.changeNotificationOptions(
      title: 'Geolocation',
      subtitle: 'Geolocation detection',
    );
  }

  @override
  void initState() {
    super.initState();
    initializeBackgroundLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showInfoDialog,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(32),
          // FIXME: This ignore can be removed when we drop support for Flutter 3.10.
          // ignore: prefer_const_constructors
          child: Column(
            // FIXME: This ignore can be removed when we drop support for Flutter 3.10.
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              const PermissionStatusWidget(),
              const Divider(height: 32),
              const ServiceEnabledWidget(),
              const Divider(height: 32),
              const GetLocationWidget(),
              const Divider(height: 32),
              const ListenLocationWidget(),
              const Divider(height: 32),
              const ChangeSettings(),
              const Divider(height: 32),
              const EnableInBackgroundWidget(),
              const Divider(height: 32),
              const ChangeNotificationWidget()
            ],
          ),
        ),
      ),
    );
  }
}
