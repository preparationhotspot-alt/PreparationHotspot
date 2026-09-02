import 'package:get/get.dart';
import '../controllers/personalized_plan_controller.dart';

class PersonalizedPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PersonalizedPlanController>(() => PersonalizedPlanController());
  }
}
