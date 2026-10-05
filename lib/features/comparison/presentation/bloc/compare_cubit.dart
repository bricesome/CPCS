import 'package:flutter_bloc/flutter_bloc.dart';

class CompareCubit extends Cubit<List<String>> {
  static const maxItems = 3;

  CompareCubit() : super(const []);

  /// Retourne false si la liste est pleine.
  bool add(String id) {
    if (state.contains(id)) return true;
    if (state.length >= maxItems) return false;
    emit([...state, id]);
    return true;
  }

  void remove(String id) => emit(state.where((e) => e != id).toList());

  void clear() => emit(const []);
}
