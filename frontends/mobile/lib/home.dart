import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/components/login_required.dart';
import 'package:mobile/pages/profile_page.dart';
import 'package:mobile/pages/campaigns_page.dart';
import 'package:mobile/pages/campaign_requests_page.dart';
import 'package:mobile/services/providers.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    List<NavBarPage> navBarPages = [
      const NavBarPage(
        title: '    Public\nCampaigns',
        pageWidget: CampaignsPage(),
        icon: Icons.public,
      ),
      NavBarPage(
        title: '       My\nCampaigns',
        pageWidget: userProvider.isLoggedIn
            ? const CampaignsPage(isPublicList: false)
            : const LoginRequired(),
        icon: Icons.folder,
      ),
      NavBarPage(
        title: 'Campaign\n requests',
        pageWidget: userProvider.isLoggedIn
            ? const CampaignRequestsPage()
            : const LoginRequired(),
        icon: Icons.list_alt,
      ),
      NavBarPage(
        title: 'Profile\n',
        pageWidget: userProvider.isLoggedIn
            ? (userProvider.user != null
                ? ProfilePage(initialRecipient: userProvider.user!)
                : const Center(child: CircularProgressIndicator()))
            : const LoginRequired(),
        icon: Icons.account_circle_rounded,
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(pageTitle: navBarPages[_selectedIndex].title),
      body: IndexedStack(
        index: _selectedIndex,
        children: navBarPages.map((navPage) => navPage.pageWidget).toList(),
      ),
      bottomNavigationBar: NavigationBar(
        destinations: navBarPages
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

  //****** Helper methods
  void _onDestinationTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

class NavBarPage {
  const NavBarPage({
    required this.title,
    required this.icon,
    required this.pageWidget,
  });

  final String title;
  final Widget pageWidget;
  final IconData icon;
}
