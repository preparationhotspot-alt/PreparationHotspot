import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import { gradeAnswer } from "./grading";
import { calculatePerformance } from "./performance";
import { generateStudyPlan } from "./studyPlan";
import {
  DiagnosticConfigDoc,
  GradedAnswer,
  QuestionDoc,
  SanitizedQuestion,
  SubmittedAnswer,
} from "./types";

const REGION = "asia-south1";

function sanitize(id: string, q: QuestionDoc): SanitizedQuestion {
  return {
    questionId: id,
    subjectId: q.subjectId,
    subjectName: q.subjectName,
    chapterId: q.chapterId,
    chapterName: q.chapterName,
    topicId: q.topicId,
    topicName: q.topicName,
    questionType: q.questionType,
    difficulty: q.difficulty,
    questionText: q.questionText,
    questionImage: q.questionImage ?? null,
    options: q.options,
    marks: q.marks,
    negativeMarks: q.negativeMarks,
  };
}

function shuffle<T>(arr: T[]): T[] {
  const copy = [...arr];
  for (let i = copy.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [copy[i], copy[j]] = [copy[j], copy[i]];
  }
  return copy;
}

/** §9-§10: builds the 30-question diagnostic set from admin-defined
 * distribution rules (`diagnostic_config/{examId}`), never from unweighted
 * random selection. Creates the `diagnostic_attempts` doc up front so the
 * question order/set is fixed and can be re-graded server-side on submit. */
export const generateDiagnosticAssessment = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const examId = request.data?.examId as string | undefined;
  if (!examId) throw new HttpsError("invalid-argument", "examId is required.");

  const db = admin.firestore();

  const configSnap = await db.collection("diagnostic_config").doc(examId).get();
  if (!configSnap.exists) {
    throw new HttpsError("failed-precondition", "No diagnostic configuration for this exam.");
  }
  const config = configSnap.data() as DiagnosticConfigDoc;

  const picked: { id: string; data: QuestionDoc }[] = [];
  const usedIds = new Set<string>();

  for (const rule of config.distribution) {
    let query: FirebaseFirestore.Query = db
      .collection("questions")
      .where("examId", "==", examId)
      .where("subjectId", "==", rule.subjectId)
      .where("status", "==", "published");
    if (rule.chapterId) query = query.where("chapterId", "==", rule.chapterId);
    if (rule.topicId) query = query.where("topicId", "==", rule.topicId);
    if (rule.difficulty) query = query.where("difficulty", "==", rule.difficulty);

    const snap = await query.limit(Math.max(rule.count * 4, 20)).get();
    const candidates = shuffle(
      snap.docs.filter((d) => !usedIds.has(d.id))
    );

    if (candidates.length < rule.count) {
      throw new HttpsError(
        "failed-precondition",
        `Not enough published questions for subject=${rule.subjectId}` +
          (rule.chapterId ? ` chapter=${rule.chapterId}` : "") +
          (rule.topicId ? ` topic=${rule.topicId}` : "") +
          ` (need ${rule.count}, found ${candidates.length}).`
      );
    }

    for (const doc of candidates.slice(0, rule.count)) {
      usedIds.add(doc.id);
      picked.push({ id: doc.id, data: doc.data() as QuestionDoc });
    }
  }

  const ordered = shuffle(picked);
  const attemptRef = db.collection("diagnostic_attempts").doc();
  await attemptRef.set({
    userId: uid,
    examId,
    assessmentId: examId,
    questionIds: ordered.map((q) => q.id),
    startedAt: admin.firestore.FieldValue.serverTimestamp(),
    submittedAt: null,
    duration: config.durationMinutes * 60,
    totalQuestions: ordered.length,
    correctAnswers: 0,
    incorrectAnswers: 0,
    unanswered: ordered.length,
    score: 0,
    accuracy: 0,
    status: "in_progress",
    answers: [],
  });

  return {
    attemptId: attemptRef.id,
    durationMinutes: config.durationMinutes,
    totalQuestions: ordered.length,
    questions: ordered.map((q) => sanitize(q.id, q.data)),
  };
});

