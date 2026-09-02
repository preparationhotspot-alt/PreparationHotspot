import 'package:get/get.dart';
import '../controllers/assessment_controller.dart';

/// Assessment screens use `Get.offNamed` to move forward through the flow
/// (intro → instructions → question → result → strong/weak areas) without
/// growing the back stack. A plain `lazyPut` would be disposed the moment
/// the previous route is popped, wiping in-progress answers -- so the
/// controller is kept alive for the whole flow and torn down explicitly
/// once the student leaves it (see `AssessmentController.finishAndGoHome`).
class AssessmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AssessmentController>()) {
      Get.put<AssessmentController>(AssessmentController(), permanent: true);
    }
  }
}
