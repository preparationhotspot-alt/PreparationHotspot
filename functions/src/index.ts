import * as admin from "firebase-admin";

admin.initializeApp();

// Function implementations are added phase by phase, matching the
// Development Roadmap (generateRecommendedPractice lands with the Phase 7
// Practice module -- it has no consumer to serve until then).
export { helloWorld } from "./health";
export { generateDiagnosticAssessment, submitDiagnosticAssessment } from "./assessment";
export { regenerateStudyPlan } from "./studyPlan";
