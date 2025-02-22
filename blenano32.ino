#include <ArduinoBLE.h>
#include <Arduino_LSM9DS1.h>

BLEService messageService("19B10000-E8F2-537E-4F6C-D104768A1214"); // Custom service UUID
BLECharacteristic messageCharacteristic("19B10001-E8F2-537E-4F6C-D104768A1214", BLERead | BLENotify, 20); // Custom characteristic UUID

float x, y, z;
int degreesX = 0;
int degreesY = 0;

String message = ""; // The message to be sent

void setup() {
  Serial.begin(9600);
  //while (!Serial);
 
  if (!BLE.begin()) {
    Serial.println("Failed to initialize BLE!");
    while (1);
  }
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }
 
  BLE.setLocalName("Smart Care Watch"); // Set the device name
 
  BLE.setAdvertisedService(messageService); // Advertise the message service
  messageService.addCharacteristic(messageCharacteristic); // Add the message characteristic
 
  BLE.addService(messageService); // Start the service
 
  messageCharacteristic.writeValue(message.c_str()); // Set the initial value of the characteristic
 
  BLE.advertise(); // Start advertising
  Serial.print("Accelerometer sample rate = ");
  Serial.print(IMU.accelerationSampleRate());
  Serial.println("Hz");
 
  Serial.println("Waiting for a connection...");
}

void loop() {
  BLEDevice central = BLE.central();
 
  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
   
    while (central.connected()) {
      delay(100);
     
      if (IMU.accelerationAvailable()) {
        IMU.readAcceleration(x, y, z);
       
        if (x > 0.30 && y > 0.80 && message == "") {
          message = "patient needs help"; // Set the message when the condition is satisfied
          messageCharacteristic.writeValue(message.c_str()); // Send the message
        }
       
        if (x <= 0.30 && y <= -0.80 && message == "patient needs help") {
          message = ""; // Reset the message when the condition is not satisfied
          messageCharacteristic.writeValue(message.c_str()); // Clear the message
        }
      }
    }
   
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}