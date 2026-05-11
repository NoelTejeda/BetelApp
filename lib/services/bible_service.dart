import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class BibleService {
  // YouVersion API config
  final String _yvBaseUrl = "https://api.youversion.com/v1";
  final String _yvToken = "G0K5I4CTLQKuRFGdaLuAz01lOLfMU8CajlTBRPI7gNLzR1yo";

  // ID por defecto (Reina-Valera Antigua)
  String _bibleId = "147"; 

  // Lista de biblias abiertas de YouVersion (proporcionadas por el usuario)
  final List<Map<String, dynamic>> _youVersionBibles = [
    {'id': '147', 'name': 'Reina-Valera Antigua', 'abbreviation': 'RVES'},
    {'id': '1718', 'name': 'Biblia Reina Valera 1909', 'abbreviation': 'RVR09'},
    {'id': '3291', 'name': 'Versión Biblia Libre', 'abbreviation': 'VBL'},
    {'id': '1076', 'name': 'Biblia del Jubileo', 'abbreviation': 'JBS'},
    {'id': '753', 'name': 'Nueva Biblia Viva', 'abbreviation': 'NBV'},
    {'id': '3365', 'name': 'Palabra de Dios para ti', 'abbreviation': 'PdDpt'},
    {'id': '1715', 'name': 'Biblia del Oso 1573', 'abbreviation': 'BDO1573'},
    {'id': '3539', 'name': 'NT: Texto Bizantino', 'abbreviation': 'NTBIZ'},
  ];

  void setBibleId(String id) {
    _bibleId = id;
  }

  /// Obtiene las versiones de la Biblia disponibles (YouVersion Open Access)
  Future<List<Map<String, dynamic>>> getAvailableBibles() async {
    return _youVersionBibles;
  }

  // Claves para SharedPreferences
  static const String _prefKeyDate = "vod_date";
  static const String _prefKeyVerse = "vod_text";
  static const String _prefKeyRef = "vod_reference";

  /// Obtiene el Versículo del Día desde YouVersion.
  Future<Map<String, String>> getVerseOfTheDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    
    final savedDate = prefs.getString(_prefKeyDate);
    
    if (savedDate == today) {
      return {
        'text': prefs.getString(_prefKeyVerse) ?? "Cargando...",
        'reference': prefs.getString(_prefKeyRef) ?? "...",
        'id': prefs.getString('vod_id') ?? "JHN.3.16",
        'share_url': prefs.getString('vod_share_url') ?? "https://www.bible.com/bible/149/JHN.3.16",
      };
    }

    return await _fetchYouVersionVerse(prefs, today);
  }

  Future<Map<String, String>> _fetchYouVersionVerse(SharedPreferences prefs, String today) async {
    try {
      final now = DateTime.now();
      final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays + 1;
      
      final votdUrl = Uri.parse("$_yvBaseUrl/verse_of_the_days/$dayOfYear");
      final votdResponse = await http.get(votdUrl, headers: {
        'X-YVP-App-Key': _yvToken,
        'Accept': 'application/json',
      });

      if (votdResponse.statusCode != 200) throw 'Error VOD';

      final votdData = json.decode(votdResponse.body);
      final String passageId = votdData['passage_id'] ?? votdData['usfm'];
      
      // Intentamos obtener el contenido
      final passageData = await getYouVersionPassage(passageId);
      final String cleanText = passageData['content'].replaceAll(RegExp(r'<[^>]*>'), '').trim();
      final String reference = passageData['reference'];
      final shareUrl = "https://www.bible.com/bible/$_bibleId/$passageId";

      await prefs.setString(_prefKeyDate, today);
      await prefs.setString(_prefKeyVerse, cleanText);
      await prefs.setString(_prefKeyRef, reference);
      await prefs.setString('vod_id', passageId);
      await prefs.setString('vod_share_url', shareUrl);

      return {
        'text': cleanText,
        'reference': reference,
        'id': passageId,
        'share_url': shareUrl,
      };
    } catch (e) {
      // Fallback simple
      return {
        'text': "Porque de tal manera amó Dios al mundo...",
        'reference': "Juan 3:16",
        'id': "JHN.3.16",
        'share_url': "https://www.bible.com/bible/147/JHN.3.16",
      };
    }
  }

  /// Obtiene los libros de la Biblia desde YouVersion (CON CACHÉ)
  Future<List<Map<String, dynamic>>> getBooks() async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'yv_books_$_bibleId';
    
    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final url = Uri.parse("$_yvBaseUrl/bibles/$_bibleId/books");
      final response = await http.get(url, headers: {
        'X-YVP-App-Key': _yvToken,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List books = data['data'];
        
        // Mapeamos a formato compatible: YouVersion 'title' -> 'name'
        final mappedBooks = books.map((b) => {
          'id': b['id'],
          'name': b['title'],
          'canon': b['canon'],
        }).toList();

        await prefs.setString(cacheKey, json.encode(mappedBooks));
        return mappedBooks;
      }
      throw 'Error libros YouVersion';
    } catch (e) {
      print('❌ Error getBooks: $e');
      rethrow;
    }
  }

  /// Obtiene los capítulos de un libro desde YouVersion (CON CACHÉ)
  Future<List<Map<String, dynamic>>> getChapters(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'yv_chapters_${_bibleId}_$bookId';

    final cachedData = prefs.getString(cacheKey);
    if (cachedData != null) {
      return List<Map<String, dynamic>>.from(json.decode(cachedData));
    }

    try {
      final url = Uri.parse("$_yvBaseUrl/bibles/$_bibleId/books/$bookId/chapters");
      final response = await http.get(url, headers: {
        'X-YVP-App-Key': _yvToken,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List chapters = data['data'];

        // Mapeamos a formato compatible: passage_id -> id, title -> number
        final mappedChapters = chapters.map((c) => {
          'id': c['passage_id'],
          'number': c['title'].toString(),
        }).toList();

        await prefs.setString(cacheKey, json.encode(mappedChapters));
        return mappedChapters;
      }
      throw 'Error capítulos YouVersion';
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene el contenido de un pasaje (capítulo) desde YouVersion
  Future<Map<String, dynamic>> getChapterContent(String chapterId) async {
    // Redirigimos a getYouVersionPassage para unificar lógica
    return await getYouVersionPassage(chapterId);
  }

  Future<Map<String, dynamic>> getYouVersionPassage(String passageId, {int? bibleVersion}) async {
    final bId = bibleVersion?.toString() ?? _bibleId;
    try {
      var url = Uri.parse("$_yvBaseUrl/bibles/$bId/passages/$passageId");
      var response = await http.get(url, headers: {
        'X-YVP-App-Key': _yvToken,
        'Accept': 'application/json',
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'content': data['content'] ?? data['text'] ?? "",
          'reference': data['reference'] ?? data['display'] ?? "",
          'id': data['id'] ?? passageId,
        };
      }
      
      // Fallback a 147 si falla el actual por 403
      if (response.statusCode == 403 && bId != '147') {
        return await getYouVersionPassage(passageId, bibleVersion: 147);
      }
      
      throw 'Error pasaje: ${response.statusCode}';
    } catch (e) {
      rethrow;
    }
  }
}
