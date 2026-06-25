import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:vsign_mobile_app/core/models/payment_models.dart';
import 'package:vsign_mobile_app/core/network/repositories.dart';

// --- Events ---
abstract class DictionaryEvent {}

class SearchWordRequested extends DictionaryEvent {
  final String? word;
  final String? category;
  SearchWordRequested({this.word, this.category});
}

// --- States ---
abstract class DictionaryState {}

class DictionaryInitial extends DictionaryState {}

class DictionaryLoading extends DictionaryState {}

class DictionaryLoaded extends DictionaryState {
  final List<DictionaryEntry> entries;
  DictionaryLoaded({required this.entries});
}

class DictionaryError extends DictionaryState {
  final String message;
  DictionaryError({required this.message});
}

// --- BLoC ---
class DictionaryBloc extends Bloc<DictionaryEvent, DictionaryState> {
  final DictionaryRepository _repository = GetIt.instance<DictionaryRepository>();

  DictionaryBloc() : super(DictionaryInitial()) {
    on<SearchWordRequested>(_onSearchWordRequested);
  }

  Future<void> _onSearchWordRequested(SearchWordRequested event, Emitter<DictionaryState> emit) async {
    emit(DictionaryLoading());
    try {
      final entries = await _repository.listEntries(
        word: event.word,
        category: event.category,
      );
      emit(DictionaryLoaded(entries: entries));
    } catch (e) {
      emit(DictionaryError(message: 'Không thể tìm kiếm từ vựng.'));
    }
  }
}
