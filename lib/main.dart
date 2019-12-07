import 'dart:math';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String language = '';
  String country = '';
  String githubUsername = '';
  List<String> recentShortcuts = [];

  _MyHomePageState() {
    _getSettings();
  }

  Future _setSettings() async {
    final prefs = await SharedPreferences.getInstance();

    this.githubUsername = this.githubUsernameController.text;
    this.language = this.languageController.text;
    this.country = this.countryController.text;

    prefs.setString('githubUsername', this.githubUsername);
    prefs.setString('language', this.language);
    prefs.setString('country', this.country);
    prefs.setStringList('recentShortcuts', this.recentShortcuts);
  }

  Future _getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    this.githubUsername = prefs.getString('githubUsername');
    this.language = prefs.getString('language');
    this.country = prefs.getString('country');
    this.recentShortcuts = prefs.getStringList('recentShortcuts') ?? [];

    this.githubUsernameController.text = this.githubUsername;
    this.languageController.text = this.language;
    this.countryController.text = this.country;

    // Trigger redraw.
    // TODO: Probably can be done cleaner.
    setState(() { });
  }

  @override
  Widget build(BuildContext context) {

    final List<ListTile> recentShortcutsTiles = recentShortcuts.map(
      (String recentShortcut) {
        return ListTile(
          title: Text(recentShortcut),
          onTap: () {
            queryController.text = recentShortcut;
            // Hack to set cursor position to the end.
            // From https://github.com/flutter/flutter/issues/11416#issuecomment-541435871
            final selection = TextSelection.collapsed(offset: queryController.text.length); 
            queryController.selection = selection;
          },
        );
      },
    ).toList();
    final List<Widget> recentShortcutsTilesDivided = ListTile.divideTiles(
      context: context,
      tiles: recentShortcutsTiles,
    ).toList();
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
                  autofocus: true,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
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
          ListTile(
            title: Text('Recent shortcuts:'),
          )
        ] + recentShortcutsTilesDivided,
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
                      onChanged: (text) {
                        _setSettings();
                      },
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

    final String query = queryController.text;
    final String url = baseUrl + paramString + 'query=' + query;

    setState(() {
      final String keyword = query.split(' ').first;
      if (keyword.isNotEmpty) {
        this.recentShortcuts.insert(0, keyword);
        this.recentShortcuts = this.recentShortcuts.toSet().toList();
        this.recentShortcuts = this.recentShortcuts.sublist(0, min(this.recentShortcuts.length, 20));
        _setSettings();
      }
    });
    launch(url);
    //print(url);
  }
}
