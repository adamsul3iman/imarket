import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'blocked_users_event.dart';
part 'blocked_users_state.dart';

@injectable
class BlockedUsersBloc extends Bloc<BlockedUsersEvent, BlockedUsersState> {
  final SupabaseClient _supabase;

  BlockedUsersBloc(this._supabase) : super(const BlockedUsersState()) {
    on<FetchBlockedUsers>(_onFetch);
    on<UnblockUser>(_onUnblock);
  }

  Future<void> _onFetch(FetchBlockedUsers event, Emitter<BlockedUsersState> emit) async {
    emit(state.copyWith(status: BlockedUsersStatus.loading));
    final user = _supabase.auth.currentUser;
    if (user == null) {
      emit(state.copyWith(status: BlockedUsersStatus.loaded, users: []));
      return;
    }

    try {
      final response = await _supabase
          .from('blocked_users')
          .select('profiles!blocked_id(id, full_name)')
          .eq('blocker_id', user.id);
      
      final users = response.map((item) => BlockedUser.fromMap(item)).toList();
      emit(state.copyWith(status: BlockedUsersStatus.loaded, users: users));
    } catch (e) {
      emit(state.copyWith(status: BlockedUsersStatus.failure, errorMessage: e.toString()));
    }
  }

  Future<void> _onUnblock(UnblockUser event, Emitter<BlockedUsersState> emit) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    try {
      await _supabase
          .from('blocked_users')
          .delete()
          .match({'blocker_id': user.id, 'blocked_id': event.userId});
      
      // After unblocking, refresh the list
      add(FetchBlockedUsers());
    } catch (e) {
      emit(state.copyWith(status: BlockedUsersStatus.failure, errorMessage: 'Failed to unblock user'));
    }
  }
}