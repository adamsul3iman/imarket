import 'package:flutter/material.dart';
import 'package:imarket/main.dart';

// موديل بسيط لتخزين بيانات المستخدم المحظور
class BlockedUser {
  final String id;
  final String fullName;

  BlockedUser({required this.id, required this.fullName});

  factory BlockedUser.fromMap(Map<String, dynamic> map) {
    return BlockedUser(
      id: map['profiles']['id'] as String,
      fullName: map['profiles']['full_name'] as String? ?? 'مستخدم محظور',
    );
  }
}

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  late Future<List<BlockedUser>> _blockedUsersFuture;

  @override
  void initState() {
    super.initState();
    _blockedUsersFuture = _fetchBlockedUsers();
  }

  /// جلب قائمة المستخدمين المحظورين من قاعدة البيانات
  Future<List<BlockedUser>> _fetchBlockedUsers() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];
    try {
      final response = await supabase
          .from('blocked_users')
          .select('profiles!blocked_id(id, full_name)') // جلب بيانات الشخص المحظور
          .eq('blocker_id', user.id);
          
      return response.map((item) => BlockedUser.fromMap(item)).toList();
    } catch (e) {
      debugPrint('Error fetching blocked users: $e');
      rethrow;
    }
  }

  /// إلغاء حظر مستخدم معين
  Future<void> _unblockUser(String blockedId) async {
    final user = supabase.auth.currentUser;
    if (user == null) return;
    try {
      await supabase
          .from('blocked_users')
          .delete()
          .match({'blocker_id': user.id, 'blocked_id': blockedId});
      
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء حظر المستخدم بنجاح.'), backgroundColor: Colors.green),
        );
        // تحديث القائمة بعد إلغاء الحظر
        setState(() {
          _blockedUsersFuture = _fetchBlockedUsers();
        });
      }
    } catch(e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المستخدمين المحظورين'),
      ),
      body: FutureBuilder<List<BlockedUser>>(
        future: _blockedUsersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('حدث خطأ في تحميل القائمة.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('قائمة الحظر فارغة.'),
            );
          }

          final blockedUsers = snapshot.data!;
          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final blockedUser = blockedUsers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(blockedUser.fullName.isNotEmpty ? blockedUser.fullName[0].toUpperCase() : '?'),
                  ),
                  title: Text(blockedUser.fullName),
                  trailing: ElevatedButton(
                    onPressed: () => _unblockUser(blockedUser.id),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('إلغاء الحظر'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}