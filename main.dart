import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:provider/provider.dart';

// MQTT Configuration
const String broker = 'mqtt.eclipse.org'; // Replace with your broker's address
const int port = 1883; // Default MQTT port
const String topic = 'test/topic'; // Replace with your topic

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => MqttProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MQTT Flutter Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MqttProvider with ChangeNotifier {
  MqttServerClient? client;
  List<String> messages = [];

  MqttProvider() {
    _setupMqttClient();
  }

  void _setupMqttClient() async {
    client = MqttServerClient(broker, '');
    client!.port = port;
    client!.logging(on: true);
    client!.onConnected = _onConnected;
    client!.onSubscribed = _onSubscribed;
    client!.onUnsubscribed = _onUnsubscribed;
    client!.onDisconnected = _onDisconnected;
    client!.onMessage = _onMessage;

    try {
      await client!.connect();
    } catch (e) {
      print('MQTT Client connection error: $e');
      client!.disconnect();
    }
  }

  void _onConnected() {
    print('Connected to MQTT Broker');
    client!.subscribe(topic, MqttQos.atMostOnce);
  }

  void _onSubscribed(String topic) {
    print('Subscribed to $topic');
  }

  void _onUnsubscribed(String topic) {
    print('Unsubscribed from $topic');
  }

  void _onDisconnected() {
    print('Disconnected from MQTT Broker');
  }

  void _onMessage(MqttMessage message) {
    final payload = message.payload as MqttPublishPayload;
    final messageText = MqttPublishPayload.bytesToStringAsString(payload.message);
    print('Received message: $messageText');
    messages.add(messageText);
    notifyListeners();
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final mqttProvider = Provider.of<MqttProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Flutter Example'),
      ),
      body: ListView.builder(
        itemCount: mqttProvider.messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(mqttProvider.messages[index]),
          );
        },
      ),
    );
  }
}
