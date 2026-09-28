import 'package:aula360/features/share/export/screen_export.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String hintText;
  final List<T> items;
  final T? value;
  final String Function(T)? labelBuilder;
  final void Function(T?)? onChanged;
  final String? Function(T?)? validator;
  final bool isRequired;
  final Color? fillColor;
  final String? errorText;
  final bool enabled;
  final Future<void> Function()? onLoadMore;
  final bool hasMore;
  final bool isLoadingMore;
  final Widget? emptyPlaceholder;

  const CustomDropdownField({
    super.key,
    required this.hintText,
    required this.items,
    this.value,
    this.labelBuilder,
    this.onChanged,
    this.validator,
    this.isRequired = false,
    this.fillColor,
    this.errorText,
    this.enabled = true,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.emptyPlaceholder,
  });

  @override
  Widget build(BuildContext context) {
    final message = "Field Is Required";

    String? Function(T?)? validation = (isRequired
        ? (val) => (val == null) ? message : null
        : null);
    final validationFunction = validator ?? validation;

    final bool hasError = errorText != null && errorText!.isNotEmpty;

    //
    final dropdownItems = <DropdownMenuItem<T>>[
      ...items.map((item) {
        final isSelected = item == value;

        return DropdownMenuItem<T>(
          value: item,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(
              labelBuilder?.call(item) ?? item.toString(),
              style: context.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppColors.primaryColor
                    : AppColors.darkTextColor,
              ),
            ),
          ),
        );
      }),

      if (onLoadMore != null && hasMore)
        DropdownMenuItem<T>(
          value: null,
          enabled: !isLoadingMore,
          child: Center(
            child: isLoadingMore
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    "Load more",
                    style: context.bodyMedium.copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
    ];

    if (items.isEmpty && emptyPlaceholder != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [emptyPlaceholder!, const SizedBox(height: 8)],
      );
    }

    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: items.contains(value) ? value : null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        border: OutlineInputBorder(
          gapPadding: 0,
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(
            color: hasError
                ? AppColors.redColor
                : AppColors.bgSecondaryButtonColor,
            width: 0.8,
          ),
        ),
        filled: true,
        fillColor: fillColor ?? AppColors.white,
        errorText: errorText,
        errorStyle: const TextStyle(color: AppColors.redColor),
      ),
      hint: Text(
        hintText,
        style: context.bodyMedium.copyWith(
          color: AppColors.grayTertiaryTextColor,
          fontWeight: FontWeight.w400,
        ),
      ),
      items: dropdownItems,
      onChanged: enabled
          ? (value) async {
              if (value == null && onLoadMore != null && hasMore) {
                await onLoadMore!();
                return;
              }

              onChanged?.call(value);
            }
          : null,
      validator: validationFunction,
      style: context.bodyMedium,
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down,
          color: AppColors.grayTertiaryTextColor,
        ),
        iconSize: 24,
      ),
      selectedItemBuilder: (context) {
        return items.map((item) {
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              labelBuilder?.call(item) ?? item.toString(),
              style: context.bodyMedium.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextColor,
                letterSpacing: 0.2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      dropdownStyleData: DropdownStyleData(
        maxHeight: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10),
      ),
    );
  }
}
