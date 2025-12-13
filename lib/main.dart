import 'package:flutter/material.dart';
import './src/app.dart';

void main() {
  onStartUp();
}

void onStartUp() async {
  // The platform's loading screen will be used while awaiting if you omit this.

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      color: const Color(0xFFFFFFFF),
      home: const Scaffold(
        body: Center(
          child: Stack(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text(
                  "OBS Switch",
                  style: TextStyle(
                    fontFamily: "Orbitron",
                    fontSize: 48,
                    color: Color(0xFF49665F),
                  ),
                ),
              ),
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(),
                ),
              ),
            ],
          ),
        ),
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const Center(
            child: Text('Wow!'),
          ),
        );
      },
    ),
  );

  runApp(
    const OBSSwitchApp(),
  );
}
