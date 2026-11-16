// Seeds today's challenge into the Firestore EMULATOR.
// Run (emulators must be running):
//   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 GCLOUD_PROJECT=<your-project-id> node seed.js
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";

initializeApp();
await getFirestore().doc("challenges/today").set({
  title: "Name three Firebase services",
  prompt:
    "In one sentence each, say what Firebase Authentication, Cloud Firestore, and Cloud Functions do.",
});
console.log("Seeded challenges/today");
