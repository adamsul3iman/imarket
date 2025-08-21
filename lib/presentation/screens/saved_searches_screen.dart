import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:imarket/main.dart';

/// A simple model to represent a saved search item.
class SavedSearch {
  final String id;
  final String name;
  final Map<String, dynamic> filters;

  SavedSearch({required this.id, required this.name, required this.filters});

  factory SavedSearch.fromMap(Map<String, dynamic> map) {
    return SavedSearch(
      id: map['id'] as String,
      name: map['search_name'] as String,
      // Safely decode the JSON string from the database into a Map
      filters: Map<String, dynamic>.from(jsonDecode(map['filters'] as String)),
    );
  }
}

/// A screen to display and manage the user's saved searches.
class SavedSearchesScreen extends StatefulWidget {
  const SavedSearchesScreen({super.key});

  @override
  State<SavedSearchesScreen> createState() => _SavedSearchesScreenState();
}

class _SavedSearchesScreenState extends State<SavedSearchesScreen> {
  late Future<List<SavedSearch>> _savedSearchesFuture;

  @override
  void initState() {
    super.initState();
    _savedSearchesFuture = _fetchSavedSearches();
  }

  /// Fetches the list of saved searches for the current user from the database.
  Future<List<SavedSearch>> _fetchSavedSearches() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await supabase
          .from('saved_searches')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return response.map((item) => SavedSearch.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error fetching saved searches: $e');
      rethrow;
    }
  }

  /// Deletes a specific saved search from the database.
  Future<void> _deleteSearch(String searchId) async {
    try {
      await supabase.from('saved_searches').delete().eq('id', searchId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('تم حذف البحث المحفوظ.'),
              backgroundColor: Colors.green),
        );
        // Refresh the list after deleting
        setState(() {
          _savedSearchesFuture = _fetchSavedSearches();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('حدث خطأ: ${e.toString()}'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('عمليات البحث المحفوظة'),
      ),
      body: FutureBuilder<List<SavedSearch>>(
        future: _savedSearchesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('حدث خطأ في تحميل البيانات.'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _savedSearchesFuture = _fetchSavedSearches();
                    });
                  },
                  child: const Text('إعادة المحاولة'),
                )
              ],
            ));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('ليس لديك أي عمليات بحث محفوظة.'),
            );
          }

          final searches = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            itemCount: searches.length,
            itemBuilder: (context, index) {
              final search = searches[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.saved_search_outlined),
                  title: Text(search.name),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _deleteSearch(search.id),
                  ),
                  onTap: () {
                    // When tapped, pop the screen and return the filters as a result.
                    Navigator.pop(context, search.filters);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
