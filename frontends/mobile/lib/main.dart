import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const CampaignsScreen(),
    );
  }
}

/// **Main Campaigns Screen with Bottom Navigation**
class CampaignsScreen extends StatefulWidget {
  const CampaignsScreen({super.key});

 
  @override
  _CampaignsScreenState createState() => _CampaignsScreenState();
}

class _CampaignsScreenState extends State<CampaignsScreen> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const PublicCampaignsPage(),
    const MyCampaignsPage(),
    const CampaignRequestPage(), 
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[850], 
        selectedItemColor: Colors.blue, 
        unselectedItemColor: Colors.white, 
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.public), label: 'Public Campaigns'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'My Campaigns'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Request Campaign'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

/// **Campaign Request Page with Form**
class CampaignRequestPage extends StatefulWidget {
  const CampaignRequestPage({super.key});

  @override
  _CampaignRequestPageState createState() => _CampaignRequestPageState();
}

class _CampaignRequestPageState extends State<CampaignRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _recipientController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _launchDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request a Campaign')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField('Request Type', _categoryController),
              _buildTextField('Title', _titleController),
              _buildTextField('Recipient', _recipientController),
              _buildTextField('Category', _categoryController),
              _buildTextField('Goal Amount (ETB)', _goalController),
              _buildTextField('Launch Date', _launchDateController),
              _buildTextField('End Date', _endDateController),
              _buildTextField('Description', _descriptionController),
              _buildTextField('Justification', _justificationController),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle submission logic here.
                        }
                      },
                      child: const Text('Create Request')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
      ),
    );
  }
}

/// **My Campaigns Page**
class MyCampaignsPage extends StatelessWidget {
  const MyCampaignsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Campaigns')),
      body: const Center(
          child: Text('Your personal campaigns will be displayed here.')),
    );
  }
}

/// **Settings Page**
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: const Center(
          child: Text('User preferences and settings will be here.')),
    );
  }
}

/// **Public Campaigns Page**
class PublicCampaignsPage extends StatelessWidget {
  const PublicCampaignsPage({super.key});

  final List<Map<String, String>> campaigns = const [
    {
      'title': 'Medical Aid for Abebe',
      'recipient': 'Abebe Kebede',
      'goal': '2400 ETB',
      'raised': '1345 ETB',
      'category': 'Medical',
      'status': 'Live',
      'launchDate': '11/04/23',
      'endDate': '12/03/25',
      'description': 'Providing urgent medical assistance to Abebe.',
      'updates': '50% funds collected!'
    },
    {
      'title': 'Medical Fund for Seble',
      'recipient': 'Seble Seyoum',
      'goal': '1500 ETB',
      'raised': '750 ETB',
      'category': 'Medical',
      'status': 'Live',
      'launchDate': '10/03/24',
      'endDate': '15/09/25',
      'description': 'Helping Seble seek higher medical assistance',
      'updates': 'Raised halfway!'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Public Campaigns')),
      body: ListView.builder(
        itemCount: campaigns.length,
        itemBuilder: (context, index) {
          return CampaignCard(campaign: campaigns[index]);
        },
      ),
    );
  }
}

/// **Campaign Card Navigation**
class CampaignCard extends StatelessWidget {
  final Map<String, String> campaign;

  const CampaignCard({super.key, required this.campaign});

  double _parseValue(String value) {
    // Remove any non-digit or non-decimal characters (e.g., " ETB")
    return double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    double raised = _parseValue(campaign['raised']!);
    double goal = _parseValue(campaign['goal']!);
    double progress = goal != 0 ? raised / goal : 0;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CampaignDetailsPage(campaign: campaign),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(campaign['title']!,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Recipient: ${campaign['recipient']}'),
              Text('Goal: ${campaign['goal']}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
              const SizedBox(height: 8),
              Text('${(progress * 100).toStringAsFixed(0)}% funded'),
            ],
          ),
        ),
      ),
    );
  }
}

/// **Campaign Details Page**
class CampaignDetailsPage extends StatelessWidget {
  final Map<String, String> campaign;

  const CampaignDetailsPage({super.key, required this.campaign});

  double _parseValue(String value) {
    return double.parse(value.replaceAll(RegExp(r'[^\d.]'), ''));
  }

  @override
  Widget build(BuildContext context) {
    double raised = _parseValue(campaign['raised']!);
    double goal = _parseValue(campaign['goal']!);
    double progress = goal != 0 ? raised / goal : 0;

    return Scaffold(
      appBar: AppBar(title: Text(campaign['title']!)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(campaign['title']!,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text('Recipient: ${campaign['recipient']}'),
            Text('Category: ${campaign['category']}'),
            Text('Status: ${campaign['status']}'),
            Text(
                'Goal Amount: ${campaign['raised']} ETB / ${campaign['goal']} ETB'),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            Text('Launch Date: ${campaign['launchDate']}'),
            Text('End Date: ${campaign['endDate']}'),
            const SizedBox(height: 16),
            Text('Description:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(campaign['description']!),
            const SizedBox(height: 16),
            Text('Updates:',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(campaign['updates']!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              child: const Text('Donate'),
            ),
          ],
        ),
      ),
    );
  }
}
