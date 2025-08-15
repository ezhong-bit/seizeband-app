import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> sendSeizureAlert(String chatId, String userName) async {
  final String backendUrl = 'https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/alert';

  try {
    final response = await http.post(
      Uri.parse(backendUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'chat_id': chatId,
        'user_name': userName,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Alert sent successfully!');
    } else {
      print('❌ Failed to send alert: ${response.body}');
    }
  } catch (e) {
    print('❌ Error sending alert: $e');
  }
}
