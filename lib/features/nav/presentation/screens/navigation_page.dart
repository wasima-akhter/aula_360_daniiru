import 'package:flutter/material.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key, this.index = 0});

  final int index;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  late int selectedIndex;

  final List<IconData> icons = const [
    Icons.home_outlined,
    Icons.search_rounded,
    Icons.notifications_none_rounded,
    Icons.person_outline_rounded,
  ];

  final List<String> labels = const ['Home', 'Search', 'Alerts', 'Profile'];

  @override
  void initState() {
    super.initState();

    selectedIndex = widget.index.clamp(0, 3);
  }

  final List<Widget> pages = const [
    _NavigationPlaceholder(title: 'Home', icon: Icons.home_outlined),
    _NavigationPlaceholder(title: 'Search', icon: Icons.search_rounded),
    _NavigationPlaceholder(
      title: 'Alerts',
      icon: Icons.notifications_none_rounded,
    ),
    _NavigationPlaceholder(
      title: 'Profile',
      icon: Icons.person_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[selectedIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      padding: const EdgeInsets.only(top: 14, bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(0),
              _buildNavItem(1),
              _buildNavItem(2),
              _buildNavItem(3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index) {
    final isSelected = selectedIndex == index;

    final color = isSelected
        ? const Color(0xFF123B8F)
        : const Color(0xFF8A93A3);

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            selectedIndex = index;
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icons[index], color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              labels[index],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationPlaceholder extends StatelessWidget {
  final String title;
  final IconData icon;

  const _NavigationPlaceholder({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 55, color: const Color(0xFF123B8F)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
