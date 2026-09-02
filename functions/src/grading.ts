import { QuestionDoc, SubmittedAnswer } from "./types";

/** Server-side answer grading (§10-§11) -- the client never sees this logic
 * or the correct answers, so scores can't be forged by a modified client. */
export function gradeAnswer(
  question: QuestionDoc,
  submitted: SubmittedAnswer | undefined
): { isCorrect: boolean; isAnswered: boolean; marksAwarded: number } {
  const selected = submitted?.selectedAnswer ?? null;
  const isAnswered = selected !== null && selected !== undefined &&
    !(Array.isArray(selected) && selected.length === 0) &&
    !(typeof selected === "string" && selected.trim() === "");

  if (!isAnswered) {
    return { isCorrect: false, isAnswered: false, marksAwarded: 0 };
  }

  const isCorrect = checkCorrectness(question, selected as string | string[]);
  const marksAwarded = isCorrect ? question.marks : -Math.abs(question.negativeMarks);
  return { isCorrect, isAnswered: true, marksAwarded };
}

function checkCorrectness(question: QuestionDoc, selected: string | string[]): boolean {
  switch (question.questionType) {
    case "multiple_choice": {
      const correct = (Array.isArray(question.correctAnswer)
        ? question.correctAnswer
        : [question.correctAnswer]
      ).map(String).sort();
      const given = (Array.isArray(selected) ? selected : [selected]).map(String).sort();
      return correct.length === given.length && correct.every((v, i) => v === given[i]);
    }
    case "numerical": {
      const correctNum = Number(
        Array.isArray(question.correctAnswer) ? question.correctAnswer[0] : question.correctAnswer
      );
      const givenNum = Number(Array.isArray(selected) ? selected[0] : selected);
      if (Number.isNaN(correctNum) || Number.isNaN(givenNum)) return false;
      const tolerance = question.tolerance ?? 0;
      return Math.abs(correctNum - givenNum) <= tolerance;
    }
    case "single_choice":
    case "true_false":
    case "integer":
    default: {
      const correct = String(
        Array.isArray(question.correctAnswer) ? question.correctAnswer[0] : question.correctAnswer
      ).trim();
      const given = String(Array.isArray(selected) ? selected[0] : selected).trim();
      return correct === given;
    }
  }
}
