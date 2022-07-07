import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stalkie/pages/config_page.dart';
import 'package:stalkie/settings.dart';
import 'package:stalkie/sms_client.dart';
import 'package:stalkie/tg_client.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Home());
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Stalkie",
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const _App(),
    );
  }
}

class _App extends StatefulWidget {
  const _App({Key? key}) : super(key: key);

  @override
  State<_App> createState() => _AppState();
}

class _AppState extends State<_App> {
  late TgClient client;
  bool started = false;
  late StreamSubscription<ConnectivityResult> sub;

  Future<void> _initService() async {
    await FlutterForegroundTask.init(
        androidNotificationOptions: AndroidNotificationOptions(
            channelId: 'notification_channel_id',
            channelName: 'Stalkie Notification',
            channelDescription: 'Stalkie is running',
            channelImportance: NotificationChannelImportance.LOW,
            priority: NotificationPriority.LOW,
            isSticky: false,
            iconData: const NotificationIconData(
                resType: ResourceType.mipmap,
                resPrefix: ResourcePrefix.ic,
                name: 'launcher')),
        foregroundTaskOptions: const ForegroundTaskOptions(
          autoRunOnBoot: false,
          allowWifiLock: true,
        ));
  }

  Future<bool> _startService() async {
    var token = AppSettings.getBotToken();
    if (token != null && token.isNotEmpty) {
      await FlutterForegroundTask.startService(
        notificationTitle: 'Stalkie is running',
        notificationText: 'Stalkie is running',
      );
      client = TgClient(token);
      await client.start();
      if (AppSettings.getSendheartbeat()) {
        await SmsClient.sendSMS("Stalkie is on");
      }
      return true;
    }
    return false;
  }

  Future<bool> _stopService() async {
    if (AppSettings.getSendheartbeat()) {
      await SmsClient.sendSMS("Stalkie is off");
    }
    client.stop();
    return await FlutterForegroundTask.stopService();
  }

  @override
  void initState() {
    super.initState();
    AppSettings.load();
    _askPermissions();
    _initService();
    _checkConnectivity();
  }

  @override
  dispose() {
    super.dispose();
    sub.cancel();
  }

  Future<void> _start() async {
    try {
      if (await _startService()) {
        setState(() {
          started = true;
        });
      }
    } catch (e) {
      setState(() {
        started = false;
      });
    }
  }

  Future<void> _stop() async {
    try {
      await _stopService();
    } finally {
      setState(() {
        started = false;
      });
    }
  }

  Future<void> _askPermissions() async {
    var neededPerm = [
      Permission.location,
      Permission.camera,
      Permission.storage,
      Permission.microphone,
      Permission.sms
    ];
    await neededPerm.request();
  }

  void _checkConnectivity() {
    sub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      switch (result) {
        case ConnectivityResult.none:
          if (started) await _stop();
          break;
        case ConnectivityResult.ethernet:
        case ConnectivityResult.mobile:
        case ConnectivityResult.wifi:
          if (!started) await _start();
          break;
        case ConnectivityResult.bluetooth:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Stalkie',
        theme: ThemeData(
          primarySwatch: Colors.red,
        ),
        home: WithForegroundTask(
            child: Scaffold(
                appBar: AppBar(title: const Text("Stalkie")),
                drawer: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 80, 0, 0),
                  child: Drawer(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      children: [
                        ListTile(
                          title: const Text(
                            "Configuration",
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) {
                                return ConfigPage(
                                  onSave: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(const SnackBar(
                                      content: Text("Configuration saved"),
                                    ));
                                  },
                                );
                              }),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                body: Center(
                    child: Text(
                  started ? "Running" : "Stopped",
                  style: const TextStyle(fontSize: 50),
                )))));
  }
}
