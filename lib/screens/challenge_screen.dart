import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/coach_service.dart';
import '../services/reward_service.dart';

typedef DocStream = Stream<DocumentSnapshot<Map<String, dynamic>>>;

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key, required this.user});
  final User user;

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  late final DocStream _challenge;
  late final DocStream _progress;
  final _question = TextEditingController();

  bool _completing = false;
  bool _asking = false;
  String? _rewardMessage;
  String? _coachReply;

  @override
  void initState() {
    super.initState();
    final db = FirebaseFirestore.instance;
    _challenge = db.doc('challenges/today').snapshots();
    // Only this learner's own progress document.
    _progress = db.doc('users/${widget.user.uid}/progress/today').snapshots();
  }

  @override
  void dispose() {
    _question.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    setState(() {
      _completing = true;
      _rewardMessage = null;
    });
    try {
      final r = await completeChallenge();
      _rewardMessage = r.alreadyCompleted
          ? 'Already completed. You keep your ${r.points} points.'
          : 'Done! +${r.points} points and the "${r.badgeId}" badge.';
    } on FirebaseFunctionsException catch (e) {
      debugPrint('completeToday failed: ${e.code}');
      _rewardMessage = 'Could not complete the challenge. Please try again.';
    } catch (e) {
      debugPrint('completeToday failed: $e');
      _rewardMessage = 'Could not complete the challenge. Please try again.';
    } finally {
      if (mounted) setState(() => _completing = false);
    }
  }

  Future<void> _askCoach() async {
    if (_question.text.trim().isEmpty) {
      setState(() => _coachReply = 'Type a question first.');
      return;
    }
    setState(() {
      _asking = true;
      _coachReply = null;
    });
    try {
      final reply = await getQuestHint(_question.text);
      if (mounted) setState(() => _coachReply = reply);
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Quest Coach request failed: ${e.code}');
      if (mounted) {
        setState(() => _coachReply = 'The coach is unavailable. Try again.');
      }
    } catch (e) {
      debugPrint('Quest Coach request failed: $e');
      if (mounted) {
        setState(() => _coachReply = 'The coach is unavailable. Try again.');
      }
    } finally {
      if (mounted) setState(() => _asking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Quest'),
        actions: [
          TextButton(onPressed: logOut, child: const Text('Sign out')),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Signed in as ${widget.user.email ?? widget.user.uid}'),
            const SizedBox(height: 16),
            Text("Today's challenge", style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _challenge,
              builder: (context, snap) {
                if (snap.hasError) {
                  return const Text('Could not load the challenge.');
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snap.data!.data();
                if (data == null) {
                  return const Text('No challenge today.');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${data['title']}', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('${data['prompt']}'),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _progress,
              builder: (context, snap) {
                final p = snap.data?.data();
                final done = p?['completed'] == true;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FilledButton(
                      onPressed: (_completing || done) ? null : _complete,
                      child: Text(done
                          ? 'Completed'
                          : (_completing ? 'Completing…' : 'Complete challenge')),
                    ),
                    if (_rewardMessage != null) ...[
                      const SizedBox(height: 8),
                      Text(_rewardMessage!),
                    ],
                    const SizedBox(height: 12),
                    Text(done
                        ? 'Points: ${p?['points']}   Badge: ${p?['badgeId']}'
                        : 'Points: 0   Badge: none yet'),
                  ],
                );
              },
            ),
            const Divider(height: 32),
            Text('Quest Coach', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _question,
              maxLength: 300,
              decoration: const InputDecoration(
                labelText: 'Ask the Quest Coach for a hint',
                border: OutlineInputBorder(),
              ),
            ),
            OutlinedButton(
              onPressed: _asking ? null : _askCoach,
              child: Text(_asking ? 'Thinking…' : 'Get hint'),
            ),
            if (_coachReply != null) ...[
              const SizedBox(height: 12),
              Text('Coach: $_coachReply'), // rendered as plain text
            ],
          ],
        ),
      ),
    );
  }
}
