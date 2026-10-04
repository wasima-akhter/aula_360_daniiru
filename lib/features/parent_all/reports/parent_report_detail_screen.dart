import '../../parent_all/helper/parent_home_helper.dart';
import '../../share/export/screen_export.dart';
import 'parent_report_screen.dart';

class ReportDetailsScreen extends StatefulWidget {
  final ReportModel report;

  const ReportDetailsScreen({super.key, required this.report});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  bool showFullNote = false;

  @override
  Widget build(BuildContext context) {
    final report = widget.report;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      appBar: const AulaAppBar(title: 'Report Details', showBack: true),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 30.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _header(report),

                SizedBox(height: 18.h),

                _homeworkSection(report),

                SizedBox(height: 16.h),

                _teacherObservation(report),

                SizedBox(height: 16.h),

                _attendanceSection(),

                SizedBox(height: 16.h),

                _reportAction(),

                SizedBox(height: 10.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _header(ReportModel report) {
    return AulaCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.subject,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      report.teacher,
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 15.sp,
                      ),
                    ),
                  ],
                ),
              ),
              const StatusPill(text: 'Present'),
            ],
          ),

          SizedBox(height: 15.h),

          Divider(height: 1, color: AppColors.backgroundsLinesColor),

          SizedBox(height: 13.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 7.w),
                    Flexible(
                      child: Text(
                        report.dateLabel.replaceAll('TODAY — ', ''),
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // const Spacer(),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 16.sp,
                      color: AppColors.secondaryText,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        report.time,
                        style: TxtStyle.titleLarge(
                          color: AppColors.secondaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _homeworkSection(ReportModel report) {
    return _sectionCard(
      title: 'Homework',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Essay Draft: Character Motivations',
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),

          SizedBox(height: 5.h),

          Text(
            'Due Oct 26',
            style: TxtStyle.titleLarge(
              color: const Color(0xFFE68A27),
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 10.h),

          Text(
            'Write a 500-word analysis explaining how character motivation develops throughout the selected chapter.',
            style: TxtStyle.bodyMedium(
              color: AppColors.secondaryText,
              fontSize: 14.5.sp,
              height: 1.45,
            ),
          ),

          SizedBox(height: 13.h),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                context.push(RoutePath.homework);
              },
              child: Text(
                'View Homework →',
                style: TxtStyle.titleLarge(
                  color: AppColors.primary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _teacherObservation(ReportModel report) {
    final note = report.note;

    return _sectionCard(
      title: 'Teacher Observation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UserAvatar(initials: report.initials, size: 36),
              SizedBox(width: 9.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.teacher,
                      style: TxtStyle.titleLarge(
                        color: AppColors.text,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      report.subject,
                      style: TxtStyle.titleLarge(
                        color: AppColors.secondaryText,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 13.h),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F7FF),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '"$note"',
              maxLines: showFullNote ? null : 4,
              overflow: showFullNote
                  ? TextOverflow.visible
                  : TextOverflow.ellipsis,
              style: TxtStyle.bodyMedium(
                color: AppColors.text,
                fontSize: 15.sp,
                height: 1.5,
              ),
            ),
          ),

          SizedBox(height: 8.h),

          GestureDetector(
            onTap: () {
              setState(() {
                showFullNote = !showFullNote;
              });
            },
            child: Text(
              showFullNote ? 'Show Less' : 'Read Full Note',
              style: TxtStyle.titleLarge(
                color: AppColors.primary,
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _attendanceSection() {
    return _sectionCard(
      title: 'Attendance',
      child: Row(
        children: [
          Expanded(
            child: _statItem('Status', 'Present', const Color(0xFF2B9D70)),
          ),
          Expanded(child: _statItem('Duration', '1h 20m', AppColors.primary)),
          Expanded(
            child: _statItem(
              'Participation',
              'Excellent',
              const Color(0xFF7656D8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TxtStyle.titleLarge(
            color: AppColors.secondaryText,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          textAlign: TextAlign.center,
          style: TxtStyle.titleLarge(
            color: color,
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _reportAction() {
    return GestureDetector(
      onTap: () {
        // Optional: download/share report
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(11.r),
        ),
        child: Center(
          child: Text(
            'Download Report',
            style: TxtStyle.titleLarge(
              color: Colors.white,
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return AulaCard(
      padding: EdgeInsets.all(15.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TxtStyle.titleLarge(
              color: AppColors.text,
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}
