import 'package:flutter/material.dart';

class NavigationState extends ChangeNotifier {
  int _currentIndex = 0;
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  int get currentIndex => _currentIndex;
  List<GlobalKey<NavigatorState>> get navigatorKeys => _navigatorKeys;

  void setCurrentIndex(int index) {
    if (index != _currentIndex && index >= 0 && index < _navigatorKeys.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void resetToTab(int index) {
    // Pop all routes in the tab and go to root
    final navigatorKey = _navigatorKeys[index];
    if (navigatorKey.currentState?.canPop() == true) {
      navigatorKey.currentState?.popUntil((route) => route.isFirst);
    }
    setCurrentIndex(index);
  }

  bool handleBackPress() {
    final currentNavigator = _navigatorKeys[_currentIndex].currentState;
    if (currentNavigator?.canPop() == true) {
      currentNavigator?.pop();
      return true;
    }
    return false;
  }
}
