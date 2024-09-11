import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:twin_commons/core/twinned_session.dart';
import 'package:twinned_api/api/twinned.swagger.dart' as twin;
import 'package:http/http.dart' as web;
import 'package:twin_commons/core/picker.dart'
    if (dart.library.html) 'package:twin_commons/core/picker_web.dart'
    if (dart.library.io) 'package:twin_commons/core/picker_io.dart';

class TwinImageHelper {
  static Future<PlatformFile?> pickFile(
      {List<String> allowedExtensions = const [
        'jpg',
        'png',
        'jpeg',
        'JPEG',
        'JPG',
        'PNG'
      ]}) async {
    FilePickerResult? result = await pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: allowedExtensions,
    );

    if (null != result) {
      return result.files.first;
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes?>? _upload(
      web.MultipartRequest mpr, PlatformFile file) async {
    try {
      debugPrint('ApiKey ${TwinnedSession.instance.authToken}');
      mpr.headers['APIKEY'] = TwinnedSession.instance.authToken ?? '';

      mpr.files.add(
        web.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      debugPrint('Uploading...');
      var stream = await mpr.send();
      var response = await stream.stream.bytesToString();

      debugPrint('Decoding response...');
      var map = jsonDecode(response) as Map<String, dynamic>;

      debugPrint('Converting response... ${jsonEncode(map)}');
      return twin.ImageFileEntityRes.fromJson(map);
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes?> uploadDomainIcon() async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.AssetBulkUploadRes?> uploadAssetBulkUpload(
      PlatformFile file,
      {required String premiseId,
      required String facilityId,
      required String floorId,
      required String assetModelId,
      required String deviceModelId,
      required List<String> roleIds,
      required List<String> clientIds}) async {
    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/Asset/bulk/upload",
      ),
    );

    try {
      debugPrint('ApiKey ${TwinnedSession.instance.authToken}');
      mpr.headers['APIKEY'] = TwinnedSession.instance.authToken ?? '';
      mpr.headers['premiseId'] = premiseId;
      mpr.headers['facilityId'] = facilityId;
      mpr.headers['floorId'] = floorId;
      mpr.headers['assetModelId'] = assetModelId;
      mpr.headers['deviceModelId'] = deviceModelId;
      if (clientIds.isNotEmpty) mpr.headers['clientIds'] = clientIds.join(',');
      if (roleIds.isNotEmpty) mpr.headers['roleIds'] = roleIds.join(',');

      mpr.files.add(
        web.MultipartFile.fromBytes('file', file.bytes!, filename: file.name),
      );

      debugPrint('Uploading...');
      var stream = await mpr.send();
      var response = await stream.stream.bytesToString();

      debugPrint('Decoding response...');
      var map = jsonDecode(response) as Map<String, dynamic>;

      debugPrint('Converting response... ${jsonEncode(map)}');
      return twin.AssetBulkUploadRes.fromJson(map);
    } catch (e, s) {
      debugPrint('$e\n$s');
    }

    return null;
  }

  static Future<twin.ImageFileEntityRes?>? uploadDomainImage() async {
    try {
      var file = await pickFile();
      if (null == file) return null;

      var mpr = web.MultipartRequest(
        "POST",
        Uri.https(
          TwinnedSession.instance.host,
          "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}",
        ),
      );

      return _upload(mpr, file);
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  static Future<twin.ImageFileEntityRes?> uploadDomainBanner() async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/domain/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadUserImage(
      {required String userId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/user/$userId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadFloorImage(
      {required String floorId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/floor/$floorId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadAssetImage(
      {required String assetId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/asset/$assetId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadFacilityImage(
      {required String facilityId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/facility/$facilityId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadPremiseImage(
      {required String premiseId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/premise/$premiseId",
      ),
    );

    return _upload(mpr, file);
  }

  static Image getUnCachedDomainImage(String id,
      {double scale = 1.0,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    String domainKey = TwinnedSession.instance.domainKey;
    return Image.network(
      'https://${TwinnedSession.instance.host}/rest/nocode/TwinImage/download/$domainKey/$id',
      scale: scale,
      fit: fit,
      width: width,
      height: height,
    );
  }

  static Widget getDomainImage(String id,
      {double scale = 1.0,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    return getImage(TwinnedSession.instance.domainKey, id,
        scale: scale, fit: fit, width: width, height: height);
  }

  static Widget getImage(String domainKey, String id,
      {double scale = 1.0,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    return getCachedImage(domainKey, id,
        scale: scale, fit: fit, width: width, height: height);
  }

  static Widget getCachedDomainImage(String id,
      {double scale = 1.0,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    return getCachedImage(TwinnedSession.instance.domainKey, id,
        scale: scale, fit: fit, width: width, height: height);
  }

  static Widget getCachedImage(String domainKey, String id,
      {double scale = 1.0,
      BoxFit fit = BoxFit.contain,
      double? width,
      double? height}) {
    bool useCached = true;

    if (kIsWeb) {
      useCached = !Uri.base.toString().contains('localhost');
    }

    if (!useCached) {
      return Image.network(
        'https://${TwinnedSession.instance.host}/rest/nocode/TwinImage/download/$domainKey/$id',
        scale: scale,
        fit: fit,
        width: width,
        height: height,
      );
    }

    return CachedNetworkImage(
      imageUrl:
          "https://${TwinnedSession.instance.host}/rest/nocode/TwinImage/download/$domainKey/$id",
      width: width,
      height: height,
      fit: fit,
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.image),
    );
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceModelIcon(
      {required String modelId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$modelId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceModelImage(
      {required String modelId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}/$modelId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceModelBanner(
      {required String modelId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/model/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}/$modelId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadConditionIcon(
      {required String conditionId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/condition/$conditionId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadAlarmIcon(
      {required String alarmId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/alarm/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$alarmId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDisplayIcon(
      {required String displayId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/display/$displayId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadControlIcon(
      {required String controlId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/control/$controlId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadEventIcon(
      {required String eventId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/event/$eventId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadTriggerIcon(
      {required String triggerId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/trigger/$triggerId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceIcon(
      {required String deviceId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.icon.value}/$deviceId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceImage(
      {required String deviceId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.image.value}/$deviceId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadDeviceBanner(
      {required String deviceId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/device/${twin.TwinImageUploadModelImageTypeModelIdPostImageType.banner.value}/$deviceId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadMenuIcon({
    required int menuIndex,
    required String menuId,
  }) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/menu/$menuIndex/$menuId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadMenuGroupIcon(
      {required String menuGroupId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/menugroup/$menuGroupId",
      ),
    );

    return _upload(mpr, file);
  }

  static Future<twin.ImageFileEntityRes?> uploadScreenBanner(
      {required String screenId}) async {
    var file = await pickFile();
    if (null == file) return null;

    var mpr = web.MultipartRequest(
      "POST",
      Uri.https(
        TwinnedSession.instance.host,
        "/rest/nocode/TwinImage/upload/screen/$screenId",
      ),
    );

    return _upload(mpr, file);
  }
}
