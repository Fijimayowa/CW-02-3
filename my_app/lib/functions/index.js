import { onCall, HttpsError } from "firebase-functions/v2/https";
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

export { askQuestCoach } from "./questCoach.js";

const REWARD_POINTS = 10;
const REWARD_BADGE = "first-quest";

export const completeToday = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in first.");
  if (request.data?.challengeId !== "today") {
    throw new HttpsError("invalid-argument", "Unknown challenge.");
  }
  const uid = request.auth.uid; // never read a UID from request.data
  const challengeRef = db.doc("challenges/today");
  const progressRef = db.doc(`users/${uid}/progress/today`);

  return db.runTransaction(async (tx) => {
    const [challenge, progress] = await Promise.all([
      tx.get(challengeRef),
      tx.get(progressRef),
    ]);
    if (!challenge.exists) throw new HttpsError("not-found", "No challenge today.");
    if (progress.exists) {
      const d = progress.data();
      return { completed: true, points: d.points, badgeId: d.badgeId, alreadyCompleted: true };
    }
    tx.set(progressRef, {
      completed: true,
      points: REWARD_POINTS,
      badgeId: REWARD_BADGE,
      completedAt: FieldValue.serverTimestamp(),
    });
    return { completed: true, points: REWARD_POINTS, badgeId: REWARD_BADGE, alreadyCompleted: false };
  });
});