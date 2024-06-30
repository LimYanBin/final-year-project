// algorithm.dart
// ignore_for_file: avoid_print

class Algorithm {

  final List<String> farmKeywords = [
    'create a farm profile',
    'create a new farm profile',
    'create farm profile',
    'create new farm profile',
    'add farm profile',
    'add new farm profile',
    'add a farm profile',
    'add a new farm profile',
  ];
  final List<String> fertilizerKeywords = [
    'create a fertilizer profile',
    'create fertilizer profile'
  ];
   final List<String> pesticideKeywords = [
    'create a pesticide profile',
    'create pesticide profile'
  ];

  int processInput(String input) {
    if (_containsKeyword(input, farmKeywords)) {
      return 1;
    } else if (_containsKeyword(input, fertilizerKeywords)) {
      return 2;
    } else if (_containsKeyword(input, pesticideKeywords)) {
      return 3;
    } else {
      print('Invalid command, please try again');
      return 0;
    }
  }

  bool _containsKeyword(String input, List<String> keywords) {
    for (String keyword in keywords) {
      if (input.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
