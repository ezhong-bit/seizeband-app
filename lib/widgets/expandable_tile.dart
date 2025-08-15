class ExpandableAccountTile extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController chatIdController;
  final VoidCallback onSave;

  const ExpandableAccountTile({
    super.key,
    required this.usernameController,
    required this.chatIdController,
    required this.onSave,
  });

  @override
  State<ExpandableAccountTile> createState() => _ExpandableAccountTileState();
}

class _ExpandableAccountTileState extends State<ExpandableAccountTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          ListTile(
            title: const Text('Account'),
            trailing: Icon(_isExpanded ? Icons.expand_more : Icons.chevron_right),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: widget.usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: widget.chatIdController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Telegram Chat ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: widget.onSave,
                    child: const Text('Save Name & Chat ID'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
