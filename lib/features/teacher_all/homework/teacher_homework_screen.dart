import 'package:intl/intl.dart';

import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import 'data/dtos/teacher_homework_dto.dart';
import 'presentation/controllers/teacher_homework_controller.dart';
import 'presentation/providers/teacher_homework_providers.dart';

class TeacherHomeworkScreen extends ConsumerStatefulWidget {
  const TeacherHomeworkScreen({super.key});

  @override
  ConsumerState<TeacherHomeworkScreen> createState() => _TeacherHomeworkScreenState();
}

class _TeacherHomeworkScreenState extends ConsumerState<TeacherHomeworkScreen> {
  String? _selectedCohortId;

  @override
  Widget build(BuildContext context) {
    final homeworkAsync = ref.watch(teacherHomeworkListProvider(_selectedCohortId));

    return Scaffold(
      backgroundColor: AppColors.softBackground,
      appBar: AulaAppBar(
        title: 'Tareas',
        showBack: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryDark, size: 24.sp),
            tooltip: 'Nueva Tarea',
            onPressed: () => _openCreateHomeworkSheet(context),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primaryDark,
          onRefresh: () async {
            ref.invalidate(teacherHomeworkListProvider(_selectedCohortId));
          },
          child: homeworkAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline_rounded, color: AppColors.error, size: 48.sp),
                    SizedBox(height: 12.h),
                    Text(
                      'Error al cargar tareas',
                      style: TxtStyle.titleLarge(fontSize: 18.sp, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      err.toString(),
                      textAlign: TextAlign.center,
                      style: TxtStyle.bodyMedium(color: AppColors.subtitleTextColor, fontSize: 13.sp),
                    ),
                    SizedBox(height: 16.h),
                    AulaPrimaryButton(
                      text: 'Reintentar',
                      onTap: () => ref.invalidate(teacherHomeworkListProvider(_selectedCohortId)),
                    ),
                  ],
                ),
              ),
            ),
            data: (homeworkList) {
              if (homeworkList.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                itemCount: homeworkList.length,
                separatorBuilder: (_, _) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = homeworkList[index];
                  return _buildHomeworkCard(context, item);
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryDark,
        onPressed: () => _openCreateHomeworkSheet(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nueva Tarea',
          style: TxtStyle.titleMedium(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        SizedBox(height: 100.h),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assignment_outlined, color: AppColors.primaryDark, size: 36.sp),
              ),
              SizedBox(height: 16.h),
              Text(
                'No hay tareas asignadas',
                style: TxtStyle.titleLarge(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Text(
                'Crea una nueva tarea para tus alumnos pulsando el botón inferior.',
                textAlign: TextAlign.center,
                style: TxtStyle.bodyMedium(color: AppColors.subtitleTextColor, fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              AulaPrimaryButton(
                text: 'Asignar Tarea',
                onTap: () => _openCreateHomeworkSheet(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeworkCard(BuildContext context, TeacherHomeworkDto item) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  item.subjectName.isNotEmpty ? item.subjectName : 'Matemáticas',
                  style: TxtStyle.labelLarge(
                    color: AppColors.primaryDark,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F7),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 14.sp, color: AppColors.subtitleTextColor),
                    SizedBox(width: 4.w),
                    Text(
                      '${item.submissionsCount} entregas',
                      style: TxtStyle.bodyMedium(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            item.title,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (item.description != null && item.description!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              item.description!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TxtStyle.bodyMedium(
                color: AppColors.subtitleTextColor,
                fontSize: 13.5.sp,
                height: 1.35,
              ),
            ),
          ],
          SizedBox(height: 12.h),
          Divider(color: AppColors.backgroundsLinesColor, height: 1),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 13.sp, color: AppColors.subtitleTextColor),
              SizedBox(width: 4.w),
              Text(
                'Entrega: ${_formatDate(item.dueDate)}',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () => _openMarkSubmissionDialog(context, item),
                child: Text(
                  'Calificar',
                  style: TxtStyle.titleMedium(
                    color: AppColors.primaryDark,
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    if (isoDate.isEmpty) return 'Próximamente';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('d MMM, yyyy').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  void _openCreateHomeworkSheet(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final cohortController = TextEditingController(text: 'Cohort-1');
    final subjectController = TextEditingController(text: 'Subject-1');
    DateTime selectedDueDate = DateTime.now().add(const Duration(days: 7));

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20.w,
                right: 20.w,
                top: 20.h,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Crear Nueva Tarea',
                          style: TxtStyle.titleLarge(fontSize: 19.sp, fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Título de la tarea',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    TextField(
                      controller: descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Instrucciones / Descripción',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: cohortController,
                            decoration: InputDecoration(
                              labelText: 'Cohorte / Grupo',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TextField(
                            controller: subjectController,
                            decoration: InputDecoration(
                              labelText: 'ID Asignatura',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.event_outlined, color: AppColors.primaryDark),
                      title: Text(
                        'Fecha límite: ${DateFormat('d MMM, yyyy').format(selectedDueDate)}',
                        style: TxtStyle.bodyMedium(fontSize: 14.sp, fontWeight: FontWeight.w600),
                      ),
                      trailing: TextButton(
                        child: const Text('Cambiar'),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: sheetContext,
                            initialDate: selectedDueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (picked != null) {
                            setSheetState(() => selectedDueDate = picked);
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Consumer(
                      builder: (ctx, innerRef, _) {
                        final actionState = innerRef.watch(teacherHomeworkControllerProvider);
                        return SizedBox(
                          width: double.infinity,
                          child: AulaPrimaryButton(
                            text: 'Publicar Tarea',
                            isLoading: actionState.isLoading,
                            onTap: () async {
                              if (titleController.text.trim().isEmpty) return;
                              final success = await innerRef
                                  .read(teacherHomeworkControllerProvider.notifier)
                                  .createHomework(
                                    cohortId: cohortController.text.trim(),
                                    subjectId: subjectController.text.trim(),
                                    title: titleController.text.trim(),
                                    description: descriptionController.text.trim().isEmpty
                                        ? null
                                        : descriptionController.text.trim(),
                                    startDate: DateTime.now(),
                                    dueDate: selectedDueDate,
                                  );
                              if (success && sheetContext.mounted) {
                                Navigator.of(sheetContext).pop();
                                innerRef.invalidate(teacherHomeworkListProvider(_selectedCohortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Tarea creada exitosamente')),
                                );
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openMarkSubmissionDialog(BuildContext context, TeacherHomeworkDto item) {
    final noteController = TextEditingController();
    String selectedStatus = 'COMPLETED';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                'Calificar Entrega',
                style: TxtStyle.titleLarge(fontSize: 18.sp, fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarea: ${item.title}',
                    style: TxtStyle.bodyMedium(fontSize: 14.sp, color: AppColors.subtitleTextColor),
                  ),
                  SizedBox(height: 14.h),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Estado',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'COMPLETED', child: Text('Completada')),
                      DropdownMenuItem(value: 'NEEDS_REVISION', child: Text('Requiere Revisión')),
                    ],
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedStatus = val);
                    },
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: noteController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Comentario / Nota',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancelar'),
                ),
                Consumer(
                  builder: (ctx, innerRef, _) {
                    final actionState = innerRef.watch(teacherHomeworkControllerProvider);
                    return TextButton(
                      onPressed: actionState.isLoading
                          ? null
                          : () async {
                              final success = await innerRef
                                  .read(teacherHomeworkControllerProvider.notifier)
                                  .markHomeworkSubmission(
                                    homeworkId: item.id.isNotEmpty ? item.id : 'hw-1',
                                    studentId: 'student-1',
                                    status: selectedStatus,
                                    note: noteController.text.trim().isEmpty
                                        ? null
                                        : noteController.text.trim(),
                                  );
                              if (dialogContext.mounted) {
                                Navigator.of(dialogContext).pop();
                                innerRef.invalidate(teacherHomeworkListProvider(_selectedCohortId));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Entrega calificada exitosamente'
                                          : 'No se pudo actualizar entrega',
                                    ),
                                  ),
                                );
                              }
                            },
                      child: Text(
                        'Guardar',
                        style: TxtStyle.titleMedium(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
