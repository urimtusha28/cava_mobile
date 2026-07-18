/// Navigation policy for the in-app Quipu Hosted Payment Page WebView.
///
/// Pure Dart (no WebView dependency) so URL interception is unit-testable:
/// - http/https URLs load inside the WebView (Quipu HPP, 3D Secure/ACS pages);
/// - the payment return URL is intercepted and never loaded — the app closes
///   the WebView and asks the backend (`verifyQuipuPayment`) for the real
///   status;
/// - non-web schemes (bank apps, `intent://`, `mailto:` …) are handed to the
///   OS as an external-application fallback.
enum HppNavigationAction {
  /// Load the URL inside the WebView.
  allow,

  /// The HPP redirected to the payment return URL — close the WebView and
  /// verify server-side. The redirect itself is never treated as success.
  interceptReturn,

  /// Not loadable in a WebView (bank app scheme, intent, mail …) — open via
  /// the external application/browser fallback.
  openExternal,
}

class HppNavigationDecision {
  const HppNavigationDecision._(this.action, this.transactionId);

  const HppNavigationDecision.allow() : this._(HppNavigationAction.allow, null);

  const HppNavigationDecision.interceptReturn(String? transactionId)
    : this._(HppNavigationAction.interceptReturn, transactionId);

  const HppNavigationDecision.openExternal()
    : this._(HppNavigationAction.openExternal, null);

  final HppNavigationAction action;

  /// Transaction id extracted from the return URL query (may be null when the
  /// gateway strips query parameters — the caller then falls back to the
  /// locally stored transaction id).
  final String? transactionId;
}

abstract final class QuipuHppNavigationPolicy {
  /// Path of the backend-configured HPP return URL
  /// (`QUIPU_HPP_RETURN_URL`, default `https://cava-premium.com/payment/return`).
  /// Matched by path so localhost/emulator return URLs are intercepted too.
  static const String returnPath = '/payment/return';

  /// Query parameter appended by `initiateQuipuPayment` to the return URL.
  static const String transactionIdParam = 'transactionId';

  static HppNavigationDecision decide(String url) {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.scheme.isEmpty) {
      // Unparseable/relative — let the OS decide instead of a WebView error.
      return const HppNavigationDecision.openExternal();
    }

    final scheme = uri.scheme.toLowerCase();
    if (scheme == 'http' || scheme == 'https') {
      if (isReturnUrl(uri)) {
        return HppNavigationDecision.interceptReturn(extractTransactionId(uri));
      }
      return const HppNavigationDecision.allow();
    }

    // `about:blank` & co. are used by 3DS iframes/interstitials.
    if (scheme == 'about' || scheme == 'data' || scheme == 'blob') {
      return const HppNavigationDecision.allow();
    }

    return const HppNavigationDecision.openExternal();
  }

  static bool isReturnUrl(Uri uri) {
    final path = uri.path.toLowerCase();
    final target = returnPath.toLowerCase();
    return path == target || path == '$target/';
  }

  static String? extractTransactionId(Uri uri) {
    final value = uri.queryParameters[transactionIdParam]?.trim();
    if (value == null || value.isEmpty || value.length > 128) {
      return null;
    }
    return value;
  }
}
