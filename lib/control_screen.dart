import 'dart:math' as math;
import 'dart:math';
import 'package:akhtar/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class ControlScreen extends StatefulWidget {
  final BluetoothConnection connection;

  const ControlScreen({Key? key, required this.connection}) : super(key: key);

  @override
  _ControlScreenState createState() => _ControlScreenState();
}

class _ControlScreenState extends State<ControlScreen> {
  bool isUsingButtons = true;
  bool isLightOn = false; // Track the state of the light

  Offset _circlePosition = Offset.zero; // Position of draggable center circle
  double fanRangeK = 90; // Default fan range for 'K'
  double fanRangeJ = 90; // Default fan range for 'J'

  void _sendCommand(String command) {
    if (widget.connection.isConnected) {
      widget.connection.output.add(Uint8List.fromList(command.codeUnits));
      widget.connection.output.allSent;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bluetooth is not connected!')),
      );
    }
  }

  void _handleJoystick(double x, double y) {
    // Calculate angle and magnitude
    double angle = atan2(y, x); // Angle in radians
    double magnitude =
        math.sqrt(x * x + y * y); // Magnitude of joystick movement

    // Ignore small joystick movements (dead zone)
    if (magnitude < 0.2) {
      _sendCommand("S"); // Stop
      return;
    }

    // Determine command based on angle
    if (angle >= -math.pi / 8 && angle < math.pi / 8) {
      _sendCommand("R"); // Right
    } else if (angle >= math.pi / 8 && angle < 3 * math.pi / 8) {
      _sendCommand("C"); // Backward Right
    } else if (angle >= 3 * math.pi / 8 && angle < 5 * math.pi / 8) {
      _sendCommand("B"); // Backward
    } else if (angle >= 5 * math.pi / 8 && angle < 7 * math.pi / 8) {
      _sendCommand("Z"); // Backward Left
    } else if (angle >= 7 * math.pi / 8 || angle < -7 * math.pi / 8) {
      _sendCommand("L"); // Left
    } else if (angle >= -7 * math.pi / 8 && angle < -5 * math.pi / 8) {
      _sendCommand("Q"); // Forward Left
    } else if (angle >= -5 * math.pi / 8 && angle < -3 * math.pi / 8) {
      _sendCommand("F"); // Forward
    } else if (angle >= -3 * math.pi / 8 && angle < -math.pi / 8) {
      _sendCommand("E"); // Forward Right
    }
  }

  void _toggleLight() {
    setState(() {
      isLightOn = !isLightOn; // Toggle the light state
    });

    // Send the appropriate command based on the light state
    if (isLightOn) {
      _sendCommand("M"); // Turn on light
    } else {
      _sendCommand("m"); // Turn off light
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control Screen'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C9F50), Color(0xFF81C784)], // Green gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Use Gesture Control'),
                value: !isUsingButtons,
                onChanged: (value) {
                  setState(() {
                    isUsingButtons = !value;
                  });
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isUsingButtons
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GridView.count(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15,
                          crossAxisSpacing: 15,
                          childAspectRatio: 1.2,
                          children: [
                            CustomButton(
                              icon: Icons.turn_slight_left_sharp,
                              color: Colors.blue,
                              onPressed: () => _sendCommand("Q"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.arrow_upward,
                              color: Colors.grey,
                              onPressed: () => _sendCommand("F"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.turn_slight_right_sharp,
                              color: Colors.blue,
                              onPressed: () => _sendCommand("E"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.arrow_left,
                              color: Colors.orange,
                              onPressed: () => _sendCommand("L"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.stop_circle,
                              color: Colors.red,
                              onPressed: () => _sendCommand("S"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.arrow_right,
                              color: Colors.orange,
                              onPressed: () => _sendCommand("R"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.subdirectory_arrow_left,
                              color: Colors.purple,
                              onPressed: () => _sendCommand("Z"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.arrow_downward,
                              color: Colors.grey,
                              onPressed: () => _sendCommand("B"),
                              onReleased: () => _sendCommand("S"),
                            ),
                            CustomButton(
                              icon: Icons.subdirectory_arrow_right,
                              color: Colors.purple,
                              onPressed: () => _sendCommand("C"),
                              onReleased: () => _sendCommand("S"),
                            ),
                          ],
                        ),
                      )
                    : Joystick(
                        listener: (details) {
                          _handleJoystick(details.x, details.y);
                        },
                        mode: JoystickMode.all, // 360-degree control
                      ),
              ),
              Center(
                child: GestureDetector(
                  onTap: _toggleLight,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: isLightOn
                          ? Colors.yellow
                          : Colors.grey, // Yellow for ON, Grey for OFF
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isLightOn
                              ? Colors.yellow.withOpacity(0.6)
                              : Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      isLightOn
                          ? Icons.lightbulb
                          : Icons
                              .lightbulb_outline, // Icon changes based on state
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "${fanRangeK.toStringAsFixed(0)}", // Display the current value of K
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:  [
                        Text("0"), // Min value
                        Slider(
                          value: fanRangeK,
                          min: 0,
                          max: 180,
                          divisions: 180, // Optional: To make the slider discrete
                          label: fanRangeK.toStringAsFixed(0), // Optional: Displays value as a tooltip
                          onChanged: (value) {
                            setState(() {
                              fanRangeK = value;
                            });
                            _sendCommand("K${value.toInt()}");
                          },
                        ),
                        Text("180"), // Max value
                      ],
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 5), // Space between the sliders
              // Slider for Fan Range J
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      "${fanRangeJ.toStringAsFixed(0)}", // Display the current value of J
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [


                        Text("0"), // Min value
                        Slider(
                          value: fanRangeJ,
                          min: 0,
                          max: 180,
                          divisions: 180, // Optional: To make the slider discrete
                          label: fanRangeJ.toStringAsFixed(0), // Optional: Displays value as a tooltip
                          onChanged: (value) {
                            setState(() {
                              fanRangeJ = value;
                            });
                            _sendCommand("J${value.toInt()}");
                          },
                        ),
                        Text("180"), // Max value
                      ],
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
