# NutriSafe Mitra

Flutter foundation exclusively for Mitra/SPPG users of the MBG system. No School,
Student, Admin, or business workflows are implemented.

## Run

Use the Flutter SDK compatible with `pubspec.yaml` (verified with Flutter 3.47.5,
Dart 3.13.4). Run `flutter pub get`, then `flutter run`.
Without API configuration the app still opens the login availability page; network
requests fail locally with a configuration failure.

Supply the actual backend HTTPS base URL through
`flutter run --dart-define=API_BASE_URL=<backend-base-url>`.
Use a trailing slash when the base URL contains an API path prefix, and relative
paths in data sources to preserve that prefix. Do not put secrets in dart-defines.
No API endpoint, credentials schema, or response envelope has been assumed.

## Structure

```text
lib/
  main.dart                         Bootstrap and composition root
  app/
    app.dart                        MaterialApp, provider, router lifecycle
    di/dependencies.dart            get_it registration and disposal
    router/app_router.dart          Redirect policy, splash, shell, fallback
    theme/app_theme.dart            Shared Material 3 theme
  core/
    error/app_failure.dart          Failure categories and safe UI messages
    network/api_config.dart         Build-time API configuration
    network/dio_factory.dart        Timeouts, authorization, error interceptor
    storage/token_store.dart       Injectable secure token persistence
  features/
    auth/
      data/auth_gateway.dart        Contract-independent login boundary
      data/session_repository.dart  Local token/session persistence
      presentation/login_page.dart  Availability placeholder, no fake login
      presentation/session_cubit.dart
```

Add constants, widgets, utils, domain layers, and use cases only when actual code
needs them. The starter counter and its obsolete test have been replaced; native
platform scaffolding and existing lint configuration are retained.

## Dependencies

Added flutter_bloc, go_router, Dio, get_it, equatable, and flutter_secure_storage.
flutter_secure_storage provides platform secure storage rather than preferences
for tokens. Existing cupertino_icons and flutter_lints are retained. Resolved
versions are committed in pubspec.lock. No GetX or code generation is used.

## Routing and session lifecycle

The app starts at `/splash` while SessionCubit restores storage. A missing/blank
token routes to `/login`; a stored token routes to `/` inside the application
shell. All other locations require an authenticated local session. Authenticated
unknown locations show the not-found page. Anonymous unknown locations redirect
to login. Login and splash redirect to home after authentication. Requested deep
links are not retained across login in this foundation.

SessionCubit has no navigation dependency. Its stream refreshes go_router through
a disposable ChangeNotifier bridge. BlocProvider exposes the injected singleton
without owning it; get_it owns and closes it. Tests dispose app/router before
calling `di.reset()`.

`AuthGateway<Credentials>` is the deliberately unimplemented backend boundary.
When the contract arrives, define real credential types and a Dio-backed gateway,
normalize the documented response to an access token, and enforce Mitra/SPPG
access according to the backend contract. Add a login Cubit/repository as needed;
only successful real authentication may call `acceptAuthenticatedToken`.
Never insert demonstration tokens into the production app.

Restoration currently means a token exists locally, not that the backend has
validated it. The backend remains authoritative. Refresh, expiry parsing, remote
validation, role claims, and server logout/revocation are deferred until their
contracts exist. Logout currently clears the local session only.

Storage mutations are serialized. Authenticated 401 responses clear only the
session whose token was sent, protecting a newer login from delayed responses.
Storage failures block protected routes and offer a clear-session retry; failed
storage deletion is never reported as successful logout.

## Networking and errors

UI -> Cubit/Bloc -> feature repository -> data source/Dio -> backend.
Repositories catch technical failures and map them with `AppFailure.from` before
emitting failure state. UI renders `failure.message`, never exception strings or
backend response bodies. Supported categories: network, timeout, unauthorized,
server, unexpected, configuration, and storage.

Dio preserves response data for feature-specific decoding; no global response
schema is invented. Defaults include 15-second connection and 30-second send/read
timeouts. The bearer header is attached only for the configured HTTPS origin.
Automatic redirects are disabled. Public calls such as a future login request use
`Options(extra: {'requiresAuth': false})`. No automatic retry, token refresh, or
request logging is installed. Do not log request options containing credentials.
The bearer scheme is a centralized integration assumption to confirm against the
backend contract. Additional interceptors belong in the factory.

Android release network permission is enabled and application backup is disabled
for secure token storage. Native secure storage and networking must still be
smoke-tested on Android/iOS hardware before release. Follow the package's platform
requirements if enabling additional targets:
https://pub.dev/packages/flutter_secure_storage

## Adding the next SPPG feature

1. Obtain its real backend endpoint, authorization, and payload contract.
2. Add `features/<feature>/data` and `presentation` with only needed models,
   repository/data source, Cubit/state, and page. Add domain only for reusable
   business rules or a useful independent boundary.
3. Constructor-inject Dio into data sources, repositories into Cubits, and provide
   Cubits at the route boundary. Register repositories as lazy singletons and
   page-owned Cubits as factories in `app/di/dependencies.dart`.
4. Construct dependencies in the composition layer and pass them into pages or
   route builders. Do not call get_it from UI widgets.
5. Add the protected route under ShellRoute. Keep navigation in presentation.
6. Test repository response/error mapping and meaningful state transitions, plus
   one page integration test where appropriate.

Use Cubit for fetching lists, dashboard/profile state, or straightforward updates.
Use Bloc when meaningful events and complex transitions/concurrency justify it.
Use local StatefulWidget state for password visibility, expansion, tabs, and
transient form UI. Do not add a Cubit for every widget.

## Verification

```sh
flutter pub get
dart format lib test
flutter analyze
flutter test
```

Tests use in-memory storage and an HTTP adapter, never a real authentication API.
They cover session persistence, restoration, logout, storage failure recovery,
stale 401s, protected routes, not-found navigation, header isolation, configuration
failure, response decoding, and error classification.
