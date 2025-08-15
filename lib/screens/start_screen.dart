import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
// import 'package:seize_appios/alert_form.dart';

class GettingStartedScreen extends StatefulWidget {
  final VoidCallback onContinue;
  const GettingStartedScreen({super.key, required this.onContinue});

  @override
  State<GettingStartedScreen> createState() => _GettingStartedScreenState();
}

class _GettingStartedScreenState extends State<GettingStartedScreen> {
    final PageController _pageController = PageController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _chatIdController = TextEditingController();

      int _currentPage = 0;

  void _goToNextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> onContinue() async {
    final username = _nameController.text.trim();
    final chatId = _chatIdController.text.trim();


    if (username.isEmpty || chatId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and YOUR Telegram Chat ID')),
      );
      return;
    }
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_name', username);
  await prefs.setString('telegram_chat_id', chatId);

  try {
    final response = await http.post(
      Uri.parse('https://1039321b-b048-480a-9cf5-1348f5413d71-00-2sebn6d1aozvp.picard.replit.dev/register-user'), // 👈 Replace this
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_name': username,
        'chat_id': chatId,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Registered user with backend');
      widget.onContinue();
    } else {
      print('❌ Failed to register user: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Backend error: ${response.body}')),
      );
    }
  } catch (e) {
    print('❌ Error connecting to backend: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Network error')),
    );
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

 @override
  Widget build(BuildContext context) {

final List<Widget> pages = [

// Page 1: Seize Band Introduction
Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height:80),
        Text(
          'Welcome to the Seize Band App!',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 20),

        Text(
          'Seize Band is a headband like device that can detect seizures through motion and heartrate sensors and then alert your emergency contacts.' 
          ' Seize Band also tracks and displays the data from seizures detected while wearing it.',
        style: Theme.of(context).textTheme.bodyLarge,
        ),
      ]
    )
  ),

//Page 2: Connecting Your Contacts to the Alert System
Padding(
  padding: const EdgeInsets.all(16.0),
  child: SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height:60),
        Text('How Alerts Work and Connecting Your Contacts:',
        style: Theme.of(context).textTheme.titleLarge,),
        const SizedBox(height:20),
        Text(
          'Seize Band is using the Telegram app to message your contacts in the event of a seizure. You also need to download Telegram so we can contact you if needed.\n',
        style: Theme.of(context).textTheme.bodyLarge,
        ),
        Text(
          'To make sure your emergency contacts get notified after a seizure detection and that you receive messages from our app, please follow these steps:',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Text('1. Download the Telegram app from the App Store or Google Play.', style: Theme.of(context).textTheme.bodyLarge,),
        const SizedBox(height: 6),
        Text('2. Search for our bot: @SeizureBandAlertBot', style: Theme.of(context).textTheme.bodyLarge,),
        const SizedBox(height: 6),
        Text(
            '3. Open a chat with the bot and click the "Start" button at the bottom of the page or send a simple message like "Hi" to start receiving alerts.'
            'The chat bot will give you and your contacts their Telegram Chat ID. Have your contacts send this ID to you. On the next page, there will be an input field for you to provide your Telegram Chat ID.', 
            style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 12),
        Text(
          'Make sure your contacts do this so they can get seizure alerts when needed.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)
            ),

          Text('\n* To register your contacts on the Seize Band app, head to the emergency contacts page on the homescreen, select "add contact" and input their Telegram Chat ID. *',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
          ),
          
      const SizedBox(height: 24),
    ]
  )
)
),

//Connecting the Seize Band to the app and data collection
//Data is length and time stamp
//Please keep app running in the background
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children:[
      const SizedBox(height: 80.0),
      Text("A few more notes before we get started!",
        style: 
          Theme.of(context).textTheme.titleLarge,
      ),
      const SizedBox(height: 30),
      TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'Enter Your Name',
          border: OutlineInputBorder(),
        ),
      ),
      const SizedBox(height: 20),
      TextField(
        controller: _chatIdController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Enter Your Telegram Chat ID',
          border: OutlineInputBorder(),
        ),
      ),
    ]
  )
)    

];

return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: pages,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(width: 60),

Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: List.generate(3, (index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 12 : 8,
      height: _currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.deepPurple[200] : Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }),
),

if (_currentPage == pages.length - 1)
  Center(
    child: TextButton(
      onPressed: onContinue,
      child: const Text('Continue'),
    ),
  )
else
  TextButton(
    onPressed: _goToNextPage,
    child: const Text('Next'),
  ),
              ],
            ),
          ),
        ]
      )
    );
  }
}
