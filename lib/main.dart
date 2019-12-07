import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trovu',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Trovu'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController queryController = new TextEditingController();
  TextEditingController languageController = new TextEditingController();
  TextEditingController countryController = new TextEditingController();
  TextEditingController githubUsernameController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.settings), onPressed: _settings),
        ],
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: queryController,
                      textInputAction: TextInputAction.send,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Enter a Trovu query'),
                      onSubmitted: (text) {
                        _processQuery();
                      },
                    ),
                  ),
                  FlatButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    disabledColor: Colors.blue[100],
                    child: Icon(Icons.search),
                    onPressed: () {
                      _processQuery();
                    },
                  )
                ],
          )),
        ],
      ),
    );
  }

  void _settings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
              appBar: AppBar(
                title: Text('Settings'),
              ),
              body: ListView(
                children: <Widget>[
                  ListTile(
                    title: TextField(
                      controller: githubUsernameController,
                      decoration: InputDecoration(hintText: 'Github user name'),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: languageController,
                      decoration: InputDecoration(hintText: 'Language code'),
                    ),
                  ),
                  ListTile(
                    title: TextField(
                      controller: countryController,
                      decoration: InputDecoration(hintText: 'Country code'),
                    ),
                  ),
                ],
              ));
        },
      ),
    );
  }

  void _processQuery() {
    final String baseUrl = 'https://trovu.net/process#';
    String paramString;
    if (this.githubUsernameController.text.isEmpty) {
      paramString = 'language=' +
          this.languageController.text +
          '&country=' +
          this.countryController.text +
          '&';
    } else {
      paramString = 'github=' + this.githubUsernameController.text + '&';
    }
    final url = baseUrl + paramString + 'query=' + queryController.text;
    launch(url);
  }
}
