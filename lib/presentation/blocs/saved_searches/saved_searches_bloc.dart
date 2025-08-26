import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'saved_searches_event.dart';
part 'saved_searches_state.dart';

@injectable
class SavedSearchesBloc extends Bloc<SavedSearchesEvent, SavedSearchesState> {
  final SupabaseClient _supabase;

  SavedSearchesBloc(this._supabase) : super(const SavedSearchesState()) {
    on<FetchSavedSearches>(_onFetch);
    on<DeleteSavedSearch>(_onDelete);
  }

  Future<void> _onFetch(FetchSavedSearches event, Emitter<SavedSearchesState> emit) async {
    emit(state.copyWith(status: SavedSearchesStatus.loading));
    final user = _supabase.auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: SavedSearchesStatus.loaded, searches: []));
      return;
    }
    try {
      final response = await _supabase
          .from('saved_searches')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      
      final searches = response.map((item) => SavedSearch.fromMap(item)).toList();
      emit(state.copyWith(status: SavedSearchesStatus.loaded, searches: searches));
    } catch (e) {
      emit(state.copyWith(status: SavedSearchesStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onDelete(DeleteSavedSearch event, Emitter<SavedSearchesState> emit) async {
    try {
      await _supabase.from('saved_searches').delete().eq('id', event.searchId);
      // After deleting successfully, trigger a refresh of the list.
      add(FetchSavedSearches());
    } catch (e) {
      // FIX: If deleting fails, emit a failure state so the UI can show an error.
      emit(state.copyWith(
        status: SavedSearchesStatus.failure,
        errorMessage: 'فشل حذف البحث المحفوظ. يرجى المحاولة مرة أخرى.',
      ));
    }
  }
}