import 'dart:convert';
import 'dart:async' as async;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiUrl = "https://api.hgbrasil.com/finance?format=json&key=3e14c5c6";

void main() async {
  runApp(MaterialApp(
      home: Home(),
      theme: ThemeData(
          brightness: Brightness.dark,
          hintColor: Colors.white,
          primaryColor: Colors.white,
          inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white))))));
}

Future<Map> getData() async {
  http.Response response = await http.get(apiUrl);
  return json.decode(response.body)["results"];
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dollarController = TextEditingController();
  final eurController = TextEditingController();

  double dollar;
  double eur;

  void _realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }
    double real = double.parse(text);
    dollarController.text = (real / dollar).toStringAsFixed(2);
    eurController.text = (real / eur).toStringAsFixed(2);
  }

  void _dollarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double dollar = double.parse(text);
    realController.text = (dollar = dollar * this.dollar).toStringAsFixed(2);
    eurController.text = (dollar = this.dollar / eur).toStringAsFixed(2);
  }

  void _eurChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
      return;
    }

    double eur = double.parse(text);
    realController.text = (eur = this.eur).toStringAsFixed(2);
    dollarController.text = (eur = this.eur / dollar).toStringAsFixed(2);
  }

  void _clearAll() {
    realController.text = "";
    dollarController.text = "";
    eurController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Currency Converter"),
        backgroundColor: Colors.deepOrange,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
          future: getData(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return Center(
                  child: Text(
                    "Loading data..",
                    style: TextStyle(color: Colors.deepOrange, fontSize: 25.0),
                    textAlign: TextAlign.center,
                  ),
                );
              default:
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error",
                      style:
                          TextStyle(color: Colors.deepOrange, fontSize: 25.0),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else {
                  dollar = snapshot.data["currencies"]["USD"]["buy"];
                  eur = snapshot.data["currencies"]["EUR"]["buy"];

                  return SingleChildScrollView(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(Icons.monetization_on,
                            size: 150.0, color: Colors.deepOrange),
                        buildTextField(
                            'BRL', 'R\$', realController, _realChanged),
                        Divider(),
                        buildTextField(
                            'USD', 'USD', dollarController, _dollarChanged),
                        Divider(),
                        buildTextField(
                            'EUR', 'EUR', eurController, _eurChanged),
                      ],
                    ),
                  );
                }
            }
          }),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController txtE, Function func) {
  return TextField(
    controller: txtE,
    decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.deepOrange),
        border: OutlineInputBorder(),
        prefixText: prefix),
    style: TextStyle(color: Colors.deepOrange),
    onChanged: func,
    keyboardType: TextInputType.number,
  );
}
