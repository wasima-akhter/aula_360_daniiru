// import 'package:aula360/features/share/export/screen_export.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';

// import '../../../../../core/features/other/controller/other_controller.dart';
// import '../../../../../utils/enum/app_enum.dart';

// class RatingBottomSheet extends StatelessWidget {
//   const RatingBottomSheet({super.key});
//   @override
//   Widget build(BuildContext context) {
//     final controller = OtherController.to;
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
//       ),
//       padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 30.h),
//       child: SafeArea(
//         top: false,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             /// Drag Handle
//             Container(
//               width: 45.w,
//               height: 5.h,
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade300,
//                 borderRadius: BorderRadius.circular(20.r),
//               ),
//             ),

//             Gap(20.h),

//             /// Title & Close
//             Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       /// Title
//                       Text(
//                         AppStrings.rateSomSpot,
//                         style: context.titleLarge.copyWith(
//                           fontWeight: FontWeight.w700,
//                           color: AppColors.blackMainTextColor,
//                         ),
//                       ),

//                       Gap(4.h),

//                       /// Subtitle
//                       Text(
//                         AppStrings.enjoyingTheAppLetUsKnow,
//                         style: context.bodySmall.copyWith(
//                           color: AppColors.grayTextSecondaryColor,
//                           fontWeight: FontWeight.w400,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   onPressed: () => Navigator.pop(context),
//                   icon: Icon(
//                     Icons.close,
//                     color: AppColors.grayTextSecondaryColor,
//                     size: 22.sp,
//                   ),
//                 ),
//               ],
//             ),

//             Gap(22.h),

//             /// Rating Card
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 18.w),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade100,
//                 borderRadius: BorderRadius.circular(18.r),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     AppStrings.tapToRate,
//                     style: context.bodyMedium.copyWith(
//                       color: AppColors.grayTextSecondaryColor,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),

//                   Gap(18.h),

//                   RatingBar.builder(
//                     initialRating: controller.rating.value,
//                     minRating: 1,
//                     allowHalfRating: false,
//                     itemCount: 5,
//                     itemSize: 38.sp,
//                     unratedColor: Colors.grey.shade300,
//                     itemPadding: EdgeInsets.symmetric(horizontal: 4.w),
//                     itemBuilder: (_, _) => const Icon(
//                       Icons.star_rounded,
//                       color: Color(0xffFFC529),
//                     ),
//                     onRatingUpdate: controller.updateRating,
//                   ),

//                   Gap(16.h),

//                   Obx(
//                     () => Text(
//                       controller.ratingText,
//                       style: context.titleMedium.copyWith(
//                         fontWeight: FontWeight.w700,
//                         color: AppColors.blackMainTextColor,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Gap(28.h),

//             /// Submit Button
//             Obx(
//               () => SizedBox(
//                 width: double.infinity,
//                 height: 50.h,
//                 child: ElevatedButton.icon(
//                   onPressed: controller.ratingLoading.value == ApiStatus.loading
//                       ? null
//                       : () {
//                           controller.submitRating(
//                             onSuccess: () {
//                               Navigator.pop(context);
//                             },
//                           );
//                         },

//                   icon: controller.ratingLoading.value == ApiStatus.loading
//                       ? SizedBox(
//                           height: 18.h,
//                           width: 18.w,
//                           child: CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Icon(Icons.send, size: 20.sp),

//                   label: Text(
//                     AppStrings.submitRating,
//                     style: context.bodyMedium.copyWith(
//                       color: Colors.white,
//                       fontSize: 15.5.sp,
//                     ),
//                   ),

//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: const Color(0xff4DA3FF),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
