import 'package:flutter/material.dart';
import 'package:cava_ecommerce/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../domain/utils/quipu_hpp_navigation_policy.dart';

/// Outcome of the in-app HPP WebView, returned to the caller via `pop`.
sealed class HppWebviewResult {
  const HppWebviewResult();
}

/// The HPP redirected to the payment return URL. Never proof of payment —
/// the caller must run server-side verification (`verifyQuipuPayment`).
class HppWebviewReturned extends HppWebviewResult {
  const HppWebviewReturned(this.transactionId);

  /// Transaction id from the return URL query, when present.
  final String? transactionId;
}

/// The user left the WebView without reaching the return URL (back/close).
/// NOT a cancellation: the payment stays unverified and can still settle.
class HppWebviewDismissed extends HppWebviewResult {
  const HppWebviewDismissed();
}

/// The flow was handed to an external application/browser (bank app scheme or
/// user-chosen browser fallback). Verification continues on app resume.
class HppWebviewOpenedExternally extends HppWebviewResult {
  const HppWebviewOpenedExternally();
}

/// Full-screen in-app WebView for the Quipu Hosted Payment Page.
///
/// Card number/CVV/expiry are entered ONLY inside the Quipu page — this screen
/// renders the remote page and never collects card data itself. 3D Secure
/// redirects (http/https) stay inside the WebView; non-web schemes fall back
/// to the external application.
class QuipuHppWebviewScreen extends StatefulWidget {
  const QuipuHppWebviewScreen({super.key, required this.initialUrl});

  final String initialUrl;

  @override
  State<QuipuHppWebviewScreen> createState() => _QuipuHppWebviewScreenState();
}

class _QuipuHppWebviewScreenState extends State<QuipuHppWebviewScreen> {
  late final WebViewController _webViewController;
  bool _loading = true;
  bool _loadFailed = false;
  bool _returned = false;

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
          onWebResourceError: _onWebResourceError,
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
  }

  void _setLoading(bool value) {
    if (mounted && _loading != value) {
      setState(() => _loading = value);
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final decision = QuipuHppNavigationPolicy.decide(request.url);
    switch (decision.action) {
      case HppNavigationAction.allow:
        return NavigationDecision.navigate;
      case HppNavigationAction.interceptReturn:
        _completeWithReturn(decision.transactionId);
        return NavigationDecision.prevent;
      case HppNavigationAction.openExternal:
        _openExternal(request.url);
        return NavigationDecision.prevent;
    }
  }

  void _completeWithReturn(String? transactionId) {
    if (_returned || !mounted) {
      return;
    }
    _returned = true;
    Navigator.of(context).pop(HppWebviewReturned(transactionId));
  }

  Future<void> _openExternal(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (launched && mounted && !_returned) {
        // Bank-app / external handoff: let the caller resume verification
        // when the app returns to the foreground.
        Navigator.of(context).pop(const HppWebviewOpenedExternally());
      }
    } catch (_) {
      // Ignore — the page stays open; the user can retry inside the WebView.
    }
  }

  /// User-facing fallback: continue the same HPP session in the real browser.
  Future<void> _openInBrowserFallback() async {
    final uri = Uri.tryParse(widget.initialUrl);
    if (uri == null) {
      return;
    }
    var launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }
    if (launched && mounted && !_returned) {
      Navigator.of(context).pop(const HppWebviewOpenedExternally());
    }
  }

  void _onWebResourceError(WebResourceError error) {
    // Only main-frame failures should replace the page with the error state;
    // subresource hiccups (images, trackers) are ignored.
    if (error.isForMainFrame ?? true) {
      if (mounted) {
        setState(() {
          _loadFailed = true;
          _loading = false;
        });
      }
    }
  }

  Future<void> _retry() async {
    setState(() {
      _loadFailed = false;
      _loading = true;
    });
    await _webViewController.loadRequest(Uri.parse(widget.initialUrl));
  }

  Future<void> _handleBack() async {
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      return;
    }
    if (mounted && !_returned) {
      // Leaving without the return redirect is NOT a cancellation — the
      // payment stays unverified and the caller keeps its pending state.
      Navigator.of(context).pop(const HppWebviewDismissed());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _handleBack();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          surfaceTintColor: AppColors.background,
          centerTitle: true,
          automaticallyImplyLeading: false,
          // Explicit back handler: one WebView page back when history exists,
          // otherwise leave the screen (without marking the payment cancelled).
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: _handleBack,
          ),
          title: Text(l10n.cardPaymentTitle, style: AppTextStyles.h2),
        ),
        body: SafeArea(
          child: _loadFailed ? _buildError(l10n) : _buildWebView(),
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),
        if (_loading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(
              color: AppColors.burgundy,
              backgroundColor: Colors.transparent,
            ),
          ),
      ],
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screen),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.burgundy.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.burgundy,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            l10n.cardPaymentWebviewLoadError,
            style: AppTextStyles.body,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          PrimaryButton(label: l10n.cardPaymentRetry, onPressed: _retry),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: _openInBrowserFallback,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.burgundy,
                side: const BorderSide(color: AppColors.burgundy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.cardPaymentOpenInBrowser,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.burgundy,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
