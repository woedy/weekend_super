import 'dart:convert';

import 'package:flutter/services.dart';

class SampleDataLoader {
  const SampleDataLoader();

  Future<Map<String, dynamic>> loadJson(String fileName) async {
    final String raw = await rootBundle.loadString('assets/sample_data/$fileName');
    return json.decode(raw) as Map<String, dynamic>;
  }
}
