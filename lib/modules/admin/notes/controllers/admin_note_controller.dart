import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../data/models/exam_model.dart';
import '../../../../data/models/note_model.dart';
import '../../../../data/repositories/exam_repository.dart';
import '../../../../data/repositories/note_repository.dart';

class AdminNoteController extends GetxController {
  final NoteRepository _noteRepository;
  final ExamRepository _examRepository;

  AdminNoteController({NoteRepository? noteRepository, ExamRepository? examRepository})
      : _noteRepository = noteRepository ?? NoteRepository(),
        _examRepository = examRepository ?? ExamRepository();

  final exams = <ExamModel>[].obs;
  final notes = <NoteModel>[].obs;
  final selectedExamId = RxnString();
  final isLoading = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadExams();
    _noteRepository.watchNotes().listen((list) {
      notes.assignAll(list);
      isLoading.value = false;
    });
  }

  Future<void> _loadExams() async {
    exams.assignAll(await _examRepository.fetchPublishedExams());
  }

  List<NoteModel> get filteredNotes {
    final examId = selectedExamId.value;
    if (examId == null || examId.isEmpty) return notes;
    return notes.where((n) => n.examId == examId).toList();
  }

  Future<bool> saveNote(String? existingId, Map<String, dynamic> data) async {
    try {
      isSaving.value = true;
      if (existingId == null) {
        await _noteRepository.createNote(data);
      } else {
        await _noteRepository.updateNote(existingId, data);
      }
      return true;
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Could not save note');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStatus(NoteModel note) async {
    final newStatus = note.status == 'published' ? 'draft' : 'published';
    try {
      await _noteRepository.setStatus(note.id, newStatus);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }

  Future<void> deleteNote(NoteModel note) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Delete "${note.title}"?',
      message: 'This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await _noteRepository.deleteNote(note.id);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }
}
