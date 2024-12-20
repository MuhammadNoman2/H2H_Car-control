import 'package:flutter/material.dart';

class ControlSystemDialog extends StatelessWidget {
  const ControlSystemDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      backgroundColor: Colors.white,
      contentPadding: const EdgeInsets.all(20),
      title: const Text(
        "Control System Info",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min, // Keeps the dialog compact
        children: [
          // Icon Row 1: Forward and Backward
          _buildControlRow(
            context,
            icon1: Icons.arrow_upward,
            label1: "Forward",
            icon2: Icons.arrow_downward,
            label2: "Backward",
          ),
          const SizedBox(height: 20),
          // Icon Row 2: Left and Right
          _buildControlRow(
            context,
            icon1: Icons.arrow_back,
            label1: "Left",
            icon2: Icons.arrow_forward,
            label2: "Right",
          ),
          const SizedBox(height: 20),
          // Icon Row 3: Light and Stop
          _buildControlRow(
            context,
            icon1: Icons.lightbulb,
            label1: "Toggle Light",
            icon2: Icons.stop,
            label2: "Stop",
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: const Text(
            "Close",
            style: TextStyle(fontSize: 18, color: Colors.blue),
          ),
        ),
      ],
    );
  }

  // Helper function to create a row of controls
  Widget _buildControlRow(
      BuildContext context, {
        required IconData icon1,
        required String label1,
        required IconData icon2,
        required String label2,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlIcon(context, icon: icon1, label: label1),
        _buildControlIcon(context, icon: icon2, label: label2),
      ],
    );
  }

  // Helper function to create an icon with a label
  Widget _buildControlIcon(BuildContext context, {required IconData icon, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: Colors.blueAccent),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
