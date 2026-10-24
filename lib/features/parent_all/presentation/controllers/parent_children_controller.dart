import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/dtos/add_child_dto.dart';
import '../../data/repositories/parent_repository_impl.dart';
import '../../domain/models/parent_models.dart';
import '../../domain/repositories/parent_repository.dart';
import 'parent_home_controller.dart';

class ParentChildrenState {
  final List<ChildModel> children;
  final ChildModel? selectedChild;
  final bool isLoading;
  final String? error;

  const ParentChildrenState({
    this.children = const [],
    this.selectedChild,
    this.isLoading = false,
    this.error,
  });

  ParentChildrenState copyWith({
    List<ChildModel>? children,
    ChildModel? selectedChild,
    bool? isLoading,
    String? error,
  }) {
    return ParentChildrenState(
      children: children ?? this.children,
      selectedChild: selectedChild ?? this.selectedChild,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final parentChildrenControllerProvider =
    NotifierProvider<ParentChildrenController, ParentChildrenState>(
      ParentChildrenController.new,
    );

class ParentChildrenController extends Notifier<ParentChildrenState> {
  ParentRepository get _repository => ref.read(parentRepositoryProvider);

  @override
  ParentChildrenState build() {
    Future.microtask(() => loadChildren());
    return const ParentChildrenState(isLoading: true);
  }

  Future<void> loadChildren() async {
    try {
      final children = await _repository.getChildren();
      final currentId = state.selectedChild?.id;
      ChildModel? activeChild;
      if (children.isNotEmpty) {
        if (currentId != null) {
          activeChild = children.firstWhere(
            (c) => c.id == currentId,
            orElse: () => children.first,
          );
        } else {
          activeChild = children.first;
        }
      }
      state = state.copyWith(
        children: children,
        selectedChild: activeChild,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectChild(ChildModel child) {
    state = state.copyWith(selectedChild: child);
    ref.read(parentHomeControllerProvider.notifier).selectChild(child);
  }

  Future<bool> addChild({
    required String name,
    String? dob,
    String? gender,
    String? grade,
    String? enrollmentNumber,
    String? avatarUrl,
    File? avatarFile,
    String? room,
    String? parentTeacher,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      String? finalAvatarUrl = avatarUrl;
      if (avatarFile != null) {
        final uploaded = await ref
            .read(uploadMediaUseCaseProvider)
            .call(files: [avatarFile]);
        if (uploaded.isNotEmpty) {
          finalAvatarUrl = uploaded.first;
        }
      }

      final dto = AddChildDto(
        fullName: name,
        dob: dob,
        gender: gender,
        gradeLevel: grade,
        enrollmentNumber: enrollmentNumber,
        avatarUrl: finalAvatarUrl,
      );
      final newChild = await _repository.addChild(dto);
      final updated = await _repository.getChildren();
      state = state.copyWith(
        children: updated.isNotEmpty ? updated : [newChild],
        selectedChild: newChild,
        isLoading: false,
        error: null,
      );
      ref.read(parentHomeControllerProvider.notifier).loadDashboardData();
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}
