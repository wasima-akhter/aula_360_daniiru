/// ===============================================================
/// MODELS (PARENT FEATURE)
/// ===============================================================
library;

class ChildModel {
  final String id;
  final String name;
  final String grade;
  final String room;
  final String imageUrl;
  final String parentTeacher;
  final double attendance;
  final int present;
  final int absent;
  final int late;

  const ChildModel({
    required this.id,
    required this.name,
    required this.grade,
    required this.room,
    required this.imageUrl,
    required this.parentTeacher,
    required this.attendance,
    required this.present,
    required this.absent,
    required this.late,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE / MOCK DATA (Spanish Academy Context)
// ─────────────────────────────────────────────────────────────────────────────

const ChildModel lucasChild = ChildModel(
  id: '#STU-4821',
  name: 'Lucas Rivera',
  grade: '2º ESO',
  room: 'Aula 3B',
  imageUrl:
      'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
  parentTeacher: 'Dña. Sarah Vance (Tutora)',
  attendance: 96,
  present: 48,
  absent: 2,
  late: 1,
);

const ChildModel sophiaChild = ChildModel(
  id: '#STU-5298',
  name: 'Sophia Rivera',
  grade: '5º Primaria',
  room: 'Aula 1A',
  imageUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
  parentTeacher: 'D. David Miller (Tutor)',
  attendance: 98,
  present: 49,
  absent: 1,
  late: 0,
);
