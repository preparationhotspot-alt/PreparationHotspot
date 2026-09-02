/**
 * One-off admin script to seed the initial exam catalog (§7-8 of the
 * architecture doc). Run with a service account key locally:
 *   node scripts/seed-exams.js
 *
 * This is NOT deployed as a Cloud Function -- it's a local admin utility.
 * Re-running it is safe: it upserts by a fixed slug-based doc id.
 */
const admin = require("firebase-admin");
const path = require("path");

const serviceAccount = require(path.join(__dirname, "..", "service-account.json"));

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();

const exams = [
  {
    id: "jee-main",
    name: "JEE Main",
    slug: "jee-main",
    description: "Joint Entrance Examination for engineering admissions.",
    icon: "jee_main",
    status: "published",
    displayOrder: 1,
  },
  {
    id: "jee-advanced",
    name: "JEE Advanced",
    slug: "jee-advanced",
    description: "Entrance exam for admission to the IITs.",
    icon: "jee_advanced",
    status: "published",
    displayOrder: 2,
  },
  {
    id: "mht-cet",
    name: "MHT-CET",
    slug: "mht-cet",
    description: "Maharashtra Common Entrance Test for engineering/pharmacy.",
    icon: "mht_cet",
    status: "published",
    displayOrder: 3,
  },
];

async function seed() {
  const batch = db.batch();
  const now = admin.firestore.FieldValue.serverTimestamp();

  for (const exam of exams) {
    const ref = db.collection("exams").doc(exam.id);
    batch.set(
      ref,
      {
        name: exam.name,
        slug: exam.slug,
        description: exam.description,
        icon: exam.icon,
        status: exam.status,
        displayOrder: exam.displayOrder,
        createdAt: now,
        updatedAt: now,
      },
      { merge: true }
    );
  }

  await batch.commit();
  console.log(`Seeded ${exams.length} exams.`);
  process.exit(0);
}

seed().catch((err) => {
  console.error("Seed failed:", err);
  process.exit(1);
});
