import 'package:flutter/material.dart';
import 'package:seize_appios/widgets/launch_screen.dart';
import 'package:seize_appios/monitoring_service.dart';
// import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MonitoringService().init(); // Starts background polling
  runApp(SeizeApp());
}


class SeizeApp extends StatelessWidget {
  const SeizeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seize Band',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[350],
        )
      ),
      home: LaunchScreen(),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:seize_appios/widgets/launch_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// import 'screens/home_screen.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📥 [Background] Push Message: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const SeizeApp());
}

class SeizeApp extends StatelessWidget {
  const SeizeApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seize Band',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.grey[200],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[350],
        )
      ),
      home: LaunchScreen(),
    );
  }
}
*/