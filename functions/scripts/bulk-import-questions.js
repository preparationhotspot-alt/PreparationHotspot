/**
 * Bulk question import (§37) -- loads a CSV of questions into the
 * `questions` collection, validating every row before writing anything.
 *
 * This is a CLI equivalent of the admin panel's Question Bank > Import CSV
 * screen (lib/modules/admin/questions) -- same validation rules and CSV
 * shape (see lib/modules/admin/questions/utils/question_csv_parser.dart),
 * useful for large imports or automation outside the browser.
 *
 * Usage:
 *   node scripts/bulk-import-questions.js path/to/questions.csv
 *
 * CSV columns:
 *   exam, subject, chapter, topic, difficulty, question,
 *   option_a, option_b, option_c, option_d, correct_answer,
 *   explanation, marks, negative_marks, source, year
 *
 * All rows are validated first. If ANY row is invalid, nothing is written
 * -- re-run after fixing the reported rows. Safe to re-run: each row's
 * Firestore doc id is derived from its content, so re-importing the same
 * row upserts rather than duplicating it.
 */
const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");
const crypto = require("crypto");
const { parse } = require("csv-parse/sync");

const serviceAccount = require(path.join(__dirname, "..", "service-account.json"));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  storageBucket: "preparationhotspot-92b87.firebasestorage.app",
});
const db = admin.firestore();

const REQUIRED_COLUMNS = [
  "exam", "subject", "chapter", "topic", "difficulty", "question",
  "option_a", "option_b", "option_c", "option_d", "correct_answer",
  "explanation", "marks", "negative_marks", "source", "year",
];
const DIFFICULTIES = ["easy", "medium", "hard"];
const ANSWER_KEYS = ["a", "b", "c", "d"];

function slugify(text) {
  return String(text)
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "");
}

const IMPORT_STRING_COLUMNS = [
  "subject", "chapter", "topic", "question",
  "option_a", "option_b", "option_c", "option_d", "explanation", "source",
];

/** Repairs "mojibake" -- UTF-8 text that got decoded as Latin-1 and
 * re-encoded, turning e.g. "²" into "Â²" or "μ" into "Î¼". Common when a
 * spreadsheet/CSV passes through a tool with the wrong encoding assumption.
 * Only applies the fix when it round-trips cleanly; otherwise leaves the
 * original text untouched rather than risking further corruption. */
function fixMojibake(text) {
  if (typeof text !== "string" || text.length === 0) return text;
  try {
    const reencoded = Buffer.from(text, "latin1").toString("utf8");
    if (reencoded.includes("�")) return text; // invalid byte sequence -- not mojibake
    return reencoded;
  } catch {
    return text;
  }
}

function cleanRow(row) {
  const cleaned = { ...row };
  for (const col of IMPORT_STRING_COLUMNS) {
    if (cleaned[col] != null) cleaned[col] = fixMojibake(cleaned[col]);
  }
  return cleaned;
}

function validateRow(row, rowNumber, examSlugs) {
  const errors = [];
  for (const col of REQUIRED_COLUMNS) {
    if (!row[col] || String(row[col]).trim() === "") {
      errors.push(`missing "${col}"`);
    }
  }
  if (errors.length > 0) return errors; // no point checking further

  const examSlug = slugify(row.exam);
  if (!examSlugs.has(examSlug)) {
    errors.push(`unknown exam "${row.exam}" (no published exam with slug "${examSlug}")`);
  }

  const difficulty = row.difficulty.trim().toLowerCase();
  if (!DIFFICULTIES.includes(difficulty)) {
    errors.push(`difficulty must be one of ${DIFFICULTIES.join("/")}, got "${row.difficulty}"`);
  }

  const correctAnswer = row.correct_answer.trim().toLowerCase();
  if (!ANSWER_KEYS.includes(correctAnswer)) {
    errors.push(`correct_answer must be one of ${ANSWER_KEYS.join("/")}, got "${row.correct_answer}"`);
  }

  if (Number.isNaN(Number(row.marks))) errors.push(`marks is not a number: "${row.marks}"`);
  if (Number.isNaN(Number(row.negative_marks))) {
    errors.push(`negative_marks is not a number: "${row.negative_marks}"`);
  }
  if (row.year && Number.isNaN(Number(row.year))) errors.push(`year is not a number: "${row.year}"`);

  return errors;
}

