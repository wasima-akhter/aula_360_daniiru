import 'package:aula360/features/share/export/screen_export.dart';

class CustomAlignText extends StatelessWidget {
  const CustomAlignText({
    super.key,
    this.alignment,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.style,
    this.maxLine,
    this.textAlign,
  });

  /// If null, automatically uses the app's current text direction.
  ///
  /// LTR -> Alignment.centerLeft
  /// RTL -> Alignment.centerRight
  final Alignment? alignment;

  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextStyle? style;
  final int? maxLine;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final resolvedAlignment =
        alignment ?? (isRtl ? Alignment.centerRight : Alignment.centerLeft);

    final resolvedTextAlign =
        textAlign ?? (isRtl ? TextAlign.right : TextAlign.left);

    return Align(
      alignment: resolvedAlignment,
      child: Text(
        text,
        textAlign: resolvedTextAlign,
        maxLines: maxLine,
        overflow: TextOverflow.ellipsis,
        style:
            style ??
            context.titleSmall.copyWith(
              fontWeight: fontWeight ?? FontWeight.w500,
              fontSize: fontSize,
              color: color ?? AppColors.blackMainTextColor,
            ),
      ),
    );
  }
}
