import 'package:flutter/material.dart';
import 'package:mobile/pages/public_campaigns_page.dart';
import 'package:mobile/utils/utils.dart';

class NavPage {
  const NavPage({
    required this.title,
    required this.icon,
    required this.widget,
  });

  final String title;
  final Widget widget;
  final IconData icon;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  final List<NavPage> _navPages = const [
    NavPage(
      title: '    Public\nCampaigns',
      widget: PublicCampaignsPage(),
      icon: Icons.public,
    ),
    NavPage(
      title: 'My Campaigns',
      widget: Center(child: Text('My Campaigns Page')),
      icon: Icons.folder,
    ),
    NavPage(
      title: 'Campaign\n requests',
      widget: Center(child: Text('Campaign Requests Page')),
      icon: Icons.list_alt,
    ),
    NavPage(
      title: 'Settings',
      widget: Center(child: Text('Profile and Settings Page')),
      icon: Icons.settings,
    ),
  ];

  void _onDestinationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toTitleCase(_navPages[_selectedIndex].title),
          style: currentTheme.textTheme.titleLarge?.copyWith(
            color: currentTheme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: currentTheme.colorScheme.primary,
        iconTheme: IconThemeData(color: currentTheme.colorScheme.onPrimary),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: currentTheme.colorScheme.onPrimary,
            ),
            tooltip: 'Notifications',
            onPressed: () {},
          ),
        ],
      ),
      body: _navPages[_selectedIndex].widget,
      bottomNavigationBar: NavigationBar(
        destinations: _navPages
            .map(
              (navPage) => NavigationDestination(
                icon: Icon(navPage.icon),
                label: navPage.title,
              ),
            )
            .toList(),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationTapped,
      ),
    );
  }
}
