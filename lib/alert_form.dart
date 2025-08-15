import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';


class AlertForm extends StatefulWidget {
  final String userName; // Accept username here

  const AlertForm({super.key, required this.userName});

  @override
  State<AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends State<AlertForm> {
  final _contactChatIdController = TextEditingController();
  final _contactNameController = TextEditingController();
  String? _statusMessage;

  final String backendBaseUrl = 'https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev';

  Future<void> _registerContact() async {
    final contactChatId = _contactChatIdController.text.trim();
    final userName = widget.userName; // Use passed username

    if (contactChatId.isEmpty || _contactNameController.text.trim().isEmpty) {
      setState(() => _statusMessage = 'Please enter your contact\'s name and chat ID.');
      return;
    } else if (userName.isEmpty){
      setState(() => _statusMessage = 'User is not logged in / user\'s name not found.\n Check your username in "Help & Settings"');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/register-contact'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': userName,
          'chat_id': contactChatId,
          'contact_name': _contactNameController.text.trim(),
        }),
      );

      if (response.statusCode == 200) {
        setState(() => _statusMessage = 'Contact registered successfully!');

      } else {
        setState(() => _statusMessage = 'Failed to register contact: ${response.body}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error registering contact: $e');
    }
  }

  Future<void> _sendTestAlert() async {
    final userName = widget.userName;
  if (userName.isEmpty) {
    setState(() {
      _statusMessage = 'No user logged in to send alert.';
    });
    return;
  }



  try {
    final position = await _determinePosition();
    final latitude = position.latitude;
    final longitude = position.longitude;

    final locationResponse = await http.post(
      Uri.parse('$backendBaseUrl/set-location'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    if (locationResponse.statusCode != 200) {
      setState(() => _statusMessage = 'Failed to set location: ${locationResponse.body}');
      return;
    }

    final response = await http.post(
      Uri.parse('$backendBaseUrl/alert-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
      }),
    );

      if (response.statusCode == 200) {
        setState(() => _statusMessage = 'Alert sent successfully!');
      } else {
        setState(() => _statusMessage = 'Failed to send alert: ${response.body}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error sending alert: $e');
    }
  }



  @override
  void dispose() {
    _contactChatIdController.dispose();
    super.dispose();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(      
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 5,
        ),
        child: Column(
          children: [
           Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed:() => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  Text('New Contact',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 20),
                ),
                  TextButton(
                    onPressed: () async{
                    await _registerContact();
                      if (_statusMessage == 'Contact registered successfully!') {
                        await Future.delayed(const Duration(seconds: 1, milliseconds: 200));
                        if (mounted) {
                          Navigator.of(context).pop();  // Close the modal/sheet
                        }
                      }
                    } ,
                    child: const Text('Done'),
                  ),
                ]
              ),

              const SizedBox(height:10),
              TextField(
                controller: _contactNameController,
                decoration: const InputDecoration(
                  labelText: 'Contact Name',
                ),
                keyboardType: TextInputType.text,
              ),

            TextField(
              controller: _contactChatIdController,
              decoration: const InputDecoration(
                labelText: 'Contact Telegram Chat ID',
                helperText: 'Have your contact message the Telegram bot first',
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: _sendTestAlert,
              child: const Text('Send Test Seizure Alert'),
            ),

              const SizedBox(height: 30),
//            const SizedBox(height: 350),
            if (_statusMessage != null)
              Text(
                _statusMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

//            const SizedBox(height:35),
          ],
        )
    );
  }
}