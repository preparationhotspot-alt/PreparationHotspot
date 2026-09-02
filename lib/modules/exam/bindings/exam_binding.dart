import 'package:get/get.dart';
import '../controllers/exam_selection_controller.dart';
import '../controllers/student_profile_controller.dart';

class ExamBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ExamSelectionController>(() => ExamSelectionController());
    Get.lazyPut<StudentProfileController>(() => StudentProfileController());
  }
}
