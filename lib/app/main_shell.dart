import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/bmi/bmi_calculator_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/account_settings_screen.dart';
import '../screens/users/users_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    final destinations = <NavigationDestination>[
      const NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: 'Dashboard'),
      const NavigationDestination(
          icon: Icon(Icons.people_outline),
          selectedIcon: Icon(Icons.people),
          label: 'Users'),
      const NavigationDestination(
          icon: Icon(Icons.monitor_weight_outlined),
          selectedIcon: Icon(Icons.monitor_weight),
          label: 'BMI'),
      if (isAdmin)
        const NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports'),
      const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Profile'),
    ];

    final screens = <Widget>[
      const DashboardScreen(),
      const UsersScreen(),
      const BmiCalculatorScreen(),
      if (isAdmin) const ReportsScreen(),
      const AccountSettingsScreen(),
    ];

    if (_index >= screens.length) _index = 0;

    // Wide screens (tablet/desktop/foldables opened flat) get a side
    // NavigationRail; phones get the bottom NavigationBar. Both drive the
    // same IndexedStack so navigation state is identical either way.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: (i) => setState(() => _index = i),
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: d.icon,
                        selectedIcon: d.selectedIcon,
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: IndexedStack(index: _index, children: screens)),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _index, children: screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: destinations,
          ),
        );
      },
    );
  }
}
