/** Shared server-side types for the assessment & performance engines (§9-§17). */

export type QuestionType =
  | "single_choice"
  | "multiple_choice"
  | "numerical"
  | "integer"
  | "true_false";

export interface QuestionOption {
  key: string;
  text: string;
}

export interface QuestionDoc {
  examId: string;
  subjectId: string;
  subjectName: string;
  chapterId: string;
  chapterName: string;
  topicId: string;
  topicName: string;
  questionType: QuestionType;
  difficulty: "easy" | "medium" | "hard";
  questionText: string;
  questionImage?: string | null;
  options?: QuestionOption[];
  /** string for single_choice/true_false/integer/numerical, string[] for multiple_choice */
  correctAnswer: string | string[];
  /** numerical questions only: acceptable +/- tolerance around correctAnswer */
  tolerance?: number;
  explanation?: string;
  marks: number;
  negativeMarks: number;
  source?: string;
  year?: number;
  status: "published" | "draft";
}

/** One rule from diagnostic_config: "give me N questions matching this shape". */
export interface DistributionRule {
  subjectId: string;
  chapterId?: string;
  topicId?: string;
  difficulty?: "easy" | "medium" | "hard";
  count: number;
}

export interface DiagnosticConfigDoc {
  examId: string;
  totalQuestions: number;
  durationMinutes: number;
  distribution: DistributionRule[];
}

/** Question shape sent to the client -- answers/explanations stripped (§30). */
export interface SanitizedQuestion {
  questionId: string;
  subjectId: string;
  subjectName: string;
  chapterId: string;
  chapterName: string;
  topicId: string;
  topicName: string;
  questionType: QuestionType;
  difficulty: string;
  questionText: string;
  questionImage?: string | null;
  options?: QuestionOption[];
  marks: number;
  negativeMarks: number;
}

export interface SubmittedAnswer {
  questionId: string;
  selectedAnswer: string | string[] | null;
  timeTaken: number;
}

export interface GradedAnswer {
  questionId: string;
  selectedAnswer: string | string[] | null;
  correctAnswer: string | string[];
  isCorrect: boolean;
  isAnswered: boolean;
  timeTaken: number;
  marksAwarded: number;
  subjectId: string;
  subjectName: string;
  chapterId: string;
  chapterName: string;
  topicId: string;
  topicName: string;
}

export type PerformanceStatus = "weak" | "average" | "strong" | "insufficient_data";

export interface PerformanceRules {
  weakMax: number;
  averageMax: number;
  minAttemptsForStatus: number;
}

export const DEFAULT_PERFORMANCE_RULES: PerformanceRules = {
  weakMax: 40,
  averageMax: 70,
  minAttemptsForStatus: 3,
};

export type StudyPlanPriority = "high" | "medium" | "low";
export type StudyPlanItemStatus = "pending" | "in_progress" | "completed";
export type RecommendedAction = "learning_practice" | "practice" | "revision";

/** One row of `study_plans/{planId}/items` (§16) -- always derived purely
 * from `user_performance`, per the §17 rule-based engine (no AI). */
export interface StudyPlanItem {
  subjectId: string;
  subjectName: string;
  chapterId: string;
  chapterName: string;
  topicId: string;
  topicName: string;
  priority: StudyPlanPriority;
  reason: string;
  accuracy: number;
  recommendedQuestions: number;
  recommendedDifficulty: "easy" | "medium" | "hard" | "mixed";
  recommendedAction: RecommendedAction;
  status: StudyPlanItemStatus;
}
