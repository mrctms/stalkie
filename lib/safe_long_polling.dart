import 'package:teledart/teledart.dart';
import 'package:teledart/telegram.dart';

class SafeLongPolling extends AbstractUpdateFetcher {
  final Telegram telegram;

  final maxTimeout = 50;

  int offset;
  int limit;
  int timeout;

  bool _isPolling = false;
  bool get isPolling => _isPolling;

  SafeLongPolling(this.telegram,
      {this.offset = 0, this.limit = 100, this.timeout = 30}) {
    if (limit > 100 || limit < 1) {
      throw LongPollingException('Limit must between 1 and 100.');
    }
    if (timeout > maxTimeout) {
      throw LongPollingException('Timeout may not greater than $maxTimeout.');
    }
  }

  @override
  Future stop() {
    if (_isPolling) _isPolling = false;
    return Future.value();
  }

  @override
  Future start() {
    if (!_isPolling) {
      _isPolling = true;
      return _recursivePolling();
    } else {
      throw LongPollingException('A long poll is aleady inplace');
    }
  }

  Future<void> _recursivePolling() async {
    try {
      if (_isPolling) {
        var updates = await telegram.getUpdates(
            offset: offset, limit: limit, timeout: timeout);
        if (updates.isNotEmpty) {
          for (var update in updates) {
            emitUpdate(update);
            offset = update.update_id + 1;
          }
        }
        _recursivePolling();
      }
    } catch (e) {
      _recursivePolling();
    }
  }
}
