import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/navigation/user_navigator.dart';

class UserAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const UserAppBar({
    super.key,
    required this.title,
    this.showBack = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF0E1A2F),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: true,
      title: Row(
        mainAxisAlignment:
            showBack ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: [
          if (showBack)
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => UserNavigator.pop(context),
            ),
          if (showBack) const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              textAlign: showBack ? TextAlign.start : TextAlign.center,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
