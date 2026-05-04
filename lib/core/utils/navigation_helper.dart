import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  static void navigateToSplash(BuildContext context) {
    context.go('/splash');
  }

  static void navigateToOnboarding(BuildContext context) {
    context.go('/onboarding');
  }

  static void navigateToLogin(BuildContext context) {
    context.go('/login');
  }

  static void navigateToRegister(BuildContext context) {
    context.go('/register');
  }

  static void navigateToHome(BuildContext context) {
    context.go('/home');
  }

  static void navigateToCameras(BuildContext context) {
    context.go('/cameras');
  }

  static void navigateToLiveStream(BuildContext context, {String? cameraId}) {
    if (cameraId != null) {
      context.go('/live-stream?cameraId=$cameraId');
    } else {
      context.go('/live-stream');
    }
  }

  static void navigateToAnalytics(BuildContext context) {
    context.go('/analytics');
  }

  static void navigateToHistory(BuildContext context) {
    context.go('/history');
  }

  static void navigateToProfile(BuildContext context) {
    context.go('/profile');
  }

  static void navigateToSettings(BuildContext context) {
    context.go('/settings');
  }

  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }
}
