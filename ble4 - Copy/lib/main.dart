import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BLE Demo',
    theme: ThemeData(
      primarySwatch: Colors.red,
    ),
    home: MyHomePage(title: 'Smart Care'),
  );
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];
  StreamController<List<int>> _streamController = StreamController<List<int>>();
  bool _isPlayingSound = false;
  bool _isBlinking = false;
  String _receivedMessage = '';
  bool _showPatientDetails = false;
  String _patientName = '';
  int _patientAge = 0;
  String _patientCondition = '';
  String _patientBloodGroup = ''; // Added blood group

  StreamSubscription<List<int>>? _streamSubscription;

  void _startScan() {
    widget.flutterBlue.startScan();
  }

  void _stopScan() {
    widget.flutterBlue.stopScan();
  }

  void _refreshScan() {
    _stopScan();
    widget.devicesList.clear();
    _startScan();
  }

  _addDeviceToList(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  void _connectToDevice(BluetoothDevice device) async {
    widget.flutterBlue.stopScan();
    try {
      await device.connect();
      device.state.listen((event) {
        if (event == BluetoothDeviceState.disconnected) {
          _onDeviceDisconnected();
        }
      });
    } on PlatformException catch (e) {
      if (e.code != 'already_connected') {
        rethrow;
      }
    } finally {
      _services = await device.discoverServices();
      _setupCharacteristicSubscriptions();
    }
    setState(() {
      _connectedDevice = device;
    });
  }

  void _disconnectDevice() async {
    await _connectedDevice?.disconnect();
    setState(() {
      _connectedDevice = null;
      _services.clear();
    });
  }

  void _setupCharacteristicSubscriptions() {
    for (BluetoothService service in _services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.notify) {
          characteristic.setNotifyValue(true);
          _streamSubscription?.cancel();
          _streamSubscription = characteristic.value.listen((value) {
            _streamController.add(value);
            String receivedMessage = utf8.decode(value);
            if (receivedMessage.isNotEmpty) {
              _playBuzzerSound();
              _startBlinking();
              setState(() {
                _receivedMessage = receivedMessage; // Display in the blink box
                _showPatientDetails = true;
                // Here, you can parse the receivedMessage and update patient details accordingly
                _patientName = 'John Doe';
                _patientAge = 35;
                _patientBloodGroup = 'A+'; // Set patient blood group
                _patientCondition = 'Critical';
              });
            } else {
              _stopBlinking();
              setState(() {
                _showPatientDetails = false;
              });
            }
          });
        }
      }
    }
  }

  final AudioPlayer disconnectionAudioPlayer = AudioPlayer();

  Future<void> _playBuzzerSound({bool isDisconnectionSound = false}) async {
    String soundPath = isDisconnectionSound
        ? "C:/apps/ble4/android/asstes/disconnected.wav"
        : "C:/Users/mavee/Downloads/help.wav";

    AudioPlayer audioPlayer = isDisconnectionSound ? disconnectionAudioPlayer : widget.audioPlayer;

    try {
      await audioPlayer.setAsset(soundPath);
      await audioPlayer.play();
      audioPlayer.playerStateStream.listen((event) {
        if (event.processingState == ProcessingState.completed) {
          if (isDisconnectionSound) {
            disconnectionAudioPlayer.dispose();
          } else {
            _isPlayingSound = false;
          }
        }
      });
    } catch (e) {
      print('Error playing buzzer sound: $e');
      if (isDisconnectionSound) {
        disconnectionAudioPlayer.dispose();
      } else {
        _isPlayingSound = false;
      }
    }
  }

  void _onDeviceDisconnected() {
    _disconnectDevice();
    _playBuzzerSound(isDisconnectionSound: true);
    _showDisconnectMessage();
  }

  void _showDisconnectMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disconnected from the device.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _startBlinking() {
    setState(() {
      _isBlinking = true;
    });
  }

  void _stopBlinking() {
    setState(() {
      _isBlinking = false;
    });
  }

  @override
  void initState() {
    super.initState();

    // Listen for BLE device disconnection events
    widget.flutterBlue.connectedDevices.asStream().listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceToList(device);
        device.state.listen((event) {
          if (event == BluetoothDeviceState.disconnected) {
            _onDeviceDisconnected();
          }
        });
      }
    });

    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceToList(result.device);
      }
    });
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      containers.add(
        SizedBox(
          height: 50,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                  ],
                ),
              ),
              Expanded( // Wrap with Expanded
                child: ElevatedButton(
                  onPressed: () => _connectToDevice(device),
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8.0),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  Widget _buildInnerBox() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 50,
      decoration: BoxDecoration(
        color: _isBlinking ? Colors.black : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          _receivedMessage,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (_connectedDevice == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded( // Wrap with Expanded
                    child: ElevatedButton(
                      onPressed: _startScan,
                      child: const Text('Scan Devices'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded( // Wrap with Expanded
                    child: ElevatedButton(
                      onPressed: _stopScan,
                      child: const Text('Stop Scan'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded( // Wrap with Expanded
                    child: ElevatedButton(
                      onPressed: _refreshScan,
                      child: const Text('Refresh Scan'),
                    ),
                  ),
                ],
              ),
            ),
          if (_connectedDevice != null)
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'BE CAREFUL',
                    style: TextStyle(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: _buildInnerBox(),
                ),
              ],
            ),
          if (_connectedDevice != null && _showPatientDetails)
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(16.0),
                child: PatientDetailsWidget(
                  name: _patientName,
                  age: _patientAge,
                  bloodGroup: _patientBloodGroup,
                  condition: _patientCondition,
                  imageAssetPath : "C:/apps/ble4/android/asstes/patient.jpeg", // Replace with the actual image path
                  fontSize: 24, // Adjust the font size for Patient Details
                  imageSize: 200, // Adjust the size of the displayed image
                ),
              ),
            ),
          if (_connectedDevice == null)
            Expanded(
              child: _buildListViewOfDevices(),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _streamController.close();
    _streamSubscription?.cancel();
    widget.audioPlayer.dispose();
    disconnectionAudioPlayer.dispose();
    super.dispose();
  }
}

class PatientDetailsWidget extends StatelessWidget {
  final String name;
  final int age;
  final String bloodGroup;
  final String condition;
  final String imageAssetPath;
  final double fontSize;
  final double imageSize;

  PatientDetailsWidget({
    required this.name,
    required this.age,
    required this.bloodGroup,
    required this.condition,
    required this.imageAssetPath,
    required this.fontSize,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.grey[300],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Patient Details',
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Name: $name',
            style: TextStyle(fontSize: fontSize),
          ),
          Text(
            'Age: $age',
            style: TextStyle(fontSize: fontSize),
          ),
          Text(
            'Blood Group: $bloodGroup',
            style: TextStyle(fontSize: fontSize),
          ),
          Text(
            'Condition: $condition',
            style: TextStyle(fontSize: fontSize),
          ),
          SizedBox(height: 16),
          Image.asset(
            imageAssetPath,
            width: imageSize,
            height: imageSize,
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}
