import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { RecommendedAction, StudyPlanItem, StudyPlanPriority } from "./types";

const REGION = "asia-south1";

interface TopicPerformance {
  subjectId: string;
  subjectName: string;
  chapterId: string;
  chapterName: string;
  topicId: string;
  topicName: string;
  accuracy: number;
  attemptedQuestions: number;
  performanceStatus: string;
}

/** §17: pure rule-based mapping from a topic's accuracy to a study-plan
 * item -- no AI, no ML, just the thresholds the spec defines. */
function toStudyPlanItem(topic: TopicPerformance): StudyPlanItem {
  let priority: StudyPlanPriority;
  let recommendedAction: RecommendedAction;
  let recommendedQuestions: number;
  let recommendedDifficulty: StudyPlanItem["recommendedDifficulty"];
  let reason: string;

  if (topic.performanceStatus === "weak") {
    priority = "high";
    recommendedAction = "learning_practice";
    recommendedQuestions = 20;
    recommendedDifficulty = "easy";
    reason = `Accuracy is ${topic.accuracy}% across ${topic.attemptedQuestions} ` +
      "questions attempted -- this needs focused attention.";
  } else if (topic.performanceStatus === "average") {
    priority = "medium";
    recommendedAction = "practice";
    recommendedQuestions = 15;
    recommendedDifficulty = "medium";
    reason = `Accuracy is ${topic.accuracy}% -- more practice will push this into your strong areas.`;
  } else {
    priority = "low";
    recommendedAction = "revision";
    recommendedQuestions = 5;
    recommendedDifficulty = "hard";
    reason = `Accuracy is ${topic.accuracy}% -- keep this sharp with periodic revision.`;
  }

  return {
    subjectId: topic.subjectId,
    subjectName: topic.subjectName,
    chapterId: topic.chapterId,
    chapterName: topic.chapterName,
    topicId: topic.topicId,
    topicName: topic.topicName,
    priority,
    reason,
    accuracy: topic.accuracy,
    recommendedQuestions,
    recommendedDifficulty,
    recommendedAction,
    status: "pending",
  };
}

const PRIORITY_ORDER: Record<StudyPlanPriority, number> = { high: 0, medium: 1, low: 2 };

/** §16/§17: (re)builds the student's study plan from their current
 * `user_performance` topic data. Called automatically right after
 * `calculatePerformance` on every diagnostic submission, so the plan is
 * ready the moment the student reaches Home -- also exposed as a callable
 * for a manual "Refresh My Plan" action later. */
export async function generateStudyPlan(
  db: admin.firestore.Firestore,
  userId: string,
  examId: string
): Promise<void> {
  const snap = await db
    .collection("user_performance")
    .where("userId", "==", userId)
    .where("examId", "==", examId)
    .where("level", "==", "topic")
    .get();

  const topics = snap.docs
    .map((d) => d.data() as TopicPerformance)
    .filter((t) => t.performanceStatus !== "insufficient_data");

  const items = topics
    .map(toStudyPlanItem)
    .sort((a, b) => {
      const priorityDiff = PRIORITY_ORDER[a.priority] - PRIORITY_ORDER[b.priority];
      return priorityDiff !== 0 ? priorityDiff : a.accuracy - b.accuracy;
    });

  const weakCount = items.filter((i) => i.priority === "high").length;
  const averageCount = items.filter((i) => i.priority === "medium").length;
  const strongCount = items.filter((i) => i.priority === "low").length;

  const overallPriority: StudyPlanPriority =
    weakCount > 0 ? "high" : averageCount > 0 ? "medium" : "low";

  const planRef = db.collection("study_plans").doc(`${userId}_${examId}`);
  const now = admin.firestore.FieldValue.serverTimestamp();

  await planRef.set(
    {
      userId,
      examId,
      title: "Your Preparation Plan",
      description: items.length === 0
        ? "Complete a diagnostic assessment to get your personalized plan."
        : `${weakCount} topic${weakCount === 1 ? "" : "s"} need attention, ` +
          `${averageCount} at average, ${strongCount} strong.`,
      priority: overallPriority,
      status: "active",
      updatedAt: now,
      createdAt: now,
    },
    { merge: true }
  );

  // Rebuild items fresh each time -- topic count is small (dozens, not
  // thousands), so delete+rewrite is simpler and safer than diffing.
  const itemsCollection = planRef.collection("items");
  const existing = await itemsCollection.get();
  const batch = db.batch();
  existing.docs.forEach((doc) => batch.delete(doc.ref));
  items.forEach((item) => {
    const itemRef = itemsCollection.doc(`${item.subjectId}_${item.chapterId}_${item.topicId}`);
    batch.set(itemRef, { ...item, updatedAt: now });
  });
  await batch.commit();
}

export const regenerateStudyPlan = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const examId = request.data?.examId as string | undefined;
  if (!examId) throw new HttpsError("invalid-argument", "examId is required.");

  await generateStudyPlan(admin.firestore(), uid, examId);
  return { status: "ok" };
});
