import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../data/models/app_user_model.dart';
import '../controllers/admin_student_controller.dart';
import 'student_detail_dialog.dart';

class AdminStudentView extends GetView<AdminStudentController> {
  const AdminStudentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Students', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: Icon(Icons.search, size: 20),
              ),
              onChanged: (v) => controller.searchText.value = v,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                switch (controller.status.value) {
                  case AdminStudentStatus.loading:
                    return const AppLoadingView(message: 'Loading students...');
                  case AdminStudentStatus.error:
                    return AppErrorView(
                      message: controller.errorMessage.value ?? 'Something went wrong.',
                      onRetry: controller.load,
                    );
                  case AdminStudentStatus.loaded:
                    final list = controller.filteredStudents;
                    if (list.isEmpty) {
                      return const Center(child: Text('No students found.'));
                    }
                    return SingleChildScrollView(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Email')),
                            DataColumn(label: Text('Exam')),
                            DataColumn(label: Text('Target Year')),
                            DataColumn(label: Text('Questions')),
                            DataColumn(label: Text('Tests')),
                            DataColumn(label: Text('Accuracy')),
                          ],
                          rows: list
                              .map((student) => _studentRow(student, controller))
                              .toList(),
                        ),
                      ),
                    );
                }
              }),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _studentRow(AppUserModel student, AdminStudentController controller) {
    return DataRow(
      onSelectChanged: (_) =>
          showStudentDetailDialog(student, controller.examName(student.selectedExamId)),
      cells: [
        DataCell(Text(student.fullName)),
        DataCell(Text(student.email)),
        DataCell(Text(controller.examName(student.selectedExamId))),
        DataCell(Text('${student.targetExamYear ?? "-"}')),
        DataCell(Text('${student.questionsAttempted}')),
        DataCell(Text('${student.testsAttempted}')),
        DataCell(Text(
          '${student.overallAccuracy.toStringAsFixed(0)}%',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: student.overallAccuracy >= 71
                ? AppColors.strong
                : student.overallAccuracy >= 41
                    ? AppColors.average
                    : AppColors.weak,
          ),
        )),
      ],
    );
  }
}
