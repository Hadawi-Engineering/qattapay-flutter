/// QattaPay environment mode.
///
/// Merchants pick [dev] or [live] — the SDK resolves the correct hostnames.
enum QattaPayMode {
  /// `https://dev.qatta.sa` (fallback: `https://dev.hadawi.sa`)
  dev,

  /// `https://qatta.sa` (fallback: `https://beta.hadawi.sa`)
  live,
}

class _HostPair {
  const _HostPair(this.primary, this.fallback);
  final String primary;
  final String fallback;
}

/// `qatta.sa` is tried first. The previous brand's deployment is kept as an
/// automatic fallback during the domain migration.
const Map<QattaPayMode, _HostPair> _hosts = {
  QattaPayMode.dev: _HostPair(
    'https://dev.qatta.sa',
    'https://dev.hadawi.sa',
  ),
  QattaPayMode.live: _HostPair(
    'https://qatta.sa',
    'https://beta.hadawi.sa',
  ),
};

/// Hosted checkout / web app origin for the given mode (primary host).
String resolveCheckoutBaseUrl(QattaPayMode mode) => _hosts[mode]!.primary;

/// Ordered checkout hosts — `qatta.sa` first, then the `hadawi.sa` fallback.
List<String> resolveCheckoutHosts(QattaPayMode mode) {
  final pair = _hosts[mode]!;
  return [pair.primary, pair.fallback];
}

/// REST API base URL for the given mode (primary host, `…/api`).
String resolveApiBaseUrl(QattaPayMode mode) => '${_hosts[mode]!.primary}/api';

/// Ordered API base URLs — `qatta.sa` first, then the `hadawi.sa` fallback.
List<String> resolveApiHosts(QattaPayMode mode) {
  final pair = _hosts[mode]!;
  return ['${pair.primary}/api', '${pair.fallback}/api'];
}
