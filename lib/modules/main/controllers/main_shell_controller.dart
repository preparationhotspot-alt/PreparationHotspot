import 'package:get/get.dart';

/// Drives the 5-tab bottom navigation shell (§27): Home, Prepare, Practice,
/// Performance, Profile. Tab bodies are kept alive via IndexedStack so
/// switching tabs doesn't re-fetch data each time.
class MainShellController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) => currentIndex.value = index;
}
