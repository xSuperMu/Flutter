import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:hacker_news/src/article.dart';
import 'package:hacker_news/src/hn_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  final bloc = HackerNewsBlock();
  runApp(MyApp(bloc: bloc));
}

class MyApp extends StatelessWidget {
  final HackerNewsBlock bloc;

  MyApp({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Hacker News Bloc Demo', bloc: bloc),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final HackerNewsBlock bloc;

  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: StreamBuilder<UnmodifiableListView<Article>>(
        stream: widget.bloc.articles,
        initialData: UnmodifiableListView<Article>([]),
        builder: (context, snapshot) => ListView(
          children: snapshot.data.map(_buildItem).toList(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.vertical_align_top),
            label: 'Top stories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases_sharp),
            label: 'New stories',
          ),
        ],
        onTap: (index) {
          if (index == 0)
            widget.bloc.storyType.add(StoryType.topStories);
          else
            widget.bloc.storyType.add(StoryType.newStories);
        },
      ),
    );
  }

  Widget _buildItem(Article article) {
    return Padding(
      key: GlobalKey(debugLabel: article.text), //Key(article.text),
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
