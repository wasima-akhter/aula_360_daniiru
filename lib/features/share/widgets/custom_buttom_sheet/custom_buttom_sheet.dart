import 'package:flutter/material.dart';

import 'widgets/confirmation_modal_bottom_sheet.dart';

Widget makeDismissable(BuildContext context, {required Widget child}) =>
    GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).pop(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: child,
      ),
    );

void showYesNoModal(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmButtonText,
  required VoidCallback onConfirm,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return ConfirmationModalBottomSheet(
        title: title,
        message: message,
        confirmButtonText: confirmButtonText,
        onConfirm: onConfirm,
      );
    },
  );
}

//
// void showRatingBottomSheet(BuildContext context) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     builder: (_) => const RatingBottomSheet(),
//   );
// }
