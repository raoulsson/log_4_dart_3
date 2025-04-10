import 'package:mysql1/mysql1.dart';

import '../../log_4_dart_3.dart';

///
/// A appender to store log entries in a mysql database
///
class MySqlAppender extends Appender {
  /// The host for the mysql database
  String? host;

  /// The user for the database
  String? user;

  /// The password of the user for the database
  String? password;

  /// The port of the database
  int? port;

  /// The database name on the host
  String? database;

  /// The table name to log to
  String? table;

  late MySqlConnection _connection;
  late ConnectionSettings _connectionSettings;

  @override
  void append(LogRecord logRecord) async {
    logRecord.loggerName ??= getType();
    await _connection.query(
        'insert into $table (tag, level, message, time) values (?, ?, ?, ?)', [
      logRecord.tag,
      logRecord.level.name,
      logRecord.message,
      logRecord.time.toUtc()
    ]);
  }

  @override
  String toString() {
    return '$type $host $port $user $level';
  }

  @override
  Future<void>? init(
      Map<String, dynamic> config, bool test, DateTime? date) async {
    created = date ?? DateTime.now();
    type = AppenderType.MYSQL;
    if (config.containsKey('level')) {
      level = Level.fromString(config['level']);
    } else {
      level = Level.INFO;
    }
    if (config.containsKey('host')) {
      host = config['host'];
    } else {
      throw ArgumentError('Missing host argument for MySqlAppender');
    }
    if (config.containsKey('user')) {
      user = config['user'];
    } else {
      throw ArgumentError('Missing user argument for MySqlAppender');
    }
    if (config.containsKey('password')) {
      password = config['password'];
    }
    if (config.containsKey('port')) {
      port = config['port'];
    } else {
      throw ArgumentError('Missing port argument for MySqlAppender');
    }
    if (config.containsKey('database')) {
      database = config['database'];
    } else {
      throw ArgumentError('Missing database argument for MySqlAppender');
    }
    if (config.containsKey('table')) {
      table = config['table'];
    } else {
      throw ArgumentError('Missing table argument for MySqlAppender');
    }
    if (!test) {
      _connectionSettings = ConnectionSettings(
          host: host!,
          port: port!,
          user: user,
          password: password,
          db: database);
      _connection = await MySqlConnection.connect(_connectionSettings);
    }
    return null;
  }

  @override
  Appender getInstance() {
    return MySqlAppender();
  }

  @override
  String getType() {
    return AppenderType.MYSQL.name;
  }
}
