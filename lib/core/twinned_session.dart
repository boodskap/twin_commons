import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:twin_commons/core/base_state.dart';
import 'package:twin_commons/core/storage.dart';
import 'package:twin_commons/util/nocode_utils.dart';
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

  void init({
    required bool debug,
    required String host,
    required String authToken,
    required String domainKey,
    required noCodeAuthToken,
  }) {
    _debug = debug;
    _host = host;
    _authToken = authToken;
    _domainKey = domainKey;
    _noCodeAuthToken = noCodeAuthToken;

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
    _authToken = '';
    _domainKey = '';
    _noCodeAuthToken = '';
    _user = null;
    clients = null;
  }

  static final TwinnedSession _instance = TwinnedSession._privateConstructor();

  digital.TwinSysInfo? twinSysInfo;
  digital.TwinUser? _user;
  List<digital.Client>? clients;

  String _authToken = '';
  String _domainKey = '';
  String _noCodeAuthToken = '';
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
  String get noCodeAuthToken => _noCodeAuthToken;
  digital.Twinned get twin => _twinned;
  lowcode.Nocode get nocode => _nocode;
  verification.Verification get vapi => _vapi;

  Future<digital.TwinUser?> getUser() async {
    if (null == _user) {
      await TwinUtils.execute(() async {
        var res = await twin.getMyProfile(apikey: authToken);
        if (TwinUtils.validateResponse(res)) {
          _user = res.body?.entity;
        }
      });
    }

    return _user;
  }

  bool isAdmin() {
    if (null != _user && null != _user!.platformRoles) {
      digital.TwinUser u = _user!;
      return u.platformRoles!.contains('domainadmin');
    }
    return false;
  }

  bool isClientAdmin() {
    if (null != _user && null != _user!.platformRoles) {
      digital.TwinUser u = _user!;
      return u.platformRoles!.contains('clientadmin');
    }
    return false;
  }

  bool isClient() {
    return (null != _user &&
        null != _user!.clientIds &&
        _user!.clientIds!.isNotEmpty);
  }

  Future<List<digital.Client>> getClients() async {
    if (null == clients &&
        null != _user &&
        null != _user!.clientIds &&
        _user!.clientIds!.isNotEmpty) {
      await TwinUtils.execute(() async {
        var res = await twin.getClients(
            apikey: authToken, body: digital.GetReq(ids: _user!.clientIds!));
        if (TwinUtils.validateResponse(res)) {
          clients = res.body?.values;
        }
      });
    }
    return clients ?? [];
  }
}
