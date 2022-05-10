import 'package:flutter/material.dart';
import 'package:connectanum/connectanum.dart';
import 'package:connectanum/json.dart';

var session;

void main() {
  runApp(const MaterialApp(
    home: Home(),
  ));
}

Future<void> connect() async {
  final client1 = Client(
      realm: 'realm1',
      transport: WebSocketTransport(
        'ws://192.168.100.116:8080/ws',
        Serializer(),
        WebSocketSerialization.SERIALIZATION_JSON,
      ));
  late Session session1;
  session1 = await client1
      .connect(
          options: ClientConnectOptions(
        reconnectCount: 10,
        reconnectTime: Duration(milliseconds: 200),
      ))
      .first;
  session = session1;
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("WAMP"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              onPressed: () async {
                await session
                    .publish('test', arguments: ['This is a push message']);
              },
              child: Text("Publish"),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.blue),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final subscription = await session.subscribe('test');
                subscription.eventStream!
                    .listen((event) => print(event.arguments![0]));
                await subscription.onRevoke.then((reason) => print(
                    'The server has killed my subscription due to: ' + reason));
              },
              child: Text("Subscribe"),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.blue),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                session.call('test').listen(
                    (result) => print(result.arguments![0]), onError: (e) {
                  var error = e as Error; // type cast necessary
                  print(error.error);
                });
              },
              child: Text("call"),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.blue),
            ),
          ),
          SizedBox(
            height: 20.0,
          ),
          Center(
            child: TextButton(
              onPressed: () async {
                final registered = await session.register('test');
                registered.onInvoke((invocation) =>
                    invocation.respondWith(arguments: ['1.1.0']));
              },
              child: Text("register"),
              style: TextButton.styleFrom(
                  primary: Colors.white, backgroundColor: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    connect();
  }
}
