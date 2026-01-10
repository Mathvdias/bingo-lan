import 'package:bingo_core/src/drivers/i_uuid_driver.dart';
import 'package:uuid/uuid.dart';

class UUIDDriver implements IUUIDDriver {
  final Uuid _uuid = const Uuid();

  @override
  String v4() {
    return _uuid.v4();
  }
}
