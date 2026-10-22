import 'package:aula360/features/teacher_all/homework/data/dtos/teacher_homework_dto.dart';

abstract class TeacherHomeworkRepository {
  Future<TeacherHomeworkDto> createHomework(CreateHomeworkRequestDto payload);
  Future<List<TeacherHomeworkDto>> getHomework({String? cohortId});
  Future<HomeworkSubmissionDto> markHomeworkSubmission(
    String homeworkId,
    String studentId,
    MarkHomeworkSubmissionRequestDto payload,
  );
}
