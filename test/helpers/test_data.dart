import 'dart:convert';
import 'dart:io';

import 'package:nana_doc/features/classification/data/datasources/classification_asset_data_source.dart';
import 'package:nana_doc/features/classification/data/models/classification_model.dart';
import 'package:nana_doc/features/classification/domain/entities/classification.dart';

Classification loadTestClassification() {
  final raw = File('assets/data/cpcs_1967.json').readAsStringSync();
  return ClassificationModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}

class FileAssetDataSource implements ClassificationAssetDataSource {
  final Classification data = loadTestClassification();

  @override
  Future<Classification> load() => Future.value(data);
}