/** §11-§12: grades answers server-side (client never sees correct answers
 * or scoring logic before this point) then immediately recalculates the
 * user's subject/chapter/topic performance aggregates (§13-§14). */
export const submitDiagnosticAssessment = onCall({ region: REGION }, async (request) => {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Sign in required.");

  const attemptId = request.data?.attemptId as string | undefined;
  const submittedAnswers = (request.data?.answers ?? []) as SubmittedAnswer[];
  if (!attemptId) throw new HttpsError("invalid-argument", "attemptId is required.");

  const db = admin.firestore();
  const attemptRef = db.collection("diagnostic_attempts").doc(attemptId);
  const attemptSnap = await attemptRef.get();
  if (!attemptSnap.exists) throw new HttpsError("not-found", "Attempt not found.");

  const attempt = attemptSnap.data()!;
  if (attempt.userId !== uid) {
    throw new HttpsError("permission-denied", "This attempt does not belong to you.");
  }
  if (attempt.status !== "in_progress") {
    throw new HttpsError("failed-precondition", "This attempt was already submitted.");
  }

  const questionIds: string[] = attempt.questionIds ?? [];
  const answerByQuestionId = new Map(submittedAnswers.map((a) => [a.questionId, a]));

  const questionDocs = await db.getAll(
    ...questionIds.map((id) => db.collection("questions").doc(id))
  );

  const gradedAnswers: GradedAnswer[] = questionDocs.map((snap) => {
    const q = snap.data() as QuestionDoc;
    const submitted = answerByQuestionId.get(snap.id);
    const { isCorrect, isAnswered, marksAwarded } = gradeAnswer(q, submitted);
    return {
      questionId: snap.id,
      selectedAnswer: submitted?.selectedAnswer ?? null,
      correctAnswer: q.correctAnswer,
      isCorrect,
      isAnswered,
      timeTaken: submitted?.timeTaken ?? 0,
      marksAwarded,
      subjectId: q.subjectId,
      subjectName: q.subjectName,
      chapterId: q.chapterId,
      chapterName: q.chapterName,
      topicId: q.topicId,
      topicName: q.topicName,
    };
  });

  const correctAnswers = gradedAnswers.filter((a) => a.isAnswered && a.isCorrect).length;
  const incorrectAnswers = gradedAnswers.filter((a) => a.isAnswered && !a.isCorrect).length;
  const unanswered = gradedAnswers.filter((a) => !a.isAnswered).length;
  const score = gradedAnswers.reduce((sum, a) => sum + a.marksAwarded, 0);
  const accuracy = correctAnswers + incorrectAnswers > 0
    ? Math.round((correctAnswers / (correctAnswers + incorrectAnswers)) * 10000) / 100
    : 0;

  await attemptRef.update({
    submittedAt: admin.firestore.FieldValue.serverTimestamp(),
    correctAnswers,
    incorrectAnswers,
    unanswered,
    score,
    accuracy,
    status: "submitted",
    answers: gradedAnswers,
  });

  await calculatePerformance(db, uid, attempt.examId, gradedAnswers);
  await generateStudyPlan(db, uid, attempt.examId);

  // Explanations/correct answers are safe to reveal now that this attempt
  // is graded -- §23 review needs them, and the student can no longer
  // change their answers to game the score.
  const reviewAnswers = questionDocs.map((snap) => {
    const q = snap.data() as QuestionDoc;
    const graded = gradedAnswers.find((g) => g.questionId === snap.id)!;
    return {
      questionId: snap.id,
      questionText: q.questionText,
      questionImage: q.questionImage ?? null,
      options: q.options ?? [],
      selectedAnswer: graded.selectedAnswer,
      correctAnswer: graded.correctAnswer,
      isCorrect: graded.isCorrect,
      isAnswered: graded.isAnswered,
      explanation: q.explanation ?? "",
      subjectId: q.subjectId,
      subjectName: q.subjectName,
      chapterId: q.chapterId,
      chapterName: q.chapterName,
      topicId: q.topicId,
      topicName: q.topicName,
    };
  });

  return {
    attemptId,
    correctAnswers,
    incorrectAnswers,
    unanswered,
    score,
    accuracy,
    totalQuestions: questionIds.length,
    reviewAnswers,
  };
});
