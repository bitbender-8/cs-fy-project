import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CampaignsScreen(),
    );
  }
}

class CampaignsScreen extends StatelessWidget {
  final List<Map<String, String>> campaigns = [
    {'title': 'Campaign 1', 'recipient': 'Abebe Kebede', 'goal': '1000 ETB'},
    {'title': 'Campaign 2', 'recipient': 'Seble Seyoum', 'goal': '1500 ETB'},
    {'title': 'Campaign 3', 'recipient': 'Jemal Kedir', 'goal': '2000 ETB'},
  ];

  CampaignsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaigns'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by',
                suffixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: campaigns.length,
              itemBuilder: (context, index) {
                return CampaignCard(
                  title: campaigns[index]['title']!,
                  recipient: campaigns[index]['recipient']!,
                  goal: campaigns[index]['goal']!,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            label: 'Public campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My campaigns',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Profile and Settings',
          ),
        ],
      ),
    );
  }
}

class CampaignCard extends StatelessWidget {
  final String title;
  final String recipient;
  final String goal;

  const CampaignCard({
    super.key,
    required this.title,
    required this.recipient,
    required this.goal,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Recipient: $recipient'),
            Text('Goal: $goal'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.54,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            const Text('54%'),
          ],
        ),
      ),
    );
  }
}
