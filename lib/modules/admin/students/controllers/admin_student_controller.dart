import 'package:get/get.dart';

import '../../../../core/utils/app_failure.dart';
import '../../../../data/models/app_user_model.dart';
import '../../../../data/models/exam_model.dart';
import '../../../../data/repositories/admin_student_repository.dart';
import '../../../../data/repositories/exam_repository.dart';

enum AdminStudentStatus { loading, loaded, error }

/// §40: student roster + entry point into each student's performance
/// (reuses [PerformanceRepository] the same way the student app's own
/// "My Performance" screen does).
class AdminStudentController extends GetxController {
  final AdminStudentRepository _studentRepository;
  final ExamRepository _examRepository;

  AdminStudentController({
    AdminStudentRepository? studentRepository,
    ExamRepository? examRepository,
  })  : _studentRepository = studentRepository ?? AdminStudentRepository(),
        _examRepository = examRepository ?? ExamRepository();

  final status = AdminStudentStatus.loading.obs;
  final errorMessage = RxnString();
  final students = <AppUserModel>[].obs;
  final exams = <ExamModel>[].obs;
  final searchText = ''.obs;

  List<AppUserModel> get filteredStudents {
    final q = searchText.value.toLowerCase();
    if (q.isEmpty) return students;
    return students
        .where((s) =>
            s.fullName.toLowerCase().contains(q) || s.email.toLowerCase().contains(q))
        .toList();
  }

  String examName(String? examId) {
    if (examId == null) return '-';
    return exams.where((e) => e.id == examId).firstOrNull?.name ?? examId;
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      status.value = AdminStudentStatus.loading;
      final results = await Future.wait([
        _studentRepository.fetchStudents(),
        _examRepository.fetchPublishedExams(),
      ]);
      students.assignAll(results[0] as List<AppUserModel>);
      exams.assignAll(results[1] as List<ExamModel>);
      status.value = AdminStudentStatus.loaded;
    } catch (e) {
      errorMessage.value = AppFailure.from(e).friendlyMessage;
      status.value = AdminStudentStatus.error;
    }
  }
}
