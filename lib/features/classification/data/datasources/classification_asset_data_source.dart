import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/classification.dart';
import '../models/classification_model.dart';

abstract class ClassificationAssetDataSource {
  Future<Classification> load();
}

class ClassificationAssetDataSourceImpl
    implements ClassificationAssetDataSource {
  static const assetPath = 'assets/data/cpcs_1967.json';

  final AssetBundle bundle;
  Classification? _cache;

  ClassificationAssetDataSourceImpl({AssetBundle? bundle})
    : bundle = bundle ?? rootBundle;

  @override
  Future<Classification> load() async {
    final cached = _cache;
    if (cached != null) return cached;
    final raw = await bundle.loadString(assetPath);
    final data = ClassificationModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
    _cache = data;
    return data;
  }
}
