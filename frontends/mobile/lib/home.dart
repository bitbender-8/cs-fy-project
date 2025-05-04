import 'package:flutter/material.dart';
import 'package:mobile/pages/login_required_page.dart';
import 'package:mobile/pages/public_campaigns_page.dart';
import 'package:mobile/services/notifiers.dart';
import 'package:mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class NavPage {
  const NavPage({
    required this.title,
    required this.icon,
    required this.pageWidget,
  });

  final String title;
  final Widget pageWidget;
  final IconData icon;
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  void _onDestinationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.credentials != null;

    List<NavPage> navPages = [
      const NavPage(
        title: '    Public\nCampaigns',
        pageWidget: PublicCampaignsPage(),
        icon: Icons.public,
      ),
      NavPage(
        title: '       My\nCampaigns',
        pageWidget: isLoggedIn
            ? const Center(child: Text('My Campaigns Page'))
            : const LoginRequiredPage(),
        icon: Icons.folder,
      ),
      NavPage(
        title: 'Campaign\n requests',
        pageWidget: isLoggedIn
            ? const Center(child: Text('Campaign Requests Page'))
            : const LoginRequiredPage(),
        icon: Icons.list_alt,
      ),
      NavPage(
        title: 'Profile\n',
        pageWidget: isLoggedIn
            ? const Center(child: Text('Profile and Settings Page'))
            : const LoginRequiredPage(),
        icon: Icons.account_circle_rounded,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toTitleCase(navPages[_selectedIndex].title),
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
      body: navPages[_selectedIndex].pageWidget,
      bottomNavigationBar: NavigationBar(
        destinations: navPages
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
