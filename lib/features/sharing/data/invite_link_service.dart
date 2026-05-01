import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

abstract interface class InviteLinkService {
  void start(GoRouter router);

  Future<void> dispose();
}

class AppLinksInviteLinkService implements InviteLinkService {
  AppLinksInviteLinkService({AppLinks? appLinks})
    : _appLinks = appLinks ?? AppLinks();

  final AppLinks _appLinks;
  StreamSubscription<Uri>? _subscription;

  @override
  void start(GoRouter router) {
    _subscription ??= _appLinks.uriLinkStream.listen((uri) {
      final location = inviteAcceptLocationFromUri(uri);
      if (location == null) return;
      router.go(location);
    });
  }

  @override
  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}

String? inviteAcceptLocationFromUri(Uri uri) {
  final token = uri.queryParameters['token'];
  if (token == null || token.isEmpty) return null;
  if (uri.path != '/invite' && !uri.path.endsWith('/invite')) return null;
  return Uri(
    path: AppRoutes.inviteAccept,
    queryParameters: {'token': token},
  ).toString();
}
