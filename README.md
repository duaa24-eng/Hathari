# hathari_app - a smart fire monitoring Application  

Hazari is a smart fire monitoring and emergency response system designed to improve home safety through real-time monitoring and fast communication with firefighting stations. The system combines an IoT hardware device (ESP32-based fire detector), a mobile application for users, and a station interface for firefighter . It continuously monitors temperature and flame conditions, sends instant alerts during emergencies, and enables direct communication between homeowners and fire stations.

In alignment with Saudi Vision 2030, Hazari supports smart city transformation by integrating IoT, cloud services, and mobile technologies to provide a safer and more responsive residential environment.

## Features
Real-Time Fire reading: Continuously monitors temperature and flame levels using connected sensors.
Instant Emergency Alerts: Sends immediate notifications to users when abnormal temperature or fire is detected.
Direct Fire Station Communication: Automatically forwards emergency alerts to nearby fire stations for faster response.
False Alarm Handling: Allows users to cancel incorrect alerts and mark them as false alarms to improve system accuracy.
Smart Device Setup: Supports first-time device configuration using temporary WiFi provisioning.
Location-Based Emergency Support:
Stores user home location to assist firefighter teams in reaching the correct destination quickly.
Admin Device Management:
Allows administrators to monitor devices.

## Getting Started

### Prerequisites
-Flutter SDK
-Dart SDK
-Android Studio or VS Code
-Firebase Project
-Arduino IDE

### Installation 
1. Clone the repository:
-git clone https://github.com/duaa24-eng/Hathari
2. Navigate to the project directory:
cd Hazari
3. Install Flutter packages:
flutter pub get

### Running the Mobile Application
1. Connect your Android device or start an emulator.
2. Run the application:
flutter run

### Running the Hardware Device
1. Open the Arduino code in Arduino IDE.
2. Install required libraries:
ESP32
Firebaseserviceclint
DHT sensor library
Upload the code to the ESP32 board.
Power on the device and begin monitoring.

## Usage
1. Launch the Hazari application.
2. Register a new user account.
3. Connect your smart fire detection device using temporary WiFi setup.
4. Enter your home WiFi credentials.
5. Save your personal information and home location.
6. Monitor live temperature and flame readings.
7. Receive emergency alerts when danger is detected.
8. Confirm or cancel alerts as needed.
9. Fire stations receive alerts and send response confirmation.
10. Admin can monitor and manage devices.

## Project Structure

The following summarizes the main folders and files in the project: (lib/)

### Folders:
screens/user_pages/ – User interface pages.
services/ – Firebase and backend services.
screens/admin_pages/ – Admin dashboard pages.
screens/station_pages/ – Fire station pages.

### Key Dart Files:
main.dart – Application entry point.
login_user.dart – User login screen.
signup_user.dart – User registration and device setup.
Homepage_users.dart – User dashboard.
history.dart – Fire alert history.
fire_instruction.dart – Fire safety instructions.
Notification.dart – Alert notifications.
user_account_manage.dart – User profile management.
fire_alert.dart – Fire station response handling.
Homepage_admin.dart – Admin control panel.
firebase_options.dart – Firebase configuration.

## Technologies Used
Flutter
Firebase Authentication
Firebase Storage
ESP32 
Temperature Sensor
Flame Sensor
Arduino IDE
OpenStreetMap / Flutter Map

## License
Distributed under the MIT License.

## Contact

Hazari Team's leader
Email: duaaa7839@gmail.com

Project Repository:
https://github.com/duaa24-eng/Hathari
 https://github.com/duaa24-eng/Hathari.git