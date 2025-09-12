import 'package:flutter/material.dart';
import 'package:arenanow/modules/user/view/user_root_page.dart';

class UserNavigator {
  static UserRootPageState? _getState(BuildContext context) {
    return context.findAncestorStateOfType<UserRootPageState>();
  }

  static bool canPop(BuildContext context) {
    final state = _getState(context);
    return state != null && state.hasPages;
  }

  static void push(BuildContext context, Widget page) {
    final state = _getState(context);
    if (state != null) {
      state.openPage(page);
    }
  }

  static void pop(BuildContext context) {
    final state = _getState(context);
    if (state != null && state.hasPages) {
      state.closePage();
    }
  }
}
