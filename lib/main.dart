import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter List App',
      theme: ThemeData.dark(),
      home: TabPage(),
    );
  }
}

class TabPage extends StatefulWidget {
  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  Set<WordPair> _saved = Set<WordPair>();
  int _currentIndex = 0;
  RandomWords randomWords;
  FavoriteWords favoriteWords;
  final List<Tab> appTabs = <Tab>[
    Tab(
      icon: Icon(Icons.list),
      text: 'All words',
    ),
    Tab(
      icon: Icon(
        Icons.favorite,
        color: Colors.red,
      ),
      text: 'Favorited words',
    )
  ];
  TabController _tabController;

  void tabChangedListener() {
    _currentIndex = _tabController.index;
    switch (_currentIndex) {
      case 1:
        favoriteWords.createElement();
        break;
      default:
        randomWords.createElement();
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(vsync: this, length: appTabs.length);
    _tabController.addListener(tabChangedListener);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    favoriteWords = FavoriteWords(saved: _saved);
    randomWords = RandomWords(words: [], favoriteWords: favoriteWords);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Startup name generator'),
          bottom: TabBar(
            controller: _tabController,
            tabs: appTabs,
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [randomWords, favoriteWords],
        ),
      ),
    );
  }
}

class RandomWords extends StatefulWidget {
  final FavoriteWords favoriteWords;
  final Widget child;
  final List<WordPair> words;
  RandomWords({Key key, this.words, this.favoriteWords, this.child}) : super(key: key);
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends State<RandomWords> {
  final TextStyle _biggerFont = const TextStyle(fontSize: 18);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildWords(),
    );
  }

  Widget _buildWords() {
    final List<WordPair> words = widget.words;
    final Set<WordPair> saved = widget.favoriteWords.saved;
    return ListView.builder(itemBuilder: (_, int i) {
      if (i.isOdd) return Divider();
      final int index = i ~/ 2;
      if (index >= (words.length)) words.addAll(generateWordPairs().take(10));
      return _buildRow(words[index], saved);
    });
  }

  Widget _buildRow(WordPair word, Set<WordPair> saved) {
    final bool alreadySaved = saved.contains(word);
    return ListTile(
      title: Text(
        word.asPascalCase,
        style: _biggerFont,
      ),
      trailing: IconButton(
        icon: alreadySaved ? Icon(Icons.favorite) : Icon(Icons.favorite_border),
        color: alreadySaved ? Colors.red : null,
        onPressed: () {
          setState(() {
            if (alreadySaved)
              saved.remove(word);
            else
              saved.add(word);
          });
        },
      ),
    );
  }
}

class FavoriteWords extends StatefulWidget {
  final Set<WordPair> saved;
  final Widget child;
  FavoriteWords({Key key, this.saved, this.child}) : super(key: key);
  @override
  _FavoriteWordsState createState() => _FavoriteWordsState();
}

class _FavoriteWordsState extends State<FavoriteWords> {
  @override
  Widget build(BuildContext context) {
    final Iterable<ListTile> tiles = widget.saved.map(
      (WordPair pair) {
        return ListTile(
          title: Text(
            pair.asPascalCase,
          ),
          trailing: IconButton(
            icon: Icon(Icons.remove_circle_outline),
            onPressed: () {
              setState(() {
                widget.saved.remove(pair);
                // currSaved = widget.saved;
              });
            },
          ),
        );
      },
    );
    final List<Widget> divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
    ).toList();

    return Scaffold(
      body: ListView(children: divided),
    );
  }
}
