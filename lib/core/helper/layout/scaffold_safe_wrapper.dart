import '../../../features/share/export/screen_export.dart';

class ScaffoldWrapper extends StatelessWidget {
  const ScaffoldWrapper({
    super.key,
    this.appBar,
    required this.body,
    this.bottomWidget,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.title,
    this.onPressed,
    this.actions,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomWidget;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final String? title;
  final List<Widget>? actions;

  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    final safeBottom = bottomPadding(context) + 10;

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.backgroundColorNew,

      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      appBar:
          appBar ??
          AppBar(
            backgroundColor: Colors.transparent,

            elevation: 0,

            leading: IconButton(
              icon: Icon(Iconsax.arrow_left_2, size: 18.sp),
              onPressed:
                  onPressed ??
                  () {
                    AppRouter.router.goNamed(RoutePath.navigationPages);
                  },
            ),
            title: Text(
              title ?? '',
              style: context.titleLarge.copyWith(fontWeight: FontWeight.w600),
            ),
            centerTitle: false,
            titleSpacing: 0,

            actions: actions ?? [],
          ),

      body: Padding(
        padding: EdgeInsets.only(bottom: safeBottom),
        child: body,
      ),
      bottomNavigationBar: bottomWidget == null
          ? null
          : Padding(
              padding: EdgeInsets.only(left: 20, right: 20, bottom: safeBottom),
              child: bottomWidget,
            ),
    );
  }
}
