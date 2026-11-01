import 'package:flutter/material.dart';

// ---------- Lecture sûre du JSON ----------

/// Certaines API enveloppent la réponse dans {"data": ...}.
dynamic corps(dynamic d) =>
    (d is Map && d.length == 1 && d.containsKey('data')) ? d['data'] : d;

int versInt(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ??
      double.tryParse(v.toString())?.toInt() ??
      0;
}

int? versIntOuNul(dynamic v) => v == null ? null : versInt(v);

double? versDoubleOuNul(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

DateTime? versDate(dynamic v) =>
    v == null ? null : DateTime.tryParse(v.toString())?.toLocal();

bool versBool(dynamic v, {bool defaut = false}) {
  if (v == null) return defaut;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString();
  return s == 'true' || s == '1';
}

List<Map<String, dynamic>> versListe(dynamic v) => v is List
    ? v.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : <Map<String, dynamic>>[];

// ---------- Affichage des montants ----------

String formatNombre(int n) {
  final s = n.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('\u00A0');
    b.write(s[i]);
  }
  return n < 0 ? '-$b' : b.toString();
}

String formatFcfa(int n) => '${formatNombre(n)} FCFA';
String formatSats(int n) => '${formatNombre(n)} sats';

String formatBtc(int sats) {
  final t = (sats / 100000000).toStringAsFixed(6).replaceAll('.', ',');
  return '$t BTC';
}

// ---------- Dates ----------

const _mois = [
  'janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
  'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'
];

String _2(int n) => n.toString().padLeft(2, '0');

String formatDate(DateTime d) => '${d.day} ${_mois[d.month - 1]} ${d.year}';
String formatJourCourt(DateTime d) => '${d.day} ${_mois[d.month - 1]}';
String formatHeure(DateTime d) => '${_2(d.hour)}:${_2(d.minute)}';
String formatDateHeure(DateTime d) => '${formatDate(d)} à ${formatHeure(d)}';

/// 04:58 (compte à rebours).
String formatChrono(Duration d) {
  final s = d.isNegative ? 0 : d.inSeconds;
  return '${_2(s ~/ 60)}:${_2(s % 60)}';
}

// ---------- Moyens de paiement ----------

String nomMethode(String m) {
  switch (m) {
    case 'especes':
      return 'Espèces';
    case 'lightning':
      return 'Bitcoin';
    case 'wave':
      return 'Wave';
    case 'orange_money':
      return 'Orange Money';
    case 'free_money':
      return 'Free Money';
    default:
      return m;
  }
}

IconData iconeMethode(String m) {
  switch (m) {
    case 'especes':
      return Icons.payments_rounded;
    case 'lightning':
      return Icons.currency_bitcoin_rounded;
    default:
      return Icons.smartphone_rounded;
  }
}

Color couleurMethode(String m) =>
    m == 'lightning' ? const Color(0xFFF7931A) : const Color(0xFF2358D8);

Color fondMethode(String m) =>
    m == 'lightning' ? const Color(0xFFFFF1DE) : const Color(0xFFE4EDFD);
