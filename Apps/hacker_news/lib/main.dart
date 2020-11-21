import 'package:flutter/material.dart';
import 'package:hacker_news/src/article.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
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
  List<int> _ids = [
    24522908,
    24506303,
    24499924,
    24495330,
    24519684,
    24518295,
    24504080,
    24510053,
    24504074,
    24520397
  ]; //articles;

  Future<Article> _getArticle(int id) async {
    final storyUrl = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final storyRes = await http.get(storyUrl);
    if (storyRes.statusCode == 200) {
      return parseArticle(storyRes.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: _ids
            .map(
              (i) => FutureBuilder<Article>(
                future: _getArticle(i),
                builder:
                    (BuildContext context, AsyncSnapshot<Article> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    // the future is finished
                    return _buildItem(snapshot.data);
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key: Key(article.text),
      padding: const EdgeInsets.all(16.0),
      child: ExpansionTile(
        title: Text(
          article.title,
          style: TextStyle(fontSize: 24.0),
        ),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(article.type),
              IconButton(
                onPressed: () async {
                  if (await canLaunch(article.url)) {
                    launch(article.url);
                  }
                },
                icon: Icon(Icons.launch),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
