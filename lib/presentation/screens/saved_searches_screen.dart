import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/saved_searches/saved_searches_bloc.dart';

/// شاشة تعرض قائمة بعمليات البحث التي قام المستخدم بحفظها.
class SavedSearchesScreen extends StatelessWidget {
  const SavedSearchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<SavedSearchesBloc>()..add(FetchSavedSearches()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عمليات البحث المحفوظة'),
        ),
        body: BlocBuilder<SavedSearchesBloc, SavedSearchesState>(
          builder: (context, state) {
            if (state.status == SavedSearchesStatus.loading ||
                state.status == SavedSearchesStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == SavedSearchesStatus.failure) {
              return Center(
                  child: Text(state.errorMessage ?? 'An error occurred.'));
            }
            if (state.searches.isEmpty) {
              return const Center(
                  child: Text('ليس لديك أي عمليات بحث محفوظة.'));
            }

            final searches = state.searches;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: searches.length,
              itemBuilder: (context, index) {
                final search = searches[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.saved_search_outlined),
                    title: Text(search.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => context
                          .read<SavedSearchesBloc>()
                          .add(DeleteSavedSearch(search.id)),
                    ),
                    onTap: () {
                      Navigator.pop(context, search.filters);
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
