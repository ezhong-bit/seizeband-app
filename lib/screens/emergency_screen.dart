import 'package:flutter/material.dart';
// import 'package:seize_appios/screens/start_screen.dart';
import 'package:seize_appios/alert_form.dart';
import 'package:seize_appios/widgets/simple_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:seize_appios/screens/edit_contact_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';


class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  
  // If I ever wanted to change the color on tap: bool isRemoveSelected = false;
  List<Map<String, dynamic>> _contacts = [];
  bool _isRemoveMode = false;
  String? _statusMessage;
  String? username;

  final String backendBaseUrl =
      'https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _toggleRemoveMode() {
    setState(() {
      _isRemoveMode = !_isRemoveMode;
    });
  }

  Future<void> _removeContact(String chatId) async {
    if (username == null || username!.isEmpty) return;

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/remove-contact'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'user_name': username, 'chat_id': chatId}),
      );

      if (response.statusCode == 200) {
        setState(() {
          _contacts.removeWhere((c) => c['chat_id'] == chatId);
          _statusMessage = 'Contact removed successfully.';
        });
      } else {
        setState(() {
          _statusMessage = 'Failed to remove contact: ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error removing contact: $e';
      });
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, String contactName) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Delete'),
      content: Text('Are you sure you want to delete this contact ($contactName)?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true), // User confirms
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ) ?? false; // Return false if dialog dismissed without choice
}

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final storedName = prefs.getString('user_name');
    setState(() {
      username = storedName;
    });

    if (storedName != null && storedName.isNotEmpty) {
      _fetchContacts();
    }
  }

  Future<void> _fetchContacts() async {
    if (username == null || username!.isEmpty) return;

    try {
      final response =
          await http.get(Uri.parse('$backendBaseUrl/get-contacts/$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<Map<String, dynamic>> contacts = List<Map<String, dynamic>>.from(data['contacts']);

         setState(() {
          _contacts = contacts;
          _statusMessage = contacts.isEmpty
              ? 'No contacts found.'
              : 'Contacts loaded successfully.';
        });
      } else {
        setState(() {
          _contacts = [];
          _statusMessage = 'No contacts found.';
        });
      }
    } catch (e) {
      setState(() {
        _contacts = [];
        _statusMessage = 'Error fetching contacts: $e';
      });
    }
  }

  void _editContact(Map<String, dynamic> contact) async {
    final oldChatId = contact['chat_id'] ?? '';
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.8, 
        minChildSize: 0.6,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: EditContactScreen(
                                initialName: contact['contact_name'] ?? '',
              initialChatId: contact['chat_id'] ?? '',
              onSave: (updatedContactName, updatedChatId) async {
                setState(() {
                    contact['contact_name'] = updatedContactName;
                    contact['chat_id'] = updatedChatId;
                });
                await _saveContact(
                oldChatId: oldChatId,
                newChatId: updatedChatId,
                newContactName: updatedContactName,
                );
              },
            ),
          );
        },
      );
    },
  );
}

  Future<bool> _saveContact({
    required String oldChatId,
    required String newChatId,
    required String newContactName,
  }) async {
    if (username == null || username!.isEmpty) return false;

    try {
      final response = await http.post(
        Uri.parse('$backendBaseUrl/update-contact'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'user_name': username,
          'old_chat_id': oldChatId,
          'new_chat_id': newChatId,
          'new_contact_name': newContactName,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error saving contact: $e');
      return false;
    }
  }

Future<void> _sendTestAlert() async {
    final userName = username;
  if (userName == null || userName.isEmpty) {
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
      Uri.parse('$backendBaseUrl/test-alert-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': userName,
      }),
    );

      if (response.statusCode == 200) {
        setState(() => _statusMessage = 'Test alert sent successfully!');
      } else {
        setState(() => _statusMessage = 'Failed to send test alert: ${response.body}');
      }
    } catch (e) {
      setState(() => _statusMessage = 'Error sending test alert: $e');
    }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column( children: [
            const SizedBox(height: 16),
              Center(
                child: Row(
//                  mainAxisSize: MainAxisSize.min, // prevents full-width stretching
                  children: [
                  Expanded(
                  child: SimpleRoundedButton(
                      height:180,
                      icon: Icons.group_add,
                      label: '  Add',
                      iconSize: 40,
                      fontSize: 16,
                      onTap: () async {                        
                        await showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (context) {
                            return DraggableScrollableSheet(
                              initialChildSize: 0.8,  
                              minChildSize: 0.6,
                              maxChildSize: 0.9,
                              expand: false,
                              builder: (context, scrollController) {
                                return SingleChildScrollView(
                                  controller: scrollController,
                                  padding: EdgeInsets.only(
                                    top: 16,
                                    left: 16,
                                    right: 16,
                                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                                  ),
                                  child: AlertForm(userName: username ?? ''),
                                );
                              },
                            );
                          },
                        );
                        // Refresh contacts after adding a new one
                        _fetchContacts();
                      },
                    ),
                  ),
                  const SizedBox(width:20),
                  Expanded(
                    child: SimpleRoundedButton(
                      height: 180,
                      icon: Icons.group_remove,
                      iconSize: 40,
                      fontSize: 16,
                      onTap: _toggleRemoveMode,
                      label: '  Remove',
                      shadowColor: _isRemoveMode ? Colors.purple[200] : Colors.black12,
                      shadowOffset: _isRemoveMode ? Offset(1,2) : Offset(2,2),
                    ),
                  ),
                ]
              ),
            ),
            const SizedBox(height: 24),
            if (_contacts.isNotEmpty) ...[
              const Text(
                'Registered Emergency Contacts:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _contacts.length,
                  itemBuilder: (context, index) {
                    final contact = _contacts[index];
                    return Card(
                      color: Colors.white,
                      child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        leading: Icon ((Icons.contact_emergency),
                        color: Colors.deepOrange[300],
                        size: 35,
                        ),
                      title: Text(contact['contact_name'] ?? 'No Name'),
                      subtitle: Text('Chat ID: ${contact['chat_id']}'),
                      trailing: _isRemoveMode
                    ? Padding(
                        padding: const EdgeInsets.only(right: 0.0),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          icon: Icon(Icons.delete, color: Colors.red[800]),
                            iconSize: 30,
                            onPressed: () async {
                            bool confirmed = await _showDeleteConfirmation(context, contact['contact_name'] ?? 'this contact');
                              if (confirmed){
                                await _removeContact(contact['chat_id']);
                              }
                            },
                          ),
                        )
                        : null,
                        onTap: (){
                          _editContact(contact);
                        }
                      ),
                    );
                  },
                ),
              ),
            ] else if (_statusMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _statusMessage!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(left: 30.0, right: 30.0, bottom: 20.0, top: 20.0),
        child: SizedBox(
          height: 150,
            child: Center(
              child: Column(
                children: [
                  SimpleRoundedButton(
                  height: 63,
                  width: 200,
                  icon: Icons.warning_amber_rounded,
                  label: 'Send Test Alert',
                  iconSize: 22,
                  fontSize: 15,
                  onTap: _sendTestAlert,
                  shadowColor: Colors.deepPurple[100],
                ),
                const SizedBox(height:20),
                const Text('Tap to test the alert sending function. Real auto-alerts are sent if seizure is detected.',
                  textAlign: TextAlign.center,
                ),
              ]
            )
          )
        )
      )
    );
  }
}