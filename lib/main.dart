//ناقص صفحات عادية بتاكد منهم بكرة 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/logopage.dart';
import 'screens/Welcome_screen.dart';
import 'package:hathari_app/screens/login_user.dart'; //user1
import 'screens/users_pages/singup_user.dart'; //user2
import 'screens/users_pages/device_Setup.dart'; //user3
import 'screens/users_pages/devuce_setup2.dart'; //user4
import 'screens/station_pages/login_station.dart'; //station1
import 'screens/station_pages/request.dart'; //station2
import 'package:hathari_app/screens/users_pages/Homepage_user.dart'; //user5
import 'package:hathari_app/screens/station_pages/dash_station.dart'; //station3
import 'package:hathari_app/screens/admin_pages/Homepage_admin.dart'; //admin1
import 'package:hathari_app/screens/admin_pages/setting_admin.dart'; //admin2
import 'package:hathari_app/screens/admin_pages/station_manage.dart'; //admin3
import 'package:hathari_app/screens/Notification.dart'; 
import 'package:hathari_app/screens/admin_pages/inst.dart'; //admin4
import 'package:hathari_app/screens/admin_pages/alertMang.dart';  //admin5
import 'package:hathari_app/screens/admin_pages/devicemange.dart'; //admin6
import 'package:hathari_app/screens/admin_pages/userMange.dart';  //admin7
import 'package:hathari_app/screens/admin_pages/noti.dart';  //admin8
import 'package:hathari_app/screens/users_pages/history.dart';  //user6
import 'package:hathari_app/screens/users_pages/fire_instuctions.dart';  //user7
import 'package:hathari_app/screens/users_pages/user_account_management.dart'; //user9
import 'package:hathari_app/screens/users_pages/arrival_confirmation.dart'; //user13
import 'package:hathari_app/screens/station_pages/fire_alert.dart'; //station4
import 'package:hathari_app/screens/station_pages/station_history.dart'; //station5
import 'package:hathari_app/screens/station_pages/manage_station.dart'; //station6
import 'package:hathari_app/screens/admin_pages/guide.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // autدال القيم اليدوية بـ DefaultFirebaseOptions لضمان عملها على كل المنصات
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // test for conect firebase
    print("==========================");
    print("successfully ");
    print("==========================");
  } catch (e) {
    print("Firebase Error: $e ");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => LogoPage(),
        '/welcome': (context) => WelcomeScreen(),
        'login' :(context) => LoginUser(),//forb user
        'singupUser' :(context) => SignUpUser(),// for user 
        'device1' :(context) => UserDeviceSetup(),// cmpleted sign up for user
        'device2' :(context) => UserDeviceSetup2(),// the same idea ^
        'loginStation' :(context) => LoginStation(),
        'requestStation' :(context) => FirestationRequest(),
        //'homepageuser' :(context) => UserHome(), //home page user 
        'dashbourd' :(context) => StationHome(),//home page station
        'Home page admin': (context) => AdminDashboard(),  //home page admin
        'setting_admin': (context) => SettingsScreen(), //setting_admin
        'station manage': (context) => StationManagement(),
        'Notification':(context) => SendNotificationScreen(),//send
        'inst':(context) => InstructionsMenuScreen (), 
        'notification manage': (context) => AdminNotificationsScreen(),
        'alertma':(context) => AlertManagementScreen(),
        'devicemange' :(context) => DeviceManagement(),
        'usermanage': (context) => UserManagement(),
        //'fire_instructions': (context) => InstructionCard(),
        'app_guide': (context) => GuideScreen (),
        //'user_account_managmenet': => ManageAccountScreen(),
        'history*': (context) =>  FireHistoryScreen(),
        'station_history': (context) => stationHistoryScreen(),
        'manage_station': (context) => ManageStationScreen(),
        'inst_admin' : (context) => InstructionsMenuScreen(),

      },
    );
  }
}