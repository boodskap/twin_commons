import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:twin_commons/core/base_state.dart';

import 'mqtt_tcp_client.dart' if (dart.library.html) 'mqtt_ws_client.dart'
    as mqtt;

class MqttConnection {
  static final MqttConnection _instance = MqttConnection._internal();

  MqttClient? _client;
  final List<MqttSubscription> _subs = [];

  factory MqttConnection() {
    return _instance;
  }

  MqttConnection._internal() {
    if (null != _client) {
      _client!.disconnect();
      _client = null;
    }
  }

  Future connect(
      {required mqttUrl,
      required int mqttPort,
      required String domainKey,
      required String authToken,
      required int connCounter}) async {
    if (null != _client) return;

    try {
      if (null == _client) {
        final String clientId = '$authToken:$connCounter';
        _client = mqtt.create(
            mqttUrl: mqttUrl, mqttPort: mqttPort, clientId: clientId);
        _client!.logging(on: false);
        _client!.onConnected = _onConnected;
        _client!.onDisconnected = _onDisconnected;
        _client!.onUnsubscribed = _onUnsubscribed;
        _client!.onSubscribed = _onSubscribed;
        _client!.onSubscribeFail = _onSubscribeFail;
        _client!.pongCallback = _pong;
        _client!.keepAlivePeriod = 60;
        _client!.autoReconnect = true;
        _client!.connectionMessage =
            MqttConnectMessage().withClientIdentifier(clientId).startClean();
      }

      await _client!.connect();

      if (_client!.connectionStatus?.state == MqttConnectionState.connected) {
        final String topic = '/$domainKey/log/twin/#';
        _client?.subscribe(topic, MqttQos.atLeastOnce);

        _client?.updates.listen(cancelOnError: false,
            (List<MqttReceivedMessage<MqttMessage>> c) async {
          try {
            final MqttPublishMessage message =
                c[0].payload as MqttPublishMessage;
            String payload =
                const AsciiDecoder().convert(message.payload.message!);

            debugPrint('topic:${c[0].topic} message:$payload');

            final Map<String, dynamic> msg = jsonDecode(payload);

            switch (msg['type'] ?? 'unknown') {
              case 'message':
                BaseState.layoutEvents.emit(PageEvent.twinMessageReceived.name,
                    this, msg['deviceId'] as String);
                break;
              default:
                debugPrint('unknown message type:${msg['type']} discarded');
                break;
            }
          } catch (e, s) {
            debugPrint('$e\n$s');
          }
        });
      }
    } catch (e, s) {
      debugPrint('$e\n$s');
    }
  }

  void disconnect() {
    if (null == _client) return;
    _client?.disconnect();
    _client = null;
  }

  void _onConnected() {
    debugPrint('Connected, now subscribing...');
  }

  void _onDisconnected() {
    debugPrint('Disconnected');
  }

  void _onSubscribed(MqttSubscription sub) {
    debugPrint('Subscribed topic: ${sub.topic}');
    //_subs.add(sub);
  }

  void _onSubscribeFail(MqttSubscription sub) {
    debugPrint('Failed to subscribe topic: ${sub.topic}');
  }

  void _onUnsubscribed(MqttSubscription sub) {
    debugPrint('Unsubscribed topic: ${sub.topic}');
  }

  void _pong() {
    debugPrint('Ping response client callback invoked');
  }
}
