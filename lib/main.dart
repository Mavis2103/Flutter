import 'dart:async';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'dart:convert' show utf8;
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html;
import 'package:xml/xml.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  Future fetchRss() async {
    var _rp = await http.get(
      Uri.parse('https://vnexpress.net/rss/the-thao.rss'),
      headers: {
        'Content-Type': 'application/rss+xml;charset:utf8',
        'Charset': 'utf8'
      },
    );
    var arr = [];
    XmlDocument.parse(_rp.body)
        .findAllElements('item')
        .forEach((e) => arr.add(e));
    // print((html
    //     .parse(arr[0].getElement('description').text)
    //     .getElementsByTagName('img')[0]
    //     .attributes));
    // print((html.parse(arr[0].getElement('description').text).body.text));
    // print(HtmlP);

    return arr;
  }

  String utf8Convert(string) => utf8.decode(string.toString().codeUnits);

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10),
        child: FutureBuilder(
          future: fetchRss(),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data;
              return ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  String getText(name) =>
                      utf8Convert(data[index].getElement(name).text);
                  var title = getText('title');
                  var description = html.parse(getText('description'));
                  var image =
                      description.getElementsByTagName('img')[0].attributes;
                  var date = getText('pubDate');
                  var link = getText('link');
                  // print(data[index].getElement('guid').text);
                  var slash = getText('slash:comments');
                  return Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20)),
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.only(bottom: 20),
                    child: Column(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            title,
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: EdgeInsets.only(bottom: 20),
                          child: Text(
                            date,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network('${image["src"]}')),
                        Container(
                            padding: EdgeInsets.only(top: 20),
                            child: Text(description.body.text)),
                        // Text(link),
                        // Text(slash)
                      ],
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }
}
