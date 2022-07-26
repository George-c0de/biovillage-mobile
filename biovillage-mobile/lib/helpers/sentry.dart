import 'package:sentry/sentry.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

export 'package:sentry/sentry.dart';

class Sentry {
  static final String dsn = DotEnv().env['SENTRY_DSN'];
  static final client = SentryClient(dsn: dsn);
}
