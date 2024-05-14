import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
class SettingsPage extends StatefulWidget {
  final Function(double) updateComfortLevel;
  final Function(double) saveComfortLevel;
  final Function(String) updateGender;
  final Function(String) saveGender;
  final String initialGender;

  const SettingsPage({
    Key? key,
    required this.updateComfortLevel,
    required this.saveComfortLevel,
    required this.updateGender,
    required this.saveGender,
    required this.initialGender,
  }) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}


class _SettingsPageState extends State<SettingsPage> {
  String _selectedGender = '';
  double _comfortLevel = 2;

  void _fetchComfortLevel() async {
    final prefs = await SharedPreferences.getInstance();
    final comfortLevel = prefs.getDouble('comfortLevel') ?? 2;
    setState(() {
      _comfortLevel = comfortLevel;
    });
  }

  void _fetchGender() async {
    final prefs = await SharedPreferences.getInstance();
    final gender = prefs.getString('gender') ?? '';
    setState(() {
      _selectedGender = gender;
    });
  }

  void _updateGender(String? gender) {
    setState(() {
      _selectedGender = gender ?? '';
    });
    widget.updateGender(gender ?? '');
  }

  @override
  void initState() {
    super.initState();
    _fetchComfortLevel();
    _fetchGender();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Character',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Radio(
                  value: 'Male',
                  groupValue: _selectedGender,
                  onChanged: _updateGender,
                ),
                Text('Male'),
                SizedBox(width: 20),
                Radio(
                  value: 'Female',
                  groupValue: _selectedGender,
                  onChanged: _updateGender,
                ),
                Text('Female'),
              ],
            ),

            SizedBox(height: 1),
            Text(
              'COMFORT LEVEL',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: _comfortLevel.clamp(1,3),
              onChanged: (value) {
                setState(() {
                  _comfortLevel = value;
                });
                widget.updateComfortLevel(value);
                widget.saveComfortLevel(value);
              },
              min: 1,
              max: 3,
              divisions: 2,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stay Warmer',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Stay Cooler',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 10),
            _selectedGender == 'Male'
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('T-Shirts'),
                Text('Shirts'),
                Text('Sweaters'),
                SizedBox(height: 10),
                Text(
                  'Bottom',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Pants'),
                Text('Shorts'),
                SizedBox(height: 10),
                Text(
                  'Outerwear',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Light Jackets'),
                Text('Winter Jackets'),
                SizedBox(height: 10),
                Text(
                  'Accessories',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Scarves'),
                Text('Winter Hats'),
                Text('Gloves & Mittens'),
                Text('Umbrellas'),
                Text('Thermal Underwear'),
                SizedBox(height: 10),
                Text(
                  'Footwear',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Shoes'),
                Text('Sandals'),
                Text('Winter Boots'),
              ],
            )
                : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  'Top',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Dresses'),
                Text('T-Shirts'),
                Text('Shirts'),
                Text('Sweaters'),
                SizedBox(height: 10),
                Text(
                  'Bottom',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Pants'),
                Text('Shorts & Skirts'),
                SizedBox(height: 10),
                Text(
                  'Outerwear',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Light Jackets'),
                Text('Winter Jackets'),
                SizedBox(height: 10),
                Text(
                  'Accessories',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Scarves'),
                Text('Winter Hats'),
                Text('Gloves & Mittens'),
                Text('Umbrellas'),
                Text('Thermal Underwear'),
                SizedBox(height: 10),
                Text(
                  'Footwear',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text('Shoes'),
                Text('Sandals'),
                Text('Winter Boots'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
