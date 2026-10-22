import 'package:intl/intl.dart';

import '../../../parent_all/helper/parent_home_helper.dart';
import '../../../share/export/screen_export.dart';
import '../../domain/entities/legal_content.dart';
import '../controllers/legal_content_controller.dart';

class LegalContentScreen extends ConsumerStatefulWidget {
  final LegalContentType type;

  const LegalContentScreen({
    super.key,
    required this.type,
  });

  @override
  ConsumerState<LegalContentScreen> createState() => _LegalContentScreenState();
}

class _LegalContentScreenState extends ConsumerState<LegalContentScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final map = ref.read(legalContentControllerProvider);
      final current = map[widget.type];
      if (current == null || current.status == LegalContentStatus.initial) {
        ref
            .read(legalContentControllerProvider.notifier)
            .fetchContent(widget.type);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final map = ref.watch(legalContentControllerProvider);
    final state = map[widget.type] ??
        const LegalContentState(status: LegalContentStatus.loading);
    final controller = ref.read(legalContentControllerProvider.notifier);
    final langCode =
        ref.watch(languageProvider).valueOrNull?.language.code ?? 'en';
    final tr = ref.watchTr;
    final screenTitle = widget.type.localizedTitle(langCode);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AulaAppBar(
        title: screenTitle,
        showBack: true,
      ),
      body: SafeArea(
        child: state.showFallback
            ? _buildFallbackContent(context, langCode, tr, controller)
            : _buildContentByStatus(context, state, langCode, tr, controller),
      ),
    );
  }

  Widget _buildContentByStatus(
    BuildContext context,
    LegalContentState state,
    String langCode,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    switch (state.status) {
      case LegalContentStatus.initial:
      case LegalContentStatus.loading:
        return _buildLoadingState(tr);
      case LegalContentStatus.notFound:
        return _buildNotFoundState(context, langCode, tr, controller);
      case LegalContentStatus.offline:
        return _buildOfflineState(context, langCode, tr, controller);
      case LegalContentStatus.serverError:
        return _buildServerErrorState(context, state, tr, controller);
      case LegalContentStatus.genericError:
        return _buildGenericErrorState(context, state, tr, controller);
      case LegalContentStatus.success:
        final content = state.content;
        if (content == null || content.content.trim().isEmpty) {
          return _buildEmptyState(context, tr, controller);
        }
        return _buildDataContent(context, content, langCode, tr, controller);
    }
  }

  Widget _buildLoadingState(String Function(String) tr) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryDark),
          SizedBox(height: 16.h),
          Text(
            tr(AppStrings.legalLoadingDocument),
            style: TxtStyle.bodyMedium(
              color: AppColors.subtitleTextColor,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(
    BuildContext context,
    String langCode,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    final title = widget.type.localizedTitle(langCode);
    final isEs = langCode.startsWith('es');
    final description = isEs
        ? 'El documento oficial de "$title" aún no ha sido publicado en el servidor por la administración de Aula 360.'
        : 'The official document for "$title" has not yet been published on the server by Aula 360 administration.';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.article_outlined,
                  size: 36.sp,
                  color: AppColors.primaryDark,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                tr(AppStrings.legalDocumentInPreparation),
                style: TxtStyle.titleLarge(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                description,
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 26.h),
              // Prominent Retry Button (Single attempt, no auto-retrying)
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  text: tr(AppStrings.retry),
                  onTap: () {
                    controller.retry(widget.type);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    controller.toggleFallback(widget.type, true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    tr(AppStrings.legalViewGeneralInfo),
                    style: TxtStyle.titleMedium(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  tr(AppStrings.back),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: AppColors.softSlateBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  size: 36.sp,
                  color: AppColors.subtitleTextColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                tr(AppStrings.legalNoContentAvailable),
                style: TxtStyle.titleLarge(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                tr(AppStrings.legalNoContentDesc),
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  text: tr(AppStrings.retry),
                  onTap: () {
                    controller.retry(widget.type);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    controller.toggleFallback(widget.type, true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    tr(AppStrings.legalViewGeneralInfo),
                    style: TxtStyle.titleMedium(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  tr(AppStrings.back),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineState(
    BuildContext context,
    String langCode,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: const BoxDecoration(
                  color: AppColors.softSlateBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  size: 36.sp,
                  color: AppColors.subtitleTextColor,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                tr(AppStrings.legalNoInternetTitle),
                style: TxtStyle.titleLarge(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                tr(AppStrings.legalNoInternetDesc),
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  text: tr(AppStrings.retry),
                  onTap: () {
                    controller.retry(widget.type);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    controller.toggleFallback(widget.type, true);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primaryDark,
                      width: 1.5,
                    ),
                    padding: EdgeInsets.symmetric(vertical: 13.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    tr(AppStrings.legalViewSavedInfo),
                    style: TxtStyle.titleMedium(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  tr(AppStrings.back),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.subtitleTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServerErrorState(
    BuildContext context,
    LegalContentState state,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 36.sp,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                tr(AppStrings.legalServerErrorTitle),
                style: TxtStyle.titleLarge(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                '${tr(AppStrings.legalServerErrorDesc)} (${state.statusCode ?? 500})',
                style: TxtStyle.bodyMedium(
                  color: AppColors.subtitleTextColor,
                  fontSize: 14.sp,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.traceId != null && state.traceId!.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.softSlateBgColor,
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    'Trace ID: ${state.traceId}',
                    style: TxtStyle.bodySmall(
                      fontSize: 11.sp,
                      color: AppColors.subtitleTextColor,
                    ),
                  ),
                ),
              ],
              SizedBox(height: 26.h),
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  text: tr(AppStrings.retry),
                  onTap: () {
                    controller.retry(widget.type);
                  },
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  controller.toggleFallback(widget.type, true);
                },
                child: Text(
                  tr(AppStrings.legalViewGeneralInfo),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenericErrorState(
    BuildContext context,
    LegalContentState state,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48.sp,
                color: AppColors.error,
              ),
              SizedBox(height: 16.h),
              Text(
                tr(AppStrings.legalGenericErrorTitle),
                style: TxtStyle.titleLarge(
                  fontWeight: FontWeight.w700,
                  fontSize: 18.sp,
                ),
                textAlign: TextAlign.center,
              ),
              if (state.errorMessage != null &&
                  state.errorMessage!.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  state.errorMessage!,
                  style: TxtStyle.bodySmall(
                    color: AppColors.subtitleTextColor,
                    fontSize: 13.sp,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: AulaPrimaryButton(
                  text: tr(AppStrings.retry),
                  onTap: () => controller.retry(widget.type),
                ),
              ),
              SizedBox(height: 12.h),
              TextButton(
                onPressed: () {
                  controller.toggleFallback(widget.type, true);
                },
                child: Text(
                  tr(AppStrings.legalViewGeneralInfo),
                  style: TxtStyle.bodyMedium(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackContent(
    BuildContext context,
    String langCode,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    final localizedFallbackText =
        widget.type.localizedFallbackContent(langCode);

    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: () async {
        controller.toggleFallback(widget.type, false);
        controller.retry(widget.type);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: AppColors.primaryDark.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.primaryDark,
                    size: 20.sp,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr(AppStrings.legalInstitutionalInfo),
                          style: TxtStyle.titleMedium(
                            color: AppColors.primaryDark,
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          tr(AppStrings.legalInstitutionalNotice),
                          style: TxtStyle.bodySmall(
                            color: AppColors.text,
                            fontSize: 12.5.sp,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            SelectableText(
              localizedFallbackText,
              style: TxtStyle.bodyMedium(
                color: AppColors.text,
                fontSize: 14.5.sp,
                height: 1.65,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  controller.toggleFallback(widget.type, false);
                  controller.retry(widget.type);
                },
                icon: Icon(
                  Icons.sync_rounded,
                  size: 18.sp,
                  color: AppColors.primaryDark,
                ),
                label: Text(
                  tr(AppStrings.legalCheckServer),
                  style: TxtStyle.titleMedium(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: AppColors.primaryDark,
                    width: 1.5,
                  ),
                  padding: EdgeInsets.symmetric(vertical: 13.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
            ),
            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }

  Widget _buildDataContent(
    BuildContext context,
    LegalContent legalContent,
    String langCode,
    String Function(String) tr,
    LegalContentController controller,
  ) {
    final isEs = langCode.startsWith('es');
    String? formattedDate;
    if (legalContent.updatedAt != null) {
      try {
        formattedDate = DateFormat(
          'd MMMM, yyyy',
          isEs ? 'es' : 'en',
        ).format(legalContent.updatedAt!);
      } catch (_) {
        formattedDate =
            DateFormat('d MMMM, yyyy').format(legalContent.updatedAt!);
      }
    }

    return RefreshIndicator(
      color: AppColors.primaryDark,
      onRefresh: () async {
        controller.retry(widget.type);
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (formattedDate != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.softSlateBgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 15.sp,
                      color: AppColors.subtitleTextColor,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${tr(AppStrings.legalLastUpdated)} $formattedDate',
                      style: TxtStyle.bodySmall(
                        color: AppColors.subtitleTextColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            SelectableText(
              legalContent.content,
              style: TxtStyle.bodyMedium(
                color: AppColors.text,
                fontSize: 14.5.sp,
                height: 1.65,
              ),
            ),
            SizedBox(height: 36.h),
          ],
        ),
      ),
    );
  }
}
