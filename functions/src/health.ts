import { onCall } from "firebase-functions/v2/https";

/**
 * Simple callable used to verify the Functions deployment pipeline
 * (Firebase project, billing, region) works end-to-end before the
 * real assessment/performance functions are built.
 */
export const helloWorld = onCall({ region: "asia-south1" }, () => {
  return { status: "ok", message: "PreparationHotspot functions are live." };
});
