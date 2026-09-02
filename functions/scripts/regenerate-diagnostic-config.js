/**
 * Regenerates each exam's `diagnostic_config/{examId}` distribution so
 * every included chapter contributes MIN_QUESTIONS_PER_CHAPTER questions --
 * the §13 threshold for a topic to get a real Strong/Average/Weak rating
 * instead of "Insufficient Data" requires >=3 attempted questions, so a
 * chapter with fewer than that available is excluded from the diagnostic
 * entirely rather than included as a rating that can never resolve.
 *
 * Pulls from ALL published questions for the exam -- run this again after
 * importing more real content (via bulk-import-questions.js) to pick up
 * newly-eligible chapters.
 *
 * Run with a service account key locally:
 *   node scripts/regenerate-diagnostic-config.js
 */
const admin = require("firebase-admin");
const path = require("path");

const serviceAccount = require(path.join(__dirname, "..", "service-account.json"));
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const EXAM_IDS = ["jee-main", "jee-advanced", "mht-cet"];
const MIN_QUESTIONS_PER_CHAPTER = 3;
const MINUTES_PER_QUESTION = 1;

async function regenerate(examId) {
  const snap = await db
    .collection("questions")
    .where("examId", "==", examId)
    .where("status", "==", "published")
    .get();

  const chapterGroups = new Map(); // "subjectId|chapterId" -> { subjectId, chapterId, count }
  snap.forEach((doc) => {
    const q = doc.data();
    const key = `${q.subjectId}|${q.chapterId}`;
    const existing = chapterGroups.get(key);
    if (existing) {
      existing.count += 1;
    } else {
      chapterGroups.set(key, { subjectId: q.subjectId, chapterId: q.chapterId, count: 1 });
    }
  });

  const eligible = [...chapterGroups.values()].filter((c) => c.count >= MIN_QUESTIONS_PER_CHAPTER);
  const skipped = chapterGroups.size - eligible.length;
  const distribution = eligible.map(({ subjectId, chapterId }) => ({
    subjectId,
    chapterId,
    count: MIN_QUESTIONS_PER_CHAPTER,
  }));

  if (distribution.length === 0) {
    console.log(`Skipped ${examId}: no chapter has >=${MIN_QUESTIONS_PER_CHAPTER} published questions yet.`);
    return;
  }

  const totalQuestions = distribution.length * MIN_QUESTIONS_PER_CHAPTER;

  await db.collection("diagnostic_config").doc(examId).set({
    examId,
    totalQuestions,
    durationMinutes: totalQuestions * MINUTES_PER_QUESTION,
    distribution,
    updatedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  console.log(
    `Regenerated diagnostic_config/${examId}: ${distribution.length} chapters x ` +
    `${MIN_QUESTIONS_PER_CHAPTER} = ${totalQuestions} questions ` +
    `(${skipped} chapters skipped, <${MIN_QUESTIONS_PER_CHAPTER} questions available).`
  );
}

async function run() {
  for (const examId of EXAM_IDS) {
    await regenerate(examId);
  }
  process.exit(0);
}

run().catch((err) => {
  console.error("Regeneration failed:", err);
  process.exit(1);
});
