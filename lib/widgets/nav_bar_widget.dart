import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/navigation_provider.dart';

class NavBarWidget extends StatelessWidget {
  const NavBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavigationProvider>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: nav.canGoBack ? () => nav.goBack() : null,
          tooltip: 'Back',
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: nav.canGoForward ? () => nav.goForward() : null,
          tooltip: 'Forward',
        ),
      ],
    );
  }
}
