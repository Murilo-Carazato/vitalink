import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

/// Listens for incoming deep links (custom scheme `vitalink://…`) and
/// encaminha para as rotas internas definidas no [GoRouter].
class DeepLinkService {
  DeepLinkService(this._router);

  final GoRouter _router;
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  Future<void> init() async {
    // Link que abriu o app (cold start)
    final Uri? initial = await _appLinks.getInitialLink();
    _handle(initial);

    // Links enquanto app já aberto
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (err) {
      // Apenas loga o erro – não fazemos nada especial
      // ignore: avoid_print
      print('[DeepLinkService] error: $err');
    });
  }

  void _handle(Uri? uri) {
    if (uri == null) return;

    // Aceitamos vitalink://email-verified e vitalink://app/email-verified
    if (uri.path.endsWith('email-verified')) {
      final token = uri.queryParameters['token'] ?? '';
      _router.go('/email-verified?token=$token');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
