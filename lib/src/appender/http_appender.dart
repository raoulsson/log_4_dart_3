import 'package:basic_utils/basic_utils.dart';

import '../../log_4_dart_3.dart';
import '../log_record_formatter.dart';

///
/// A appender for sending log entries via http
///
class HttpAppender extends Appender {
  /// The destination for the http post request
  String? url;

  /// The headers to send with the request
  Map<String, String>? headers;

  @override
  void append(LogRecord logRecord) {
    logRecord.loggerName ??= getType();
    var body = LogRecordFormatter.formatJson(logRecord, dateFormat: dateFormat);
    HttpUtils.postForFullResponse(url!, body: body, headers: headers);
  }

  @override
  String toString() {
    return '$type $url $level';
  }

  @override
  Future<void>? init(Map<String, dynamic> config, bool test, DateTime? date) {
    created = date ?? DateTime.now();
    type = AppenderType.HTTP;
    if (config.containsKey('level')) {
      level = Level.fromString(config['level']);
    } else {
      level = Level.INFO;
    }
    if (config.containsKey('dateFormat')) {
      dateFormat = config['dateFormat'];
    } else {
      dateFormat = Appender.defaultDateFormat;
    }
    if (config.containsKey('url')) {
      url = config['url'];
    } else {
      throw ArgumentError('Missing url argument for HttpAppender');
    }
    headers = {};
    if (config.containsKey('headers')) {
      List<String> h = config['headers'];
      for (var s in h) {
        var splitted = s.split(':');
        headers!
            .putIfAbsent(splitted.elementAt(0), () => splitted.elementAt(1));
      }
    }
    return null;
  }

  @override
  Appender getInstance() {
    return HttpAppender();
  }

  @override
  String getType() {
    return AppenderType.HTTP.name;
  }
}
