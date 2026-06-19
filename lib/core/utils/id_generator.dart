import 'package:uuid/uuid.dart';

class IdGenerator {
  static const _uuid = Uuid();

  /// Generates a UUID v4 string which is compatible with most backend systems.
  static String generate() => _uuid.v4();
}
