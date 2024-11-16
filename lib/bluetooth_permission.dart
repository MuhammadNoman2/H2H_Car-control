import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothPermissionScreen extends StatefulWidget {
  @override
  _BluetoothPermissionScreenState createState() =>
      _BluetoothPermissionScreenState();
}

class _BluetoothPermissionScreenState extends State<BluetoothPermissionScreen> {
  bool isBluetoothEnabled = false;
  bool isLoading = true;
  List<BluetoothDiscoveryResult> devices = [];
  BluetoothConnection? connection;
  String? connectedDeviceAddress;
  bool isDiscovering = false;

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

  // Toggle Bluetooth ON/OFF
  void _toggleBluetooth() async {
    if (isBluetoothEnabled) {
      await FlutterBluetoothSerial.instance.requestDisable();
    } else {
      await FlutterBluetoothSerial.instance.requestEnable();
    }
    _checkBluetoothState();
  }

  // Start discovering devices
  void _discoverDevices() async {
    if (isDiscovering) return; // Prevent starting discovery multiple times
    setState(() {
      isDiscovering = true;
      devices.clear(); // Clear current device list before starting discovery
    });

    FlutterBluetoothSerial.instance.startDiscovery().listen((BluetoothDiscoveryResult result) {
      setState(() {
        devices.add(result);
      });
    }).onDone(() {
      setState(() {
        isDiscovering = false;
      });
      print('Discovery completed');
    });
  }

  // Connect to the selected Bluetooth device
  Future<void> _connectToDevice(BluetoothDevice device) async {
    try {
      // Check if the device is paired (manually through system settings)
      bool isDevicePaired = await _isDevicePaired(device);

      if (!isDevicePaired) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please pair the device manually in Bluetooth settings')),
        );
        return;
      }

      print('Connecting to ${device.address}...');
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);
      setState(() {
        connectedDeviceAddress = device.address;
        this.connection = connection;
      });
      print('Connected to ${device.name ?? device.address}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connected to ${device.name ?? device.address}')),
      );

      // Optionally listen for data
      connection.input!.listen((data) {
        print('Data incoming: ${String.fromCharCodes(data)}');
      }).onDone(() {
        print('Disconnected by remote request');
        setState(() {
          connectedDeviceAddress = null;
        });
      });
    } catch (e) {
      print('Connection failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to connect to ${device.name ?? device.address}. Make sure the device is paired and available.')),
      );
    }
  }

  // Function to check if the device is paired
  Future<bool> _isDevicePaired(BluetoothDevice device) async {
    List<BluetoothDevice> pairedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
    return pairedDevices.any((pairedDevice) => pairedDevice.address == device.address);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Permissions'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _discoverDevices,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ListTile(
            title: Text('Bluetooth Status: ${isBluetoothEnabled ? "ON" : "OFF"}'),
            trailing: Switch(
              value: isBluetoothEnabled,
              onChanged: (value) {
                _toggleBluetooth();
              },
            ),
          ),
          Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Available Devices:',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            onPressed: _discoverDevices,
            child: Text('Pair New Devices'),
          ),
          SizedBox(height: 10),
          isDiscovering
              ? Center(child: CircularProgressIndicator())
              : Expanded(
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                final device = devices[index].device;
                return ListTile(
                  title: Text(device.name ?? 'Unknown Device'),
                  subtitle: Text(device.address),
                  trailing: connectedDeviceAddress == device.address
                      ? Icon(Icons.bluetooth_connected, color: Colors.green)
                      : IconButton(
                    icon: Icon(Icons.bluetooth),
                    onPressed: () {
                      _connectToDevice(device);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    connection?.dispose();
    super.dispose();
  }
}
