import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'dart:typed_data';
import 'dart:convert';

class BluetoothScreen extends StatefulWidget {
  final String address;

  BluetoothScreen({required this.address});

  @override
  _BluetoothScreenState createState() => _BluetoothScreenState();
}

class _BluetoothScreenState extends State<BluetoothScreen> {
  late BluetoothConnection connection;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToBluetoothDevice();
  }

  Future<void> _connectToBluetoothDevice() async {
    try {
      print('Connecting to the device...');
      connection = await BluetoothConnection.toAddress(widget.address);
      print('Connected to the device');
      setState(() {
        isConnected = true;
      });

      connection.input!.listen((Uint8List data) {
        print('Data incoming: ${ascii.decode(data)}');
        connection.output.add(data);

        if (ascii.decode(data).contains('!')) {
          connection.finish();
          print('Disconnecting by local host');
        }
      }).onDone(() {
        print('Disconnected by remote request');
        setState(() {
          isConnected = false;
        });
      });
    } catch (exception) {
      print('Cannot connect, an exception occurred: $exception');
    }
  }

  @override
  void dispose() {
    if (isConnected) {
      connection.finish();
      print('Connection closed by dispose');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bluetooth Screen'),
      ),
      body: Center(
        child: isConnected
            ? Text('Connected to ${widget.address}', style: TextStyle(fontSize: 20))
            : Text('Connecting...', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
