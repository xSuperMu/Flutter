import 'dart:async';
import 'dart:collection';

import 'package:hacker_news/src/article.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';

enum StoryType {
  topStories,
  newStories,
}

class HackerNewsBlock {
  final _storiesTypeController = StreamController<StoryType>();

  Sink<StoryType> get storyType => _storiesTypeController.sink;

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  Stream<UnmodifiableListView<Article>> get articles => _articlesSubject.stream;

  var _articles = <Article>[];

  static List<int> _newIds = [
    24522908,
    24506303,
    24499924,
    24495330,
    24519684,
  ]; //articles;

  static List<int> _topIds = [
    24518295,
    24504080,
    24510053,
    24504074,
    24520397,
  ];

  HackerNewsBlock() {
    _getAndUpdateArticles(_topIds);

    _storiesTypeController.stream.listen((storyType) {
      if (storyType == StoryType.newStories)
        _getAndUpdateArticles(_newIds);
      else
        _getAndUpdateArticles(_topIds);
    });
  }

  _getAndUpdateArticles(List<int> ids) {
    _updateArticles(ids).then((_) {
      _articlesSubject.add(UnmodifiableListView(_articles));
    });
  }

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }

  Future<Article> _getArticle(int id) async {
    final storyUrl = 'https://hacker-news.firebaseio.com/v0/item/$id.json';
    final storyRes = await http.get(storyUrl);
    if (storyRes.statusCode == 200) {
      return parseArticle(storyRes.body);
    }
  }
}
