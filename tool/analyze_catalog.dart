import 'dart:convert';
import 'dart:io';

void main() {
  final raw = File('catalog_sample.json').readAsStringSync();
  final decoded = jsonDecode(raw);
  final List list = decoded is Map && decoded['data'] is List
      ? decoded['data'] as List
      : decoded as List;

  var upvcZero = 0;
  var upvcPos = 0;
  for (final e in list) {
    final map = e as Map<String, dynamic>;
    if ((map['type'] ?? '').toString().toUpperCase() != 'UPVC') continue;
    final mrp = (map['mrp'] as num?)?.toDouble() ?? 0;
    final sp = (map['sellingPrice'] as num?)?.toDouble() ?? 0;
    final sr = (map['standardRate'] as num?)?.toDouble() ?? 0;
    if (mrp > 0 || sp > 0 || sr > 0) {
      upvcPos++;
    } else {
      upvcZero++;
    }
  }
  stdout.writeln('UPVC with price: $upvcPos, all zero: $upvcZero');

  final sample = list
      .cast<Map<String, dynamic>>()
      .where((e) => (e['type'] ?? '').toString().toUpperCase() == 'UPVC')
      .where((e) =>
          ((e['mrp'] as num?)?.toDouble() ?? 0) > 0 ||
          ((e['sellingPrice'] as num?)?.toDouble() ?? 0) > 0)
      .take(2)
      .toList();
  stdout.writeln(jsonEncode(sample));

  final upvcPipe = list.cast<Map<String, dynamic>>().where((e) {
    final type = (e['type'] ?? '').toString().toUpperCase();
    final sub = (e['subcategory'] ?? '').toString().toLowerCase();
    return type == 'UPVC' && (sub == 'pipe' || sub == 'pipes');
  }).toList();
  stdout.writeln('UPVC Pipe rows: ${upvcPipe.length}');
  var pipeZero = 0;
  var pipePos = 0;
  for (final e in upvcPipe) {
    final mrp = (e['mrp'] as num?)?.toDouble() ?? 0;
    final sp = (e['sellingPrice'] as num?)?.toDouble() ?? 0;
    final sr = (e['standardRate'] as num?)?.toDouble() ?? 0;
    if (mrp > 0 || sp > 0 || sr > 0) {
      pipePos++;
    } else {
      pipeZero++;
    }
  }
  stdout.writeln('UPVC Pipe priced: $pipePos zero: $pipeZero');

  final priced = upvcPipe.where((e) {
    final mrp = (e['mrp'] as num?)?.toDouble() ?? 0;
    final sp = (e['sellingPrice'] as num?)?.toDouble() ?? 0;
    final sr = (e['standardRate'] as num?)?.toDouble() ?? 0;
    return mrp > 0 || sp > 0 || sr > 0;
  }).toList();
  if (priced.isNotEmpty) {
    final e = priced.first;
    stdout.writeln(
      'Min priced sample: mrp=${e['mrp']} sp=${e['sellingPrice']} sr=${e['standardRate']} name=${e['productName']}',
    );
  }
}
