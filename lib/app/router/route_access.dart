/// Access policy of a route.
///
/// The application is guest-first: everything visible before login is
/// [public]. Only genuinely protected destinations (checkout/payment,
/// account/profile, personal orders, persistent favorites, ...) are
/// [authenticated].
///
/// Future contract (implemented with the real authentication feature):
///
///   user requests an [authenticated] route
///     -> session check fails
///     -> redirect to login, remembering the intended destination
///        (passed as a typed parameter, e.g. a `redirectLocation` string)
///     -> successful authentication
///     -> router resumes the originally requested destination.
///
/// No route is marked authenticated yet because authentication does not
/// exist in this phase; do NOT flip routes to [authenticated] speculatively.
enum RouteAccess { public, authenticated }
