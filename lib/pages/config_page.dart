import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../settings.dart';

class ConfigPage extends StatefulWidget {
  Function? onSave;

  ConfigPage({Key? key, this.onSave}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConfigPage();
}

class _ConfigPage extends State<ConfigPage> {
  late TextEditingController _tokenController;
  late TextEditingController _numberController;
  late bool _sendHeartbeat;

  _ConfigPage() {
    _tokenController = TextEditingController(text: AppSettings.getBotToken());
    _numberController = TextEditingController();
    var number = AppSettings.getNumber();
    if (number != null) {
      _numberController.text = number.toString();
    }
    _sendHeartbeat = AppSettings.getSendheartbeat();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Text("Application settings",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: "Bot token", border: OutlineInputBorder()),
              controller: _tokenController,
            ),
          ),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                    labelText: "Number",
                    border: OutlineInputBorder(),
                    helperText:
                        "Send a message to this number in case of any errors occur"),
                controller: _numberController,
              )),
          CheckboxListTile(
              value: _sendHeartbeat,
              title: const Text("Send an SMS when the service turns on/off)"),
              onChanged: (x) {
                setState(() {
                  _sendHeartbeat = x!;
                });
              }),
          const SizedBox(height: 50),
          SizedBox(
              width: 100,
              child: ElevatedButton(
                  onPressed: () async {
                    await AppSettings.setBotToken(_tokenController.text);
                    await AppSettings.setNumer(_numberController.text.isEmpty
                        ? 0
                        : int.parse(_numberController.text));
                    await AppSettings.setHeartbeat(_sendHeartbeat);
                    widget.onSave!();
                  },
                  child: const Text("Save")))
        ],
      ),
    );
  }
}
