/**
 * Grants (or revokes) the `admin` custom claim used by firestore.rules'
 * isAdmin() and by the admin panel's login gate. Custom claims can only be
 * set via the Admin SDK -- there is no client-side or console UI for this.
 *
 * Usage:
 *   node scripts/set-admin-claim.js someone@example.com        # grant
 *   node scripts/set-admin-claim.js someone@example.com --revoke
 *
 * The user must sign out and back in (or force-refresh their ID token)
 * before the new claim takes effect on the client.
 */
const admin = require("firebase-admin");
const path = require("path");

const serviceAccount = require(path.join(__dirname, "..", "service-account.json"));
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });

async function run() {
  const email = process.argv[2];
  const revoke = process.argv.includes("--revoke");

  if (!email) {
    console.error("Usage: node scripts/set-admin-claim.js <email> [--revoke]");
    process.exit(1);
  }

  const user = await admin.auth().getUserByEmail(email);
  await admin.auth().setCustomUserClaims(user.uid, revoke ? {} : { admin: true });

  console.log(
    revoke
      ? `Revoked admin claim from ${email} (${user.uid}).`
      : `Granted admin claim to ${email} (${user.uid}).`
  );
  console.log("They must sign out and back in for this to take effect.");
  process.exit(0);
}

run().catch((err) => {
  console.error("Failed to set admin claim:", err);
  process.exit(1);
});
