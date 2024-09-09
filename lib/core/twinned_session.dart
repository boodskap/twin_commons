import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:twin_commons/util/nocode_utils.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as digital;
import 'package:nocode_api/api/nocode.swagger.dart' as lowcode;
import 'package:verification_api/api/verification.swagger.dart' as verification;
import 'package:pulse_admin_api/pulse_admin_api.dart' as pulse;

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
    required orgId,
  }) {
    _debug = debug;
    _host = host;
    _authToken = authToken;
    _domainKey = domainKey;
    _noCodeAuthToken = noCodeAuthToken;
    _orgId = orgId;
    _user = null;
    _clients = null;

    _twinned =
        digital.Twinned.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    _nocode = lowcode.Nocode.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    _vapi = verification.Verification.create(
        baseUrl: Uri.https(_host, '/rest/nocode'));

    _pulseAdmin =
        pulse.PulseAdmin.create(baseUrl: Uri.https(_host, '/rest/nocode'));

    debugPrint(
        'HOST: $_host, DomainKey: $domainKey, ApiKey: $authToken, OrgId: $orgId, NoCodeAuthToken: $noCodeAuthToken');
  }

  Future cleanup() async {
    return SessionManager().destroy();
  }

  void logout() {
    _authToken = '';
    _noCodeAuthToken = '';
    _user = null;
    _clients = null;
  }

  static final TwinnedSession _instance = TwinnedSession._privateConstructor();

  digital.TwinSysInfo? twinSysInfo;
  digital.TwinUser? _user;
  List<digital.Client>? _clients;

  String _authToken = '';
  String _domainKey = '';
  String _noCodeAuthToken = '';
  bool _debug = true;
  String _host = '';
  String _orgId = '';
  late digital.Twinned _twinned;
  late lowcode.Nocode _nocode;
  late verification.Verification _vapi;
  late pulse.PulseAdmin _pulseAdmin;

  static TwinnedSession get instance => _instance;

  String get host => _host;
  bool get debug => _debug;
  String get authToken => _authToken;
  String get domainKey => _domainKey;
  String get noCodeAuthToken => _noCodeAuthToken;
  String get orgId => _orgId;
  digital.Twinned get twin => _twinned;
  lowcode.Nocode get nocode => _nocode;
  verification.Verification get vapi => _vapi;
  pulse.PulseAdmin get pulseAdmin => _pulseAdmin;

  Future<digital.TwinUser?> getUser() async {
    if (null == _user) {
      await TwinUtils.execute(() async {
        var res = await twin.getMyProfile(apikey: authToken, orgId: _orgId);
        if (TwinUtils.validateResponse(res)) {
          _user = res.body?.entity;
        }
      });
    }

    return _user;
  }

  void setUser(digital.TwinUser user) {
    _user = user;
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
    if (null == _clients &&
        null != _user &&
        null != _user!.clientIds &&
        _user!.clientIds!.isNotEmpty) {
      await TwinUtils.execute(() async {
        var res = await twin.getClients(
            apikey: authToken, body: digital.GetReq(ids: _user!.clientIds!));
        if (TwinUtils.validateResponse(res)) {
          _clients = res.body?.values;
        }
      });
    }
    return _clients ?? [];
  }

  Future<List<String>> getClientIds() async {
    List<digital.Client> clients = await getClients();

    if (clients.isNotEmpty) {
      List<String> ids = [];
      for (var c in clients) {
        ids.add(c.id);
      }
      return ids;
    }

    return [];
  }

  Future<digital.Usage> getUsage() async {
    await TwinUtils.execute(() async {
      var res = await twin.getUsageByDomainKey(domainKey: _domainKey);
      if (TwinUtils.validateResponse(res)) {
        return res.body!.entity!;
      }
    });
    return const digital.Usage(
        usedPooledDataPoints: 0,
        usedDataPoints: 0,
        usedDeviceModels: 0,
        usedDevices: 0,
        usedUsers: 0,
        usedClients: 0,
        usedDashboards: 0,
        availablePooledDataPoints: 0,
        availableDataPoints: 0,
        availableDevices: 0,
        availableUsers: 0,
        availableClients: 0,
        availableDashboards: 0);
  }
}
