import 'package:flutter/material.dart';

class SettingsExpansePage extends StatefulWidget {
  @override
  _SettingsExpansePageState createState() => _SettingsExpansePageState();
}

class _SettingsExpansePageState extends State<SettingsExpansePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Text('Settings'),
        ),
      ),
    );
  }
}
