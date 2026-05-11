import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../services/bible_service.dart';

class BibleReaderScreen extends StatefulWidget {
  final String? initialChapterId;
  final String? initialVerseId;
  
  const BibleReaderScreen({Key? key, this.initialChapterId, this.initialVerseId}) : super(key: key);

  @override
  State<BibleReaderScreen> createState() => _BibleReaderScreenState();
}

class _BibleReaderScreenState extends State<BibleReaderScreen> with SingleTickerProviderStateMixin {
  final BibleService _bibleService = BibleService();
  List<Map<String, dynamic>> _allBooks = [];
  List<Map<String, dynamic>> _filteredBooks = [];
  List<Map<String, dynamic>> _versions = [];
  String _currentVersionName = "Cargando...";
  bool _isLoading = true;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initBible();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initBible() async {
    try {
      final versions = await _bibleService.getAvailableBibles();
      if (versions.isNotEmpty && mounted) {
        setState(() {
          _versions = versions;
          _currentVersionName = versions[0]['name'];
          _bibleService.setBibleId(versions[0]['id']);
        });
        await _loadBooks();

        if (widget.initialChapterId != null && mounted) {
          _showChapterDetail(widget.initialChapterId!, targetVerseId: widget.initialVerseId);
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showChapterDetail(String chapterId, {String? reference, String? targetVerseId}) {
    String finalRef = reference ?? "Cargando...";
    
    if (reference == null && _allBooks.isNotEmpty) {
      // Intentamos extraer referencia del ID (BOOK.CH)
      final parts = chapterId.split('.');
      if (parts.length >= 2) {
        final bookId = parts[0];
        final chapterNum = parts[1];
        try {
          final book = _allBooks.firstWhere((b) => b['id'] == bookId);
          finalRef = "${book['name']} $chapterNum";
        } catch (_) {
          finalRef = "Capítulo $chapterNum";
        }
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _ChapterDetailView(
          chapterId: chapterId,
          reference: finalRef,
          targetVerseId: targetVerseId,
          bibleService: _bibleService,
        ),
      ),
    );
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);
    try {
      final books = await _bibleService.getBooks();
      if (mounted) {
        setState(() {
          _allBooks = books;
          _filteredBooks = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterBooks(String query) {
    setState(() {
      _filteredBooks = _allBooks
          .where((book) => book['name'].toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final oldTestament = _filteredBooks.where((b) => b['canon'] == 'old_testament' || b['canon'] == 'ot').toList();
    final newTestament = _filteredBooks.where((b) => b['canon'] == 'new_testament' || b['canon'] == 'nt').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentVersionName, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _showVersionSelector, 
            child: const Text('Cambiar', style: TextStyle(color: Colors.blueAccent))
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(isDark),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blueAccent,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blueAccent,
            tabs: const [
              Tab(text: 'Antiguo'),
              Tab(text: 'Nuevo'),
            ],
          ),
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookList(oldTestament, isDark),
                    _buildBookList(newTestament, isDark),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _filterBooks,
        decoration: InputDecoration(
          hintText: 'Buscar libro...',
          prefixIcon: const Icon(Icons.search, size: 20),
          filled: true,
          fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
          contentPadding: const EdgeInsets.all(0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(List<Map<String, dynamic>> books, bool isDark) {
    if (books.isEmpty && !_isLoading) {
      return const Center(child: Text('No se encontraron libros'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: ListTile(
            dense: true,
            title: Text(book['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
            trailing: const Icon(Icons.chevron_right, size: 18),
            onTap: () => _showChapterSelector(book),
          ),
        );
      },
    );
  }

  void _showVersionSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Seleccionar Versión', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const Divider(),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _versions.length,
                  itemBuilder: (context, index) {
                    final v = _versions[index];
                    return ListTile(
                      title: Text(v['name']),
                      subtitle: Text(v['abbreviation']),
                      trailing: _currentVersionName == v['name'] ? const Icon(Icons.check, color: Colors.green) : null,
                      onTap: () {
                        setState(() {
                          _currentVersionName = v['name'];
                          _bibleService.setBibleId(v['id']);
                        });
                        Navigator.pop(context);
                        _loadBooks();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showChapterSelector(Map<String, dynamic> book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ChapterSelector(book: book, bibleService: _bibleService),
    );
  }
}

class _ChapterSelector extends StatefulWidget {
  final Map<String, dynamic> book;
  final BibleService bibleService;

  const _ChapterSelector({required this.book, required this.bibleService});

  @override
  State<_ChapterSelector> createState() => _ChapterSelectorState();
}

class _ChapterSelectorState extends State<_ChapterSelector> {
  List<Map<String, dynamic>> _chapters = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final chapters = await widget.bibleService.getChapters(widget.book['id']);
      if (mounted) {
        setState(() {
          _chapters = chapters;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121212) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(10)),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.book['name'],
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const Divider(),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: _chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = _chapters[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _ChapterDetailView(
                                chapterId: chapter['id'],
                                reference: '${widget.book['name']} ${chapter['number']}',
                                bibleService: widget.bibleService,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blueAccent.withOpacity(0.2)),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            chapter['number'],
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChapterDetailView extends StatefulWidget {
  final String chapterId;
  final String reference;
  final String? targetVerseId;
  final BibleService bibleService;

  const _ChapterDetailView({
    required this.chapterId,
    required this.reference,
    required this.bibleService,
    this.targetVerseId,
  });

  @override
  State<_ChapterDetailView> createState() => _ChapterDetailViewState();
}

class _ChapterDetailViewState extends State<_ChapterDetailView> {
  final ItemScrollController _itemScrollController = ItemScrollController();
  List<Map<String, String>> _verses = [];
  bool _isLoading = true;
  bool _hasScrolled = false;

  @override
  void initState() {
    super.initState();
    _loadAndParseContent();
  }

  Future<void> _loadAndParseContent() async {
    try {
      final data = await widget.bibleService.getChapterContent(widget.chapterId);
      final String htmlContent = data['content'];
      
      List<Map<String, String>> parsedVerses = [];
      
      // Intentamos parsing de YouVersion (clase 'v' o 'yv-vlbl')
      final regexYV = RegExp(r'(<span[^>]*class="(?:v|yv-vlbl)"[^>]*>.*?</span>)(.*?)(?=<span[^>]*class="(?:v|yv-vlbl)"|$)', dotAll: true);
      final matchesYV = regexYV.allMatches(htmlContent).toList();
      
      if (matchesYV.isNotEmpty) {
        for (var match in matchesYV) {
          final spanHtml = match.group(1) ?? '';
          final verseTextHtml = match.group(2) ?? '';
          final numRegex = RegExp(r'>(\d+)<');
          final numMatch = numRegex.firstMatch(spanHtml);
          final verseNum = numMatch?.group(1) ?? '0';
          
          parsedVerses.add({
            'id': '${widget.chapterId}.$verseNum',
            'html': spanHtml + verseTextHtml,
          });
        }
      }

      if (parsedVerses.isEmpty) {
        // Fallback a API.Bible style o bloque completo
        final regex = RegExp(r'<span[^>]*data-verse-id="([^"]+)"[^>]*>(.*?)</span>', dotAll: true);
        final matches = regex.allMatches(htmlContent).toList();
        for (var match in matches) {
          parsedVerses.add({
            'id': match.group(1) ?? '',
            'html': match.group(0) ?? '',
          });
        }
      }

      if (parsedVerses.isEmpty) {
        parsedVerses.add({'id': 'full', 'html': htmlContent});
      }

      if (mounted) {
        setState(() {
          _verses = parsedVerses;
          _isLoading = false;
        });
        _jumpToTarget();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _verses = [{'id': 'error', 'html': 'Error al cargar el contenido.'}];
          _isLoading = false;
        });
      }
    }
  }

  void _jumpToTarget() {
    if (widget.targetVerseId == null || _hasScrolled || _verses.isEmpty) return;

    final index = _verses.indexWhere((v) => v['id'] == widget.targetVerseId);
    
    if (index != -1) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_itemScrollController.isAttached && mounted) {
          _itemScrollController.scrollTo(
            index: index,
            duration: const Duration(seconds: 1),
            curve: Curves.fastOutSlowIn,
            alignment: 0.05,
          );
          _hasScrolled = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reference, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 1,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ScrollablePositionedList.builder(
              itemCount: _verses.length,
              itemScrollController: _itemScrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              itemBuilder: (context, index) {
                final verse = _verses[index];
                final isTarget = verse['id'] == widget.targetVerseId;

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 500),
                    opacity: widget.targetVerseId == null || isTarget ? 1.0 : 0.35,
                    child: HtmlWidget(
                      verse['html']!,
                      textStyle: TextStyle(
                        fontSize: 21,
                        height: 1.6,
                        fontFamily: 'Georgia',
                        fontWeight: isTarget ? FontWeight.w600 : FontWeight.normal,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      customStylesBuilder: (element) {
                        if (element.classes.contains('v') || element.classes.contains('yv-vlbl')) {
                          return {
                            'color': isDark ? 'rgba(255, 255, 255, 0.5)' : 'rgba(0, 0, 0, 0.4)',
                            'font-size': '0.65em',
                            'vertical-align': 'super',
                            'font-weight': 'normal',
                            'margin-right': '8px',
                          };
                        }
                        return null;
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
