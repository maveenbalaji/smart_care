# Smart Care

## Overview
Smart Care is an IoT-powered wearable wristband designed to discreetly summon assistance using gesture detection. The wristband uses an IMU sensor to detect hand gestures and communicates with a paired Flutter app via Bluetooth Low Energy (BLE). The app displays alerts and details to the caregiver, enabling timely assistance.

## Features
- **Discreet Gesture Detection**: Uses an IMU sensor to detect hand gestures, such as raising a hand, to trigger alerts.
- **BLE Communication**: Wirelessly transmits data between the wristband and the mobile app.
- **Flutter Mobile App**: Displays alerts and details of the detected gestures to the caregiver.
- **Buzzer Alert**: Provides an audible alert on the wristband when a gesture is detected.
- **Real-time Monitoring**: Enables caregivers to respond promptly to requests for assistance.

## Hardware
- **Arduino BLE Nano Sense 33**: Microcontroller board with BLE capabilities and an IMU sensor.
- **IMU Sensor**: Detects hand gestures.
- **Buzzer**: Provides audible alerts.

## Software
- **Flutter App**: Mobile application developed using Flutter to receive data from the wristband and display alerts.
- **Firmware**: Code running on the Arduino BLE Nano Sense 33 to handle gesture detection and BLE communication.

## Setup Instructions

### Prerequisites
- Arduino IDE installed on your computer.
- Flutter SDK installed and set up on your development environment.

### Hardware Setup
1. **Assemble the Wristband**:
   - Connect the IMU sensor and buzzer to the Arduino BLE Nano Sense 33.
   - Ensure all connections are secure and the components are properly housed in the wristband.

2. **Upload Firmware**:
   - Open the Arduino IDE and load the firmware code onto the Arduino BLE Nano Sense 33.
   - Ensure the firmware includes logic for gesture detection and BLE communication.

### Software Setup
1. **Clone the Flutter App Repository**:
   ```bash
   git clone https://github.com/yourusername/smart-care-flutter-app.git
   cd smart-care-flutter-app
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Flutter App**:
   ```bash
   flutter run
   ```

4. **Pair the Wristband**:
   - Open the Flutter app and navigate to the Bluetooth settings to pair the wristband with the app.

## Usage
1. **Wear the Wristband**: Ensure the wristband is securely fastened and powered on.
2. **Open the Flutter App**: Launch the Flutter app on the caregiver's mobile device.
3. **Detect Gestures**: When the user raises their hand, the wristband detects the gesture and sends an alert to the Flutter app.
4. **Receive Alerts**: The caregiver receives a notification on the Flutter app and can respond accordingly.

## Future Improvements
- **Enhanced Gesture Recognition**: Improve the accuracy and range of gestures that can be detected.
- **Additional Sensors**: Integrate more sensors for better context awareness (e.g., heart rate monitor, fall detection).
- **User Customization**: Allow users to customize the types of gestures and alerts.
- **Integration with Smart Home Systems**: Connect with smart home devices for automated responses to gestures.
## Project Images

**Smart Care Band**

![WhatsApp Image 2025-02-07 at 11 51 43_bb6296ca](https://github.com/user-attachments/assets/17459484-0b06-4b0d-93b7-de6dde5a75f5)

**Arduino Nano 33 BLE**

![WhatsApp Image 2025-02-07 at 11 51 44_fbc30f5a](https://github.com/user-attachments/assets/5abeb869-de84-4c3f-9a20-007ce73e761c)

**SMART CARE FLUTTER APP**

![WhatsApp Image 2025-02-07 at 11 51 52_59f11f71](https://github.com/user-attachments/assets/6fa81aa5-4185-4ba6-8d97-25fdcc277a23)



