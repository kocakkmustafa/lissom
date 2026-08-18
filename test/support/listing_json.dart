/// `docs/store/listing.json` okuma + kullanıcı-dizesi gezinme — PAYLAŞILAN.
///
/// İki kapı bu dosyayı okur (`store_listing_test.dart`, `band_lineage_test.dart`,
/// L-348); mantık TEK yerde — kopya `H-58`in güncelleme borcunu doğurmasın
/// (iki dosya AYRI turlarda bayatlayabilirdi).
library;

import 'dart:convert';
import 'dart:io';

const String listingPath = 'docs/store/listing.json';

Map<String, dynamic> readListing([String path = listingPath]) =>
    (jsonDecode(File(path).readAsStringSync()) as Map).cast<String, dynamic>();

/// `$` önekli anahtarlar bu dosyanın KENDİ gerekçe/kaynak notlarıdır —
/// kullanıcıya gitmez, taramaya girmez.
List<String> userStrings(Object? node) {
  final List<String> out = <String>[];
  void walk(Object? n) {
    if (n is String) {
      out.add(n);
    } else if (n is List) {
      n.forEach(walk);
    } else if (n is Map) {
      n.forEach((Object? k, Object? v) {
        if (k is String && k.startsWith(r'$')) return;
        walk(v);
      });
    }
  }

  walk(node);
  return out;
}
