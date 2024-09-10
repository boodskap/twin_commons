import 'package:flutter/material.dart';
import 'package:chopper/chopper.dart' as chopper;
import 'package:eventify/eventify.dart' as event;
import 'package:twin_commons/core/twinned_session.dart';
import 'package:google_fonts/google_fonts.dart';

SizedBox divider(
    {bool horizontal = false, double height = 8, double width = 8}) {
  return horizontal
      ? SizedBox(width: width)
      : SizedBox(
          height: height,
        );
}

abstract class BaseState<T extends StatefulWidget> extends State<T> {
  static const TextStyle labelTextStyle =
      TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold);
  static event.EventEmitter layoutEvents = event.EventEmitter();
  static const Widget missingImage = Icon(
    Icons.question_mark,
    size: 25,
  );
  bool loading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool isAsync = willAsync();
      if (isAsync) busy();
      try {
        setup();
      } catch (e, s) {
        debugPrint("$e");
        debugPrint("$s");
      }
      if (isAsync) busy(busy: false);
    });
  }

  void setup();

  bool willAsync() {
    return true;
  }

  void refresh({void Function()? sync}) {
    if (!mounted) return;

    setState(() {
      if (null != sync) {
        sync();
      }
    });
  }

  void busy({busy = true}) {
    emitPageEvent(busy ? PageEvent.busyOn : PageEvent.busyOff,
        sender: this, data: '');
  }

  static void emitPageEvent(PageEvent pe, {Object? sender, Object? data}) {
    layoutEvents.emit(pe.name, sender, data);
  }

  bool validateResponse(chopper.Response r, {bool shouldAlert = true}) {
    if (null == r.body) {
      debugPrint('Error: ${r.bodyString}');
      if (shouldAlert) alert('Api Error', r.bodyString);
      return false;
    }
    if (!r.body.ok) {
      debugPrint('Error: ${r.bodyString}');
      if (shouldAlert) alert('Error', r.body.msg);
      return false;
    }
    return true;
  }

  Future<void> alert(String title, String message,
      {String okText = 'Ok',
      TextStyle? titleStyle,
      TextStyle? contentStyle}) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextStyle titleTextStyle = titleStyle ??
            GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            );
        TextStyle messageTextStyle = contentStyle ??
            GoogleFonts.lato(
              fontSize: 13,
              color: Colors.black,
            );
        return AlertDialog(
          titleTextStyle: titleTextStyle,
          contentTextStyle: messageTextStyle,
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Center(child: Text(message)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(okText,style: messageTextStyle,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future confirm({
    required String title,
    required String message,
    String okButtonText = "Ok",
    String cancelButtonText = "Cancel",
    TextStyle? titleStyle,
    TextStyle? messageStyle,
    required VoidCallback onPressed,
  }) async {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: Text(
        cancelButtonText,
        style: messageStyle,
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );
    Widget continueButton = ElevatedButton(
      child: Text(
        okButtonText,
        style: messageStyle,
      ),
      onPressed: () {
        Navigator.pop(context);
        onPressed();
      },
    );

    AlertDialog alert = AlertDialog(
      elevation: 8,
      title: Text(
        title,
        style: titleStyle,
      ),
      content: Text(
        message,
        style: messageStyle,
        maxLines: 10,
      ),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> alertDialog(
      {required String title,
      required Widget body,
      bool barrierDismissible = true,
      TextStyle? titleStyle,
      // TextStyle? contentStyle,
      double? width,
      double? height}) async {
    width ??= MediaQuery.of(context).size.width / 3;
    height ??= MediaQuery.of(context).size.height / 2;

    TextStyle titleTextStyle = titleStyle ??
        GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        );
    // TextStyle contentTextStyle = contentStyle ??
    //     GoogleFonts.lato(
    //       fontSize: 18,
    //       color: Colors.black,
    //     );
    return showDialog<void>(
      context: context,
      barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: title.isEmpty ? null : Text(title),
          titleTextStyle: titleTextStyle,
          // contentTextStyle: contentTextStyle,
          content: SingleChildScrollView(
            child: SizedBox(width: width, height: height, child: body),
          ),
        );
      },
    );
  }

  Future safeFunction(Future Function() sync, {Function? onError}) async {
    try {
      await sync();
    } catch (e, s) {
      debugPrintStack();
      debugPrint('ERROR: $e');
      if (null != onError) {
        onError();
      } else {
        String errS = e.toString();
        if (errS.contains('ClientException')) {
          alert('Network Error', 'Please check your internet connection');
        } else {
          alert('Error', errS);
        }
      }
    }
  }

  Future execute(Future Function() sync,
      {bool debug = false, Function? onError}) async {
    if (debug) {
      debugPrint('Executing...');
    }
    busy();
    try {
      await sync();
    } catch (e, s) {
      debugPrintStack();
      debugPrint('ERROR: $e');
      if (null != onError) {
        onError();
      } else {
        String errS = e.toString();
        if (errS.contains('ClientException')) {
          alert('Network Error', 'Please check your internet connection');
        } else {
          alert('Error', errS);
        }
      }
    } finally {
      busy(busy: false);
    }
    if (debug) {
      debugPrint('Finished executing');
    }
  }

  bool isAdmin() {
    return TwinnedSession.instance.isAdmin();
  }

  bool isClientAdmin() {
    return TwinnedSession.instance.isClientAdmin();
  }

  bool isClient() {
    return TwinnedSession.instance.isClient();
  }

  bool canCreate() {
    return isAdmin() || isClientAdmin();
  }

  Future<List<String>> getClientIds() async {
    return TwinnedSession.instance.getClientIds();
  }

  Future<bool> canEdit({required List<String>? clientIds}) async {
    if (TwinnedSession.instance.isAdmin()) return true;

    if (TwinnedSession.instance.isClientAdmin()) {
      if (null == clientIds || clientIds!.isEmpty) return false;

      List<String> userClients = await TwinnedSession.instance.getClientIds();

      return userClients.toSet().intersection(clientIds!.toSet()).isNotEmpty;
    }

    return false;
  }
}

enum InfraType { premise, facility, floor, asset }

enum TwinInfraType { premise, facility, floor, asset, device }

enum PageEvent {
  eventCellSelected,
  eventCellRebuild,
  eventRowRebuild,
  eventRebuild,
  themeSwitched,
  desktopWorkAreaSelected,
  tabletWorkAreaSelected,
  mobileWorkAreaSelected,
  portraitModeSelected,
  landscapeModeSelected,
  nocodeCommonComponentsPalette,
  nocodeChartsAndGraphsPalette,
  nocodeConnectorsPalette,
  nocodeIndustryWidgetsPalette,
  iotCommonComponentsPalette,
  iotChartsAndGraphsPalette,
  iotConnectorsPalette,
  iotIndustryWidgetsPalette,
  previewModeToggled,
  componentSelected,
  pageSaveTriggered,
  busyOn,
  busyOff,
  componentRemoved,
  twinMessageReceived,
  teamChanged,
  deviceModelCreated,
  assetModelCreated,
}

enum ScreenWidgetType {
  fillableRectangle,
  fillableCircle,
}
