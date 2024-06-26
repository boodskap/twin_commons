import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:twin_commons/core/storage.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as digital;
import 'package:nocode_api/api/nocode.swagger.dart' as lowcode;
import 'package:verification_api/api/verification.swagger.dart' as verification;

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
      String host = 'rest.boodskap.io',
      String authToken = '',
      String domainKey = ''}) {
    _debug = debug;
    _host = host;
    _authToken = authToken;
    _domainKey = domainKey;

    _twinned =
        digital.Twinned.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    _nocode = lowcode.Nocode.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    _vapi = verification.Verification.create(
        baseUrl: Uri.https(_host, '/rest/nocode'));

    debugPrint('HOST: $_host, DomainKey: $domainKey, ApiKey: $authToken');
  }

  Future cleanup() async {
    return SessionManager().destroy();
  }

  void logout() {
    Storage.remove('session');
  }

  static final TwinnedSession _instance = TwinnedSession._privateConstructor();

  digital.TwinSysInfo? twinSysInfo;

  String _authToken = '';
  String _domainKey = '';
  bool _debug = true;
  String _host = '';
  late digital.Twinned _twinned;
  late lowcode.Nocode _nocode;
  late verification.Verification _vapi;

  static TwinnedSession get instance => _instance;

  String get host => _host;
  bool get debug => _debug;
  String get authToken => _authToken;
  String get domainKey => _domainKey;
  digital.Twinned get twin => _twinned;
  lowcode.Nocode get nocode => _nocode;
  verification.Verification get vapi => _vapi;
}
