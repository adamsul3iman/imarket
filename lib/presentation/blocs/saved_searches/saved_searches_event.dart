part of 'saved_searches_bloc.dart';

abstract class SavedSearchesEvent extends Equatable {
  const SavedSearchesEvent();

  @override
  List<Object> get props => [];
}

class FetchSavedSearches extends SavedSearchesEvent {}

class DeleteSavedSearch extends SavedSearchesEvent {
  final String searchId;
  const DeleteSavedSearch(this.searchId);
}