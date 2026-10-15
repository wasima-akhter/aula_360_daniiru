import 'package:aula360/features/share/export/screen_export.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class CustomDropdownField<T> extends StatefulWidget {
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
  final bool? isSearchable;
  final String? searchHintText;
  final double? maxHeight;
  final double? itemHeight;
  final Widget? prefixIcon;
  final bool Function(DropdownMenuItem<T>, String)? searchMatchFn;

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
    this.isSearchable,
    this.searchHintText,
    this.maxHeight,
    this.itemHeight,
    this.prefixIcon,
    this.searchMatchFn,
  });

  @override
  State<CustomDropdownField<T>> createState() => _CustomDropdownFieldState<T>();
}

class _CustomDropdownFieldState<T> extends State<CustomDropdownField<T>> {
  final TextEditingController _searchController = TextEditingController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _searchController.dispose();
    super.dispose();
  }

  bool get _effectiveSearchable =>
      widget.isSearchable ?? (widget.items.length > 7);

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty && widget.emptyPlaceholder != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [widget.emptyPlaceholder!, const SizedBox(height: 8)],
      );
    }

    const message = 'Field Is Required';
    final String? Function(T?)? validation = widget.isRequired
        ? (val) => (val == null) ? message : null
        : null;
    final validationFunction = widget.validator ?? validation;
    final bool hasError =
        widget.errorText != null && widget.errorText!.isNotEmpty;

    // Filter unique items to avoid DropdownButton duplicate value assertion
    final seen = <T>{};
    final uniqueItems = <T>[];
    for (final item in widget.items) {
      if (seen.add(item)) {
        uniqueItems.add(item);
      }
    }

    final effectiveMaxHeight = widget.maxHeight ?? 280.h;
    final effectiveItemHeight = widget.itemHeight ?? 46.h;

    final dropdownItems = <DropdownMenuItem<T>>[
      ...uniqueItems.map((item) {
        final isSelected = item == widget.value;
        final label = widget.labelBuilder?.call(item) ?? item.toString();

        return DropdownMenuItem<T>(
          value: item,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.bodyMedium.copyWith(
                      fontSize: 14.5.sp,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.text,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
          ),
        );
      }),
      if (widget.onLoadMore != null && widget.hasMore)
        DropdownMenuItem<T>(
          value: null,
          enabled: !widget.isLoadingMore,
          child: Center(
            child: widget.isLoadingMore
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Load more',
                    style: context.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
          ),
        ),
    ];

    return DropdownButtonFormField2<T>(
      isExpanded: true,
      value: uniqueItems.contains(widget.value) ? widget.value : null,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.redColor : AppColors.border,
            width: 1.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.redColor : AppColors.border,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? AppColors.redColor : AppColors.primary,
            width: 1.2,
          ),
        ),
        filled: true,
        fillColor: widget.fillColor ?? Colors.white,
        errorText: widget.errorText,
        errorStyle: const TextStyle(color: AppColors.redColor),
        prefixIcon: widget.prefixIcon,
      ),
      hint: Text(
        widget.hintText,
        style: context.bodyMedium.copyWith(
          color: const Color(0xFFADB5C2),
          fontWeight: FontWeight.w400,
          fontSize: 14.5.sp,
        ),
      ),
      items: dropdownItems,
      onChanged: widget.enabled
          ? (value) async {
              if (value == null &&
                  widget.onLoadMore != null &&
                  widget.hasMore) {
                await widget.onLoadMore!();
                return;
              }
              widget.onChanged?.call(value);
            }
          : null,
      onMenuStateChange: (isOpen) {
        if (!isOpen && !_isDisposed) {
          _searchController.clear();
        }
      },
      validator: validationFunction,
      style: context.bodyMedium,
      buttonStyleData: const ButtonStyleData(
        padding: EdgeInsets.only(right: 8),
      ),
      iconStyleData: const IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF718096),
        ),
        iconSize: 22,
      ),
      selectedItemBuilder: (context) {
        return uniqueItems.map((item) {
          final label = widget.labelBuilder?.call(item) ?? item.toString();
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: context.titleMedium.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
      dropdownSearchData: _effectiveSearchable
          ? DropdownSearchData<T>(
              searchController: _searchController,
              searchInnerWidgetHeight: 52.h,
              searchInnerWidget: Container(
                height: 52.h,
                padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 4.h),
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _searchController,
                  builder: (context, value, child) {
                    return TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: _searchController,
                      style: context.bodyMedium.copyWith(fontSize: 14.sp),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 8.h,
                        ),
                        hintText: widget.searchHintText ?? 'Search...',
                        hintStyle: context.bodyMedium.copyWith(
                          color: const Color(0xFFADB5C2),
                          fontSize: 13.5.sp,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Color(0xFF718096),
                        ),
                        suffixIcon: value.text.isNotEmpty
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () => _searchController.clear(),
                                child: const Icon(
                                  Icons.close_rounded,
                                  size: 16,
                                  color: Color(0xFF718096),
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: const Color(0xFFF7F8FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              searchMatchFn: (item, searchValue) {
                if (item.value == null) return true;
                if (widget.searchMatchFn != null) {
                  return widget.searchMatchFn!(item, searchValue);
                }
                final label = widget.labelBuilder != null
                    ? widget.labelBuilder!(item.value as T)
                    : item.value.toString();
                return label
                    .toLowerCase()
                    .contains(searchValue.toLowerCase().trim());
              },
            )
          : null,
      dropdownStyleData: DropdownStyleData(
        maxHeight: effectiveMaxHeight,
        elevation: 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        offset: const Offset(0, -4),
        scrollbarTheme: ScrollbarThemeData(
          radius: const Radius.circular(8),
          thickness: WidgetStateProperty.all(5),
          thumbVisibility: WidgetStateProperty.all(true),
          thumbColor: WidgetStateProperty.all(
            AppColors.primary.withValues(alpha: 0.45),
          ),
        ),
      ),
      menuItemStyleData: MenuItemStyleData(
        height: effectiveItemHeight,
        padding: EdgeInsets.symmetric(horizontal: 6.w),
      ),
    );
  }
}

