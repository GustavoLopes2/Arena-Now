import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/view/user_root_page.dart';

class UserNavigator {
  static UserRootPageState? _getState(BuildContext context) {
    return context.findAncestorStateOfType<UserRootPageState>();
  }

  static void push(BuildContext context, Widget page) {
    final root = _getState(context);
    if (root != null) {
      root.openPage(page);
    } else {
      debugPrint("⚠ UserNavigator.push foi chamado fora do UserRootPage");
    }
  }

  static void pop(BuildContext context) {
    final root = _getState(context);
    if (root != null && root.hasPages) {
      root.closePage();
    } else {
      Navigator.pop(context);
    }
  }
}
