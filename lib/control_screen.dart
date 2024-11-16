import 'package:flutter/material.dart';

class ControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Control Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                print('Move Forward');
              },
              child: Text('Forward'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    print('Move Left');
                  },
                  child: Text('Left'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    print('Move Right');
                  },
                  child: Text('Right'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                print('Move Backward');
              },
              child: Text('Backward'),
            ),
            ElevatedButton(
              onPressed: () {
                print('Toggle Light');
              },
              child: Text('Light On/Off'),
            ),
          ],
        ),
      ),
    );
  }
}
