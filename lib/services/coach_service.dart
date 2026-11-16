import 'package:cloud_functions/cloud_functions.dart';

/// Asks the Quest Coach (server-side agent) for a hint.
/// The question is trimmed and capped at 300 characters; the server checks again.
Future<String> getQuestHint(String question) async {
  final trimmed = question.trim();
  final safe = trimmed.length > 300 ? trimmed.substring(0, 300) : trimmed;
  final callable = FirebaseFunctions.instance.httpsCallable('askQuestCoach');
  final result = await callable.call<Map<Object?, Object?>>({'question': safe});
  return result.data['reply'] as String;
}
