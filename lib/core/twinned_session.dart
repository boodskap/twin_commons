import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as digital;

class TwinnedSession {
  TwinnedSession._privateConstructor() {
    _load();
  }

  Future _load() async {
    //await dotenv.load(fileName: 'settings.txt');
    //var session = SessionManager();
    //await session.update();
  }

  void init(
      {bool debug = true,
      String host = 'twinned.digital',
      String authToken = '',
      String domainKey = ''}) {
    _debug = debug;
    _host = host;
    _authToken = authToken;
    _domainKey = domainKey;

    _twinned =
        digital.Twinned.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    debugPrint('HOST: $_host, DomainKey: $domainKey, ApiKey: $authToken');
  }

  Future cleanup() async {
    return SessionManager().destroy();
  }

  static final TwinnedSession _instance = TwinnedSession._privateConstructor();

  digital.TwinSysInfo? twinSysInfo;

  String _authToken = '';
  String _domainKey = '';
  bool _debug = true;
  String _host = '';
  digital.Twinned _twinned = digital.Twinned.create(
      baseUrl: Uri.https('twinned.boodskap.io', '/rest/nocode'));

  static TwinnedSession get instance => _instance;

  String get host => _host;
  bool get debug => _debug;
  String get authToken => _authToken;
  String get domainKey => _domainKey;
  digital.Twinned get twin => _twinned;
}
