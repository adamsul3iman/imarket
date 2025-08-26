import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:imarket/core/di/dependency_injection.dart';
import 'package:imarket/presentation/blocs/blocked_users/blocked_users_bloc.dart';

/// شاشة تعرض قائمة بالمستخدمين الذين قام المستخدم الحالي بحظرهم.
class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<BlockedUsersBloc>()..add(FetchBlockedUsers()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المستخدمين المحظورين'),
        ),
        body: BlocBuilder<BlockedUsersBloc, BlockedUsersState>(
          builder: (context, state) {
            if (state.status == BlockedUsersStatus.loading ||
                state.status == BlockedUsersStatus.initial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status == BlockedUsersStatus.failure) {
              return Center(
                  child:
                      Text(state.errorMessage ?? 'حدث خطأ في تحميل القائمة.'));
            }
            if (state.users.isEmpty) {
              return const Center(child: Text('قائمة الحظر فارغة.'));
            }

            final blockedUsers = state.users;
            return ListView.builder(
              itemCount: blockedUsers.length,
              itemBuilder: (context, index) {
                final blockedUser = blockedUsers[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(blockedUser.fullName.isNotEmpty
                          ? blockedUser.fullName[0].toUpperCase()
                          : '?'),
                    ),
                    title: Text(blockedUser.fullName),
                    trailing: ElevatedButton(
                      onPressed: () => context
                          .read<BlockedUsersBloc>()
                          .add(UnblockUser(blockedUser.id)),
                      style:
                          ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      child: const Text('إلغاء الحظر'),
                    ),
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
