import 'package:flutter/material.dart';
import 'package:mobile/components/custom_appbar.dart';
import 'package:mobile/pages/add_campaign_page.dart';
import 'package:mobile/pages/login_required_page.dart';
import 'package:mobile/pages/profile_page.dart';
import 'package:mobile/pages/campaign_list_page.dart';
import 'package:mobile/services/providers.dart';
import 'package:provider/provider.dart';

class NavPage {
  const NavPage({
    required this.title,
    required this.icon,
    required this.pageWidget,
    this.floatingActionButton,
  });

  final String title;
  final Widget pageWidget;
  final IconData icon;
  final FloatingActionButton? floatingActionButton;
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

  void _addNewCampaign() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddCampaignPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final bool isLoggedIn = userProvider.credentials != null;

    // Define navPages outside of the build method if they don't depend on context or mutable state
    // For now, keeping it here as it depends on `isLoggedIn`
    List<NavPage> navPages = [
      const NavPage(
        title: '    Public\nCampaigns',
        pageWidget: CampaignListPage(),
        icon: Icons.public,
      ),
      NavPage(
        title: '       My\nCampaigns',
        pageWidget: isLoggedIn
            ? const CampaignListPage(isPublicList: false)
            : const LoginRequiredPage(),
        icon: Icons.folder,
        floatingActionButton: isLoggedIn
            ? FloatingActionButton(
                onPressed: () => _addNewCampaign(),
                child: const Icon(Icons.add),
              )
            : null,
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
            ? (userProvider.user != null
                ? ProfilePage(initialRecipient: userProvider.user!)
                : const Center(child: CircularProgressIndicator()))
            : const LoginRequiredPage(),
        icon: Icons.account_circle_rounded,
        floatingActionButton: null,
      ),
    ];

    return Scaffold(
      appBar: CustomAppBar(pageTitle: navPages[_selectedIndex].title),
      body: IndexedStack(
        index: _selectedIndex,
        children: navPages.map((navPage) => navPage.pageWidget).toList(),
      ),
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
      floatingActionButton: navPages[_selectedIndex].floatingActionButton,
    );
  }
}