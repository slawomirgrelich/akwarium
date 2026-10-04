import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../services/pro_access_service.dart';

import 'package:akwarium/utils/app_snackbar.dart';

class ProBadge extends StatelessWidget {
  const ProBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (context.watch<ProAccessService>().isProUser) {
      return const SizedBox.shrink();
    }
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.amber.shade700,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'PRO',
        style: TextStyle(
          color: Colors.white,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class ProPaywallDialog extends StatefulWidget {
  const ProPaywallDialog({this.headline, super.key});

  final String? headline;

  static Future<void> show(BuildContext context, {String? headline}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => ProPaywallDialog(headline: headline),
    );
  }

  @override
  State<ProPaywallDialog> createState() => _ProPaywallDialogState();
}

class _ProPaywallDialogState extends State<ProPaywallDialog> {
  static const _monthlyProductId = 'akwarysta_pro_monthly';
  static const _yearlyProductId = 'akwarysta_pro_yearly';
  static const _productIds = {_monthlyProductId, _yearlyProductId};

  InAppPurchase? _inAppPurchase;
  final Map<String, ProductDetails> _products = {};
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool _yearlyPlanSelected = true;
  bool _loadingProducts = true;
  bool _storeAvailable = false;
  bool _purchasePending = false;
  bool _activating = false;
  _PurchaseMessage? _purchaseMessage;

  String get _selectedProductId =>
      _yearlyPlanSelected ? _yearlyProductId : _monthlyProductId;
  ProductDetails? get _selectedProduct => _products[_selectedProductId];
  bool get _canPurchase =>
      !_loadingProducts &&
      _storeAvailable &&
      !_purchasePending &&
      !_activating &&
      _selectedProduct != null;

  bool get _storePlatformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  @override
  void initState() {
    super.initState();
    if (!_storePlatformSupported) {
      _loadingProducts = false;
      _purchaseMessage = _PurchaseMessage.storeUnavailable;
      return;
    }

    final inAppPurchase = InAppPurchase.instance;
    _inAppPurchase = inAppPurchase;
    _purchaseSubscription = inAppPurchase.purchaseStream.listen(
      _onPurchaseUpdates,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('Google Play purchase stream failed: $error');
        debugPrintStack(stackTrace: stackTrace);
        if (!mounted) return;
        setState(() {
          _purchasePending = false;
          _activating = false;
          _purchaseMessage = _PurchaseMessage.purchaseFailed;
        });
      },
    );
    unawaited(_loadProducts());
  }

  Future<void> _loadProducts() async {
    final inAppPurchase = _inAppPurchase;
    if (inAppPurchase == null) return;

    try {
      final available = await inAppPurchase.isAvailable();
      if (!mounted) return;
      if (!available) {
        setState(() {
          _loadingProducts = false;
          _purchaseMessage = _PurchaseMessage.storeUnavailable;
        });
        return;
      }

      final response = await inAppPurchase.queryProductDetails(_productIds);
      if (response.error != null) {
        debugPrint(
          'Google Play product query failed: ${response.error!.message}',
        );
      }
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
          'Google Play products not found: ${response.notFoundIDs.join(', ')}',
        );
      }
      if (!mounted) return;

      setState(() {
        _storeAvailable = true;
        _loadingProducts = false;
        _products
          ..clear()
          ..addEntries(
            response.productDetails.map(
              (product) => MapEntry(product.id, product),
            ),
          );
        _purchaseMessage = response.error != null || _selectedProduct == null
            ? _PurchaseMessage.productsUnavailable
            : null;
      });
    } on Object catch (error, stackTrace) {
      debugPrint('Google Play initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _loadingProducts = false;
        _purchaseMessage = _PurchaseMessage.storeUnavailable;
      });
    }
  }

  Future<void> _onPurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (!_productIds.contains(purchase.productID)) {
        debugPrint(
          'Ignoring purchase for an unexpected product: ${purchase.productID}',
        );
        continue;
      }

      switch (purchase.status) {
        case PurchaseStatus.pending:
          if (mounted) {
            setState(() {
              _purchasePending = true;
              _purchaseMessage = _PurchaseMessage.purchasePending;
            });
          }
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _activatePurchase(purchase);
        case PurchaseStatus.error:
          debugPrint('Google Play purchase failed: ${purchase.error?.message}');
          await _completePurchase(purchase);
          if (mounted) {
            setState(() {
              _purchasePending = false;
              _activating = false;
              _purchaseMessage = _PurchaseMessage.purchaseFailed;
            });
          }
        case PurchaseStatus.canceled:
          final completed = await _completePurchase(purchase);
          if (mounted) {
            setState(() {
              _purchasePending = false;
              _activating = false;
              _purchaseMessage = completed
                  ? _PurchaseMessage.purchaseCancelled
                  : _PurchaseMessage.purchaseFailed;
            });
          }
      }
    }
  }

  Future<void> _activatePurchase(PurchaseDetails purchase) async {
    final plan = switch (purchase.productID) {
      _monthlyProductId => 'monthly',
      _yearlyProductId => 'yearly',
      _ => null,
    };
    if (plan == null) return;

    if (mounted) {
      setState(() {
        _purchasePending = false;
        _activating = true;
        _purchaseMessage = null;
      });
    }

    Object? activationError;
    try {
      await context.read<ProAccessService>().setProUser(true, plan: plan);
    } on Object catch (error, stackTrace) {
      activationError = error;
      debugPrint('PRO subscription activation failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
    final completed = await _completePurchase(purchase);
    if (!mounted) return;

    setState(() {
      _activating = false;
      _purchasePending = false;
      if (activationError != null || !completed) {
        _purchaseMessage = _PurchaseMessage.purchaseFailed;
      }
    });
    if (activationError != null) {
      context.showAppSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .proActivationFailed(activationError.toString()),
          ),
        ),
      );
      return;
    }
    if (!completed) return;

    Navigator.pop(context);
    context.showAppSnackBar(
      SnackBar(
        content: Text(AppLocalizations.of(context)!.proActivatedMessage),
      ),
    );
  }

  Future<bool> _completePurchase(PurchaseDetails purchase) async {
    if (!purchase.pendingCompletePurchase) return true;
    final inAppPurchase = _inAppPurchase;
    if (inAppPurchase == null) return false;
    try {
      await inAppPurchase.completePurchase(purchase);
      return true;
    } on Object catch (error, stackTrace) {
      debugPrint('Google Play transaction completion failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> _startPurchase() async {
    final product = _selectedProduct;
    final inAppPurchase = _inAppPurchase;
    if (!_canPurchase || product == null || inAppPurchase == null) return;

    setState(() {
      _purchasePending = true;
      _purchaseMessage = null;
    });
    try {
      final purchaseStarted = await inAppPurchase.buyNonConsumable(
        purchaseParam: PurchaseParam(productDetails: product),
      );
      if (!purchaseStarted && mounted) {
        setState(() {
          _purchasePending = false;
          _purchaseMessage = _PurchaseMessage.purchaseFailed;
        });
      }
    } on Object catch (error, stackTrace) {
      debugPrint('Google Play purchase could not be started: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(() {
        _purchasePending = false;
        _purchaseMessage = _PurchaseMessage.purchaseFailed;
      });
    }
  }

  void _selectPlan(bool yearly) {
    setState(() {
      _yearlyPlanSelected = yearly;
      if (!_storeAvailable) {
        _purchaseMessage = _PurchaseMessage.storeUnavailable;
      } else if (!_loadingProducts && _selectedProduct == null) {
        _purchaseMessage = _PurchaseMessage.productsUnavailable;
      } else {
        _purchaseMessage = null;
      }
    });
  }

  String? _messageText(AppLocalizations l10n) {
    return switch (_purchaseMessage) {
      _PurchaseMessage.storeUnavailable => l10n.subscriptionStoreUnavailable,
      _PurchaseMessage.productsUnavailable => l10n.purchaseNotConfigured,
      _PurchaseMessage.purchasePending => l10n.subscriptionPurchasePending,
      _PurchaseMessage.purchaseCancelled => l10n.subscriptionPurchaseCancelled,
      _PurchaseMessage.purchaseFailed => l10n.subscriptionPurchaseFailed,
      null => null,
    };
  }

  @override
  void dispose() {
    unawaited(_purchaseSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final selectedStatusText = _messageText(l10n);
    return PopScope(
      canPop: !_purchasePending && !_activating,
      child: AlertDialog(
        title: Row(
          children: [
            Expanded(child: Text(widget.headline ?? l10n.unlockProHeadline)),
            const SizedBox(width: 8),
            const ProBadge(),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.proPaywallSubtitle,
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 18),
              _Benefit(
                icon: Icons.show_chart,
                text: l10n.featureUnlimitedCharts,
              ),
              _Benefit(
                icon: Icons.water_drop_outlined,
                text: l10n.proBenefitUnlimitedAquariums,
              ),
              _Benefit(
                icon: Icons.auto_awesome,
                text: l10n.proBenefitAiScannerDiagnostics,
              ),
              _Benefit(
                icon: Icons.eco_outlined,
                text: l10n.featureFertilizerCalc,
              ),
              _Benefit(
                icon: Icons.notifications_active_outlined,
                text: l10n.featureReminders,
              ),
              _Benefit(
                icon: Icons.picture_as_pdf_outlined,
                text: l10n.featureExportPdf,
              ),
              _Benefit(
                icon: Icons.photo_library_outlined,
                text: l10n.proBenefitFullPhotoHistory,
              ),
              _Benefit(icon: Icons.block, text: l10n.proBenefitNoAds),
              const SizedBox(height: 8),
              _PlanTile(
                title: l10n.monthlyPlan,
                price:
                    _products[_monthlyProductId]?.price ??
                    (_loadingProducts
                        ? l10n.loadingSubscriptionPrices
                        : l10n.purchaseNotConfigured),
                selected: !_yearlyPlanSelected,
                onTap: () => _selectPlan(false),
              ),
              const SizedBox(height: 8),
              _PlanTile(
                title: l10n.yearlyPlan,
                price:
                    _products[_yearlyProductId]?.price ??
                    (_loadingProducts
                        ? l10n.loadingSubscriptionPrices
                        : l10n.purchaseNotConfigured),
                badge: l10n.mostPopularBadge,
                selected: _yearlyPlanSelected,
                onTap: () => _selectPlan(true),
              ),
              if (selectedStatusText != null) ...[
                const SizedBox(height: 8),
                Text(
                  selectedStatusText,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _purchasePending || _activating
                ? null
                : () => Navigator.pop(context),
            child: Text(l10n.maybeLater),
          ),
          FilledButton.icon(
            onPressed: _canPurchase ? _startPurchase : null,
            icon: _purchasePending || _activating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              _loadingProducts
                  ? l10n.loadingSubscriptionPrices
                  : _purchasePending || _activating
                  ? l10n.activatingEllipsis
                  : _selectedProduct == null
                  ? l10n.purchaseNotConfigured
                  : l10n.tryPro,
            ),
          ),
        ],
      ),
    );
  }
}

enum _PurchaseMessage {
  storeUnavailable,
  productsUnavailable,
  purchasePending,
  purchaseCancelled,
  purchaseFailed,
}

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.title,
    required this.price,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.outline;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(price),
                ],
              ),
            ),
            if (badge != null)
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade700,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  const _Benefit({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.teal.shade700, size: 21),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
