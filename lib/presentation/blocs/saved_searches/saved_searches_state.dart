part of 'saved_searches_bloc.dart';

class SavedSearch extends Equatable {
  final String id;
  final String name;
  final Map<String, dynamic> filters;

  const SavedSearch({required this.id, required this.name, required this.filters});

  factory SavedSearch.fromMap(Map<String, dynamic> map) {
    return SavedSearch(
      id: map['id'] as String,
      name: map['search_name'] as String,
      filters: Map<String, dynamic>.from(jsonDecode(map['filters'] as String)),
    );
  }

  @override
  List<Object?> get props => [id, name, filters];
}

enum SavedSearchesStatus { initial, loading, loaded, failure }

class SavedSearchesState extends Equatable {
  final SavedSearchesStatus status;
  final List<SavedSearch> searches;
  final String? errorMessage;

  const SavedSearchesState({
    this.status = SavedSearchesStatus.initial,
    this.searches = const [],
    this.errorMessage,
  });

  SavedSearchesState copyWith({
    SavedSearchesStatus? status,
    List<SavedSearch>? searches,
    String? errorMessage,
  }) {
    return SavedSearchesState(
      status: status ?? this.status,
      searches: searches ?? this.searches,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, searches, errorMessage];
}