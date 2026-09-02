import * as admin from "firebase-admin";
import {
  DEFAULT_PERFORMANCE_RULES,
  GradedAnswer,
  PerformanceRules,
  PerformanceStatus,
} from "./types";

/** §13: performance status thresholds. Configurable later from the admin
 * panel via settings/performanceRules -- falls back to the spec defaults. */
export async function loadPerformanceRules(
  db: admin.firestore.Firestore
): Promise<PerformanceRules> {
  const snap = await db.collection("settings").doc("performanceRules").get();
  if (!snap.exists) return DEFAULT_PERFORMANCE_RULES;
  const data = snap.data()!;
  return {
    weakMax: data.weakMax ?? DEFAULT_PERFORMANCE_RULES.weakMax,
    averageMax: data.averageMax ?? DEFAULT_PERFORMANCE_RULES.averageMax,
    minAttemptsForStatus:
      data.minAttemptsForStatus ?? DEFAULT_PERFORMANCE_RULES.minAttemptsForStatus,
  };
}

export function computeStatus(
  accuracy: number,
  attemptedQuestions: number,
  rules: PerformanceRules
): PerformanceStatus {
  if (attemptedQuestions < rules.minAttemptsForStatus) return "insufficient_data";
  if (accuracy <= rules.weakMax) return "weak";
  if (accuracy <= rules.averageMax) return "average";
  return "strong";
}

interface NodeKey {
  level: "subject" | "chapter" | "topic";
  docId: string;
  subjectId: string;
  subjectName: string;
  chapterId: string | null;
  chapterName: string | null;
  topicId: string | null;
  topicName: string | null;
}

function nodeKeysFor(a: GradedAnswer, userId: string, examId: string): NodeKey[] {
  return [
    {
      level: "subject",
      docId: `${userId}_${examId}_s_${a.subjectId}`,
      subjectId: a.subjectId,
      subjectName: a.subjectName,
      chapterId: null,
      chapterName: null,
      topicId: null,
      topicName: null,
    },
    {
      level: "chapter",
      docId: `${userId}_${examId}_c_${a.subjectId}_${a.chapterId}`,
      subjectId: a.subjectId,
      subjectName: a.subjectName,
      chapterId: a.chapterId,
      chapterName: a.chapterName,
      topicId: null,
      topicName: null,
    },
    {
      level: "topic",
      docId: `${userId}_${examId}_t_${a.subjectId}_${a.chapterId}_${a.topicId}`,
      subjectId: a.subjectId,
      subjectName: a.subjectName,
      chapterId: a.chapterId,
      chapterName: a.chapterName,
      topicId: a.topicId,
      topicName: a.topicName,
    },
  ];
}

/** §12/§14: recompute subject/chapter/topic level `user_performance` docs
 * from a freshly graded set of answers, and roll up the user's overall
 * aggregate counters on `users/{uid}`. Runs inside a single transaction so
 * a half-written aggregate is never visible to the client. */
