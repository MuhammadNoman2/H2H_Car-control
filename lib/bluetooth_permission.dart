import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart';

class BluetoothPermissionScreen extends StatefulWidget {
  const BluetoothPermissionScreen({super.key});

  @override
  _BluetoothPermissionScreenState createState() =>
      _BluetoothPermissionScreenState();
}

class _BluetoothPermissionScreenState extends State<BluetoothPermissionScreen> {
  bool isBluetoothEnabled = false;
  bool isLoading = true;
  bool isDiscovering = false;
  List<BluetoothDiscoveryResult> devices = [];
  BluetoothConnection? connection;
  String? connectedDeviceName;
  String? connectedDeviceAddress;

  @override
  void initState() {
    super.initState();
    _checkBluetoothState();
  }

  // Check Bluetooth state on app start
  Future<void> _checkBluetoothState() async {
    bool state = await FlutterBluetoothSerial.instance.isEnabled ?? false;
    setState(() {
      isBluetoothEnabled = state;
      isLoading = false;
    });
  }

  // Request Bluetooth permissions for Android 12 and above
  Future<bool> _requestBluetoothPermissions() async {
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted &&
        await Permission.location.isGranted) {
      return true;
    }

    // Request the necessary permissions
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    return statuses[Permission.bluetoothScan]?.isGranted == true &&
        statuses[Permission.bluetoothConnect]?.isGranted == true &&
        statuses[Permission.location]?.isGranted == true;
  }

  // Toggle Bluetooth ON/OFF with permission check
  Future<void> _toggleBluetooth() async {
    if (await _requestBluetoothPermissions()) {
      setState(() => isLoading = true);
      if (isBluetoothEnabled) {
        await FlutterBluetoothSerial.instance.requestDisable();
      } else {
        await FlutterBluetoothSerial.instance.requestEnable();
      }
      await _checkBluetoothState();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bluetooth permissions are required.')),
      );
    }
  }

  // Start discovering devices
  void _discoverDevices() {
    if (isDiscovering) return;

    setState(() {
      isDiscovering = true;
      devices.clear();
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((result) {
      setState(() {
        devices.add(result);
      });
    }).onDone(() {
      setState(() => isDiscovering = false);
    });
  }

  // Connect to the selected Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      bool isDevicePaired = await _isDevicePaired(device);

      if (!isDevicePaired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please pair the device in system settings')),
        );
        return;
      }

      BluetoothConnection connection =
      await BluetoothConnection.toAddress(device.address);
      setState(() {
        connectedDeviceName = device.name;
        connectedDeviceAddress = device.address;
        this.connection = connection;
      });

      // Navigate back to the home screen with connection data
      Navigator.pop(context, {
        'connection': connection,
        'deviceName': device.name,
        'deviceAddress': device.address,
      });
    } catch (e) {
      // Navigate back to the home screen and display error
      Navigator.pop(context, null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to ${device.name}')),
      );
    }
  }

  // Check if the device is paired
  Future<bool> _isDevicePaired(BluetoothDevice device) async {
    List<BluetoothDevice> pairedDevices =
    await FlutterBluetoothSerial.instance.getBondedDevices();
    return pairedDevices.any((d) => d.address == device.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text('Bluetooth Connection'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C9F50), Color(0xFF81C784)], // Green gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Bluetooth status card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.green[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 5,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bluetooth Status:',
                        style: TextStyle(fontSize: 18),
                      ),
                      Switch(
                        activeColor: Colors.green,
                        inactiveTrackColor: Colors.grey,
                        activeTrackColor: Colors.green[100],
                        value: isBluetoothEnabled,
                        onChanged: (_) => _toggleBluetooth(),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Connected device information
            if (connectedDeviceName != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: ListTile(
                    title: Text(
                      'Connected to $connectedDeviceName',
                      style: TextStyle(fontSize: 18),
                    ),
                    subtitle: Text('Address: $connectedDeviceAddress'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        connection?.close();
                        setState(() {
                          connectedDeviceName = null;
                          connectedDeviceAddress = null;
                          connection = null;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: Text('Disconnect'),
                    ),
                  ),
                ),
              ),

            // Device discovery section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Available Devices:',
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _discoverDevices,
                    child: Text('Search'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4CFF50),
                    ),
                  ),
                ],
              ),
            ),

            // Device list
            Expanded(
              child: isDiscovering
                  ? Center(child: CircularProgressIndicator())
                  : devices.isEmpty
                  ? Center(
                child: Text(
                  'No devices found',
                  style: TextStyle(fontSize: 16),
                ),
              )
                  : ListView.builder(
                itemCount: devices.length,
                itemBuilder: (context, index) {
                  final device = devices[index].device;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.bluetooth,
                        color: Colors.blue,
                      ),
                      title: Text(
                        device.name ?? 'Unknown Device',
                        style: TextStyle(fontSize: 16),
                      ),
                      subtitle: Text(device.address),
                      trailing: IconButton(
                        icon: Icon(
                          connectedDeviceAddress ==
                              device.address
                              ? Icons.bluetooth_connected
                              : Icons.bluetooth,
                          color: connectedDeviceAddress ==
                              device.address
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          _connectToDevice(device);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
