import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attestr_flowx_flutter/attestr_flowx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Attestr',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Attestr Sample App'),
    );
  }
}

List<DropdownMenuItem<bool>> get retryList{
  List<DropdownMenuItem<bool>> menuItems = [
    const DropdownMenuItem(value: true, child: Text("True")),
    const DropdownMenuItem(value: false, child: Text("False")),
  ];
  return menuItems;
}


bool isRetry = false;

TextEditingController handshakeIDController = TextEditingController();
TextEditingController clientKeyController = TextEditingController();

const MethodChannel platform = MethodChannel('attestr_flowx_plugin');

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late AttestrFlowx attestrFlowx;

  @override
  void initState() {
    super.initState();
    attestrFlowx = AttestrFlowx();
    attestrFlowx.on(AttestrFlowx.EVENT_FLOW_COMPLETE, _handleFlowComplete);
    attestrFlowx.on(AttestrFlowx.EVENT_FLOW_SKIP, _handleFlowSkip);
    attestrFlowx.on(AttestrFlowx.EVENT_FLOW_ERROR, _handleFlowError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
              ),
              child: TextField(
                controller: handshakeIDController,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter Handshake ID'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10
              ),
              child: TextField(
                controller: clientKeyController,
                decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'Enter Client Key'
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: DropdownButton<bool>(
                value: isRetry,
                items: retryList,
                disabledHint: const Text("Select Retry"),
                onChanged: (bool? retry) {
                  setState(() {
                    isRetry = retry!;
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              child: OutlinedButton(
                style: TextButton.styleFrom(
                  primary: Colors.blue,
                ),
                onPressed: () {
                  _initiateSession();
                },
                child: const Text("Initiate session"),
              ),
            )
          ],
        ),
      ),

    );
  }

  void _initiateSession() async {
    var params = {
      'hs': handshakeIDController.text,
      'cl': clientKeyController.text,
      'lc': null,
      'retry': isRetry,
      'qr': null
    };
    try {
      attestrFlowx.initiateSession(params);
    } catch (e) {
      print("Inititate session exception: $e");
    }
  }

  _handleFlowComplete(var data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data['signature'].toString()),
    ));
  }

  _handleFlowSkip(var data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data['stage'].toString()),
    ));
  }

  _handleFlowError(var data) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(data['message'].toString()),
    ));
  }

  @override
  void dispose() {
    super.dispose();
    attestrFlowx.clear();
  }

}
