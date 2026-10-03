import 'dart:async';

import 'package:flutter/material.dart';

final _actionSnackBarTimers = Expando<Timer>();

extension AppScaffoldMessenger on BuildContext {
  void showAppSnackBar(SnackBar snackBar) {
    final messenger = ScaffoldMessenger.of(this);
    final hasAction = snackBar.action != null;
    const duration = Duration(seconds: 3);
    _actionSnackBarTimers[messenger]?.cancel();
    _actionSnackBarTimers[messenger] = null;
    messenger
      ..clearSnackBars()
      ..hideCurrentSnackBar();

    late final ScaffoldFeatureController<SnackBar, SnackBarClosedReason>
    controller;
    void onVisible() {
      snackBar.onVisible?.call();
      if (!hasAction) return;

      final timer = Timer(duration, () {
        if (messenger.mounted) controller.close();
      });
      _actionSnackBarTimers[messenger] = timer;
      unawaited(
        controller.closed.then<void>((_) {
          if (identical(_actionSnackBarTimers[messenger], timer)) {
            timer.cancel();
            _actionSnackBarTimers[messenger] = null;
          }
        }),
      );
    }

    controller = messenger.showSnackBar(
      SnackBar(
        key: snackBar.key,
        content: snackBar.content,
        backgroundColor: snackBar.backgroundColor,
        elevation: snackBar.elevation,
        margin: snackBar.margin,
        padding: snackBar.padding,
        width: snackBar.width,
        shape: snackBar.shape,
        behavior: hasAction ? SnackBarBehavior.floating : snackBar.behavior,
        action: snackBar.action,
        actionOverflowThreshold: snackBar.actionOverflowThreshold,
        showCloseIcon: hasAction || snackBar.showCloseIcon == true,
        closeIconColor: snackBar.closeIconColor,
        dismissDirection: snackBar.dismissDirection,
        clipBehavior: snackBar.clipBehavior,
        onVisible: onVisible,
        animation: snackBar.animation,
        duration: hasAction ? duration : const Duration(seconds: 4),
      ),
    );
  }
}
