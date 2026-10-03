import 'package:flutter/material.dart';

extension AppScaffoldMessenger on BuildContext {
  void showAppSnackBar(SnackBar snackBar) {
    final messenger = ScaffoldMessenger.of(this);
    messenger
      ..clearSnackBars()
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: snackBar.key,
          content: snackBar.content,
          backgroundColor: snackBar.backgroundColor,
          elevation: snackBar.elevation,
          margin: snackBar.margin,
          padding: snackBar.padding,
          width: snackBar.width,
          shape: snackBar.shape,
          behavior: snackBar.behavior,
          action: snackBar.action,
          actionOverflowThreshold: snackBar.actionOverflowThreshold,
          showCloseIcon: snackBar.showCloseIcon,
          closeIconColor: snackBar.closeIconColor,
          dismissDirection: snackBar.dismissDirection,
          clipBehavior: snackBar.clipBehavior,
          onVisible: snackBar.onVisible,
          animation: snackBar.animation,
          duration: const Duration(seconds: 4),
        ),
      );
  }
}
