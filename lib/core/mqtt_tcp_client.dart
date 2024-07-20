import 'package:mqtt5_client/mqtt5_client.dart';
import 'package:mqtt5_client/mqtt5_server_client.dart';

MqttClient create(
    {required String mqttUrl,
    required String clientId,
    required int mqttPort}) {
  return MqttServerClient.withPort(mqttUrl, clientId, mqttPort);
}
