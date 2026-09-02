import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../data/models/exam_model.dart';
import '../../../../data/repositories/exam_repository.dart';

/// §33: full CRUD over `exams` -- the admin can add a new exam without any
/// Flutter code changes shipping to students, per the spec's core promise.
class AdminExamController extends GetxController {
  final ExamRepository _examRepository;
  AdminExamController({ExamRepository? examRepository})
      : _examRepository = examRepository ?? ExamRepository();

  final exams = <ExamModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _examRepository.watchAllExams().listen((list) {
      exams.assignAll(list);
      isLoading.value = false;
    });
  }

  String slugify(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-|-$)'), '');
  }

  Future<bool> createExam({
    required String name,
    required String description,
    String? icon,
    required int displayOrder,
  }) async {
    final slug = slugify(name);
    if (slug.isEmpty) {
      AppDialogs.error('Please enter a valid exam name.');
      return false;
    }
    try {
      isSaving.value = true;
      await _examRepository.createExam(
        id: slug,
        name: name,
        slug: slug,
        description: description,
        icon: icon,
        displayOrder: displayOrder,
      );
      return true;
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Could not create exam');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<bool> updateExam(
    String examId, {
    required String name,
    required String description,
    String? icon,
    required int displayOrder,
  }) async {
    try {
      isSaving.value = true;
      await _examRepository.updateExam(
        examId,
        name: name,
        description: description,
        icon: icon,
        displayOrder: displayOrder,
      );
      return true;
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage, title: 'Could not update exam');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> toggleStatus(ExamModel exam) async {
    final newStatus = exam.status == 'published' ? 'draft' : 'published';
    try {
      await _examRepository.setExamStatus(exam.id, newStatus);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }

  Future<void> deleteExam(ExamModel exam) async {
    final confirmed = await AppDialogs.confirm(
      title: 'Delete "${exam.name}"?',
      message: 'This does not delete its questions or content -- only the '
          'exam listing itself. This cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (!confirmed) return;
    try {
      await _examRepository.deleteExam(exam.id);
    } catch (e) {
      AppDialogs.error(AppFailure.from(e).friendlyMessage);
    }
  }
}
