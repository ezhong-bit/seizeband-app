// import '../screens/emergency_screen.dart';
import 'package:flutter/material.dart';

class EditContactScreen extends StatefulWidget {
  final String initialName;
  final String initialChatId;
  final Function(String updatedName, String updatedChatId) onSave;

  const EditContactScreen({
    Key? key,
    required this.initialName,
    required this.initialChatId,
    required this.onSave,
  }) : super(key: key);

  @override
  State<EditContactScreen> createState() => _EditContactSheetState();
}

class _EditContactSheetState extends State<EditContactScreen> {
  late TextEditingController _nameController;
  late TextEditingController _chatIdController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _chatIdController = TextEditingController(text: widget.initialChatId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _chatIdController.dispose();
    super.dispose();
  }

  void _handleSave() {
    widget.onSave(_nameController.text.trim(), _chatIdController.text.trim());
    Navigator.of(context).pop();
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
      mainAxisSize: MainAxisSize.min,
        children: [
          Text('Edit Contact', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Contact Name'),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _chatIdController,
            decoration: const InputDecoration(labelText: 'Telegram Chat ID'),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _handleSave,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
