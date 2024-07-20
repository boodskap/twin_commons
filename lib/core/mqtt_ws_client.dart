import 'package:mqtt5_client/mqtt5_browser_client.dart';
import 'package:mqtt5_client/mqtt5_client.dart';

MqttClient create(
    {required String mqttUrl,
    required String clientId,
    required int mqttPort}) {
  return MqttBrowserClient.withPort(mqttUrl, clientId, mqttPort);
}
