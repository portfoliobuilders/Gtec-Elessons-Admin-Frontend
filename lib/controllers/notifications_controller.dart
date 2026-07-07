import 'package:flutter/foundation.dart';

/// Notifications / Broadcast composer.
class NotificationsController extends ChangeNotifier {
  final List<String> channels = const ['Push', 'Email', 'In-app'];
  int selectedChannel = 0;

  final String title = 'New mock tests are live! 📝';
  final String message =
      '10 new full-length mock tests just dropped for Class 10 Science. '
      'Attempt them before Sunday to top the leaderboard.';

  final List<String> audiences = const [
    'Class 10 · CBSE',
    'All students',
    'By batch',
  ];
  int selectedAudience = 0;

  final String estimatedReach = '3,210';
  final String sendTime = 'Now';

  void selectChannel(int index) {
    selectedChannel = index;
    notifyListeners();
  }

  void selectAudience(int index) {
    selectedAudience = index;
    notifyListeners();
  }
}
