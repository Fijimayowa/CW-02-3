import 'package:cloud_functions/cloud_functions.dart';

/// Result of asking the server to complete today's challenge.
class RewardResult {
  RewardResult({
    required this.points,
    required this.badgeId,
    required this.alreadyCompleted,
  });
  final int points;
  final String badgeId;
  final bool alreadyCompleted;
}

// The client sends only the challenge id. The server decides who you are
// (from Auth) and what the reward is.
Future<RewardResult> completeChallenge() async {
  final callable = FirebaseFunctions.instance.httpsCallable('completeToday');
  final result = await callable.call<Map<Object?, Object?>>({
    'challengeId': 'today',
  });
  final data = result.data;
  return RewardResult(
    points: (data['points'] as num).toInt(),
    badgeId: data['badgeId'] as String,
    alreadyCompleted: data['alreadyCompleted'] == true,
  );
}
