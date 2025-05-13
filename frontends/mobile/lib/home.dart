import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/pages/login_required_page.dart';
import 'package:mobile/pages/my_campaigns_page.dart';
import 'package:mobile/pages/public_campaigns_page.dart';
import 'package:mobile/services/providers.dart';
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
    // final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = true; // userProvider.credentials != null;

    List<NavPage> navPages = [
      const NavPage(
        title: '    Public\nCampaigns',
        pageWidget: PublicCampaignsPage(),
        icon: Icons.public,
      ),
      NavPage(
        title: '       My\nCampaigns',
        pageWidget:
            isLoggedIn ? const MyCampaignsPage() : const LoginRequiredPage(),
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
      appBar: CustomAppBar(pageTitle: navPages[_selectedIndex].title),
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