function toQuestionDoc(row) {
  const subjectId = slugify(row.subject);
  const chapterId = slugify(row.chapter);
  const topicId = slugify(row.topic);
  const options = [
    { key: "A", text: row.option_a.trim() },
    { key: "B", text: row.option_b.trim() },
    { key: "C", text: row.option_c.trim() },
    { key: "D", text: row.option_d.trim() },
  ];
  const correctKey = row.correct_answer.trim().toUpperCase();

  // Deterministic id -- re-importing the same row upserts instead of
  // creating a duplicate question.
  const id = "imp_" + crypto
    .createHash("sha1")
    .update([slugify(row.exam), subjectId, chapterId, topicId, row.question.trim()].join("|"))
    .digest("hex")
    .slice(0, 24);

  return {
    id,
    data: {
      examId: slugify(row.exam),
      subjectId,
      subjectName: row.subject.trim(),
      chapterId,
      chapterName: row.chapter.trim(),
      topicId,
      topicName: row.topic.trim(),
      questionType: "single_choice",
      difficulty: row.difficulty.trim().toLowerCase(),
      questionText: row.question.trim(),
      questionImage: null,
      options,
      correctAnswer: correctKey,
      explanation: row.explanation.trim(),
      marks: Number(row.marks),
      negativeMarks: Number(row.negative_marks),
      source: row.source.trim(),
      year: row.year ? Number(row.year) : null,
      status: "published",
    },
  };
}

async function run() {
  const filePath = process.argv[2];
  if (!filePath) {
    console.error("Usage: node scripts/bulk-import-questions.js path/to/questions.csv");
    process.exit(1);
  }
  const resolvedPath = path.resolve(filePath);
  if (!fs.existsSync(resolvedPath)) {
    console.error(`File not found: ${resolvedPath}`);
    process.exit(1);
  }

  const csvContent = fs.readFileSync(resolvedPath, "utf-8");
  const rawRows = parse(csvContent, { columns: true, skip_empty_lines: true, trim: true });
  const rows = rawRows.map(cleanRow);

  if (rows.length === 0) {
    console.error("CSV has no data rows.");
    process.exit(1);
  }

  const examsSnap = await db.collection("exams").where("status", "==", "published").get();
  const examSlugs = new Set(examsSnap.docs.map((d) => d.id));
  if (examSlugs.size === 0) {
    console.error("No published exams found -- seed exams first (scripts/seed-exams.js).");
    process.exit(1);
  }

  const validRows = [];
  const failedRows = [];

  rows.forEach((row, index) => {
    const rowNumber = index + 2; // +1 for header, +1 for 1-indexing
    const errors = validateRow(row, rowNumber, examSlugs);
    if (errors.length > 0) {
      failedRows.push({ rowNumber, errors });
    } else {
      validRows.push({ rowNumber, row });
    }
  });

  console.log(`Parsed ${rows.length} rows: ${validRows.length} valid, ${failedRows.length} failed.`);

  if (failedRows.length > 0) {
    console.log("\nFailed rows (not imported):");
    for (const { rowNumber, errors } of failedRows) {
      console.log(`  Row ${rowNumber}: ${errors.join("; ")}`);
    }
  }

  if (validRows.length === 0) {
    console.log("\nNothing to import.");
    process.exit(failedRows.length > 0 ? 1 : 0);
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  let batch = db.batch();
  let opCount = 0;

  for (const { row } of validRows) {
    const { id, data } = toQuestionDoc(row);
    batch.set(db.collection("questions").doc(id), { ...data, createdAt: now, updatedAt: now }, { merge: true });
    opCount++;
    if (opCount >= 400) {
      await batch.commit();
      batch = db.batch();
      opCount = 0;
    }
  }
  if (opCount > 0) await batch.commit();

  console.log(`\nImported: ${validRows.length}`);
  console.log(`Failed: ${failedRows.length}`);

  await archiveSourceFile(resolvedPath);

  process.exit(failedRows.length > 0 ? 1 : 0);
}

/** Keeps a record of what was imported and when, under Storage's
 * admin-only /uploads/ folder (§47) -- for audit purposes only, the app
 * never reads these back. */
async function archiveSourceFile(resolvedPath) {
  const timestamp = new Date().toISOString().replace(/[:.]/g, "-");
  const destination = `uploads/question-imports/${timestamp}-${path.basename(resolvedPath)}`;
  try {
    await admin.storage().bucket().upload(resolvedPath, { destination });
    console.log(`Archived source file to gs://${admin.storage().bucket().name}/${destination}`);
  } catch (err) {
    console.warn(`Warning: could not archive source CSV to Storage: ${err.message}`);
  }
}

run().catch((err) => {
  console.error("Import failed:", err);
  process.exit(1);
});