export async function calculatePerformance(
  db: admin.firestore.Firestore,
  userId: string,
  examId: string,
  gradedAnswers: GradedAnswer[]
): Promise<{ overallAccuracy: number; overallCorrect: number; overallIncorrect: number }> {
  const rules = await loadPerformanceRules(db);
  const perfCollection = db.collection("user_performance");

  // Group graded answers per node so each node is only read/written once.
  const nodeToAnswers = new Map<string, { key: NodeKey; answers: GradedAnswer[] }>();
  for (const answer of gradedAnswers) {
    for (const key of nodeKeysFor(answer, userId, examId)) {
      const entry = nodeToAnswers.get(key.docId);
      if (entry) {
        entry.answers.push(answer);
      } else {
        nodeToAnswers.set(key.docId, { key, answers: [answer] });
      }
    }
  }

  let overallCorrect = 0;
  let overallIncorrect = 0;
  let overallUnanswered = 0;

  const userRef = db.collection("users").doc(userId);

  await db.runTransaction(async (tx) => {
    // All reads must happen before any write in a Firestore transaction --
    // so the user doc is read here alongside the performance node docs,
    // not later once the per-node tx.set() calls below have started.
    const refs = [...nodeToAnswers.keys()].map((docId) => perfCollection.doc(docId));
    const [snaps, userSnap] = await Promise.all([
      Promise.all(refs.map((ref) => tx.get(ref))),
      tx.get(userRef),
    ]);

    snaps.forEach((snap, i) => {
      const [docId, entry] = [...nodeToAnswers.entries()][i];
      const existing = snap.exists ? snap.data()! : null;

      let totalQuestions = existing?.totalQuestions ?? 0;
      let attemptedQuestions = existing?.attemptedQuestions ?? 0;
      let correctAnswers = existing?.correctAnswers ?? 0;
      let incorrectAnswers = existing?.incorrectAnswers ?? 0;
      let unansweredQuestions = existing?.unansweredQuestions ?? 0;
      let totalTimeTaken = existing?.totalTimeTaken ?? 0;

      for (const a of entry.answers) {
        totalQuestions += 1;
        totalTimeTaken += a.timeTaken;
        if (!a.isAnswered) {
          unansweredQuestions += 1;
        } else {
          attemptedQuestions += 1;
          if (a.isCorrect) correctAnswers += 1;
          else incorrectAnswers += 1;
        }
      }

      const accuracy = attemptedQuestions > 0
        ? Math.round((correctAnswers / attemptedQuestions) * 10000) / 100
        : 0;
      const averageTime = totalQuestions > 0
        ? Math.round((totalTimeTaken / totalQuestions) * 100) / 100
        : 0;
      const status = computeStatus(accuracy, attemptedQuestions, rules);

      tx.set(
        perfCollection.doc(docId),
        {
          userId,
          examId,
          subjectId: entry.key.subjectId,
          subjectName: entry.key.subjectName,
          chapterId: entry.key.chapterId,
          chapterName: entry.key.chapterName,
          topicId: entry.key.topicId,
          topicName: entry.key.topicName,
          level: entry.key.level,
          totalQuestions,
          attemptedQuestions,
          correctAnswers,
          incorrectAnswers,
          unansweredQuestions,
          totalTimeTaken,
          accuracy,
          averageTime,
          performanceStatus: status,
          lastAttemptedAt: admin.firestore.FieldValue.serverTimestamp(),
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      if (entry.key.level === "topic") {
        // Topic level is the finest grain -- use it (not subject/chapter,
        // which double count) for the user-wide overall rollup below.
        const topicCorrect = entry.answers.filter((a) => a.isAnswered && a.isCorrect).length;
        const topicIncorrect = entry.answers.filter((a) => a.isAnswered && !a.isCorrect).length;
        const topicUnanswered = entry.answers.filter((a) => !a.isAnswered).length;
        overallCorrect += topicCorrect;
        overallIncorrect += topicIncorrect;
        overallUnanswered += topicUnanswered;
      }
    });

    const userData = userSnap.data() ?? {};
    const newQuestionsAttempted =
      (userData.questionsAttempted ?? 0) + overallCorrect + overallIncorrect;
    const newQuestionsCorrect = (userData.questionsCorrect ?? 0) + overallCorrect;
    const newQuestionsIncorrect = (userData.questionsIncorrect ?? 0) + overallIncorrect;
    const newOverallAccuracy = newQuestionsAttempted > 0
      ? Math.round((newQuestionsCorrect / newQuestionsAttempted) * 10000) / 100
      : 0;

    tx.set(
      userRef,
      {
        questionsAttempted: newQuestionsAttempted,
        questionsCorrect: newQuestionsCorrect,
        questionsIncorrect: newQuestionsIncorrect,
        overallAccuracy: newOverallAccuracy,
        assessmentCompleted: true,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );
  });

  const totalGraded = overallCorrect + overallIncorrect;
  return {
    overallAccuracy: totalGraded > 0
      ? Math.round((overallCorrect / totalGraded) * 10000) / 100
      : 0,
    overallCorrect,
    overallIncorrect,
  };
}
