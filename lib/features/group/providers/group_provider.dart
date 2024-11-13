import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app_1/features/group/models/group.dart';

final supabase = Supabase.instance.client;

final groupsProvider =
    StateNotifierProvider<GroupsNotifier, AsyncValue<List<Group>>>((ref) {
  return GroupsNotifier();
});

final selectedGroupProvider = StateProvider<Group?>((ref) => null);

class GroupsNotifier extends StateNotifier<AsyncValue<List<Group>>> {
  GroupsNotifier() : super(const AsyncValue.loading()) {
    loadGroups();
  }

  Future<void> loadGroups() async {
    try {
      final response = await supabase
          .from('groups')
          .select('*, group_members(count)')
          .order('created_at', ascending: false);

      final groups =
          (response as List).map((group) => Group.fromMap(group)).toList();

      state = AsyncValue.data(groups);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<Group?> getGroupDetails(String groupId) async {
    try {
      final response = await supabase
          .from('groups')
          .select('*, group_members(count)')
          .eq('id', groupId)
          .single();

      return Group.fromMap(response);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return null;
    }
  }

  Future<void> createGroup({
    required String name,
    required String description,
    required GroupType type,
    required GroupCategory category,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = 'group_${DateTime.now().toIso8601String()}.$fileExt';

        await supabase.storage.from('groups').upload(
              fileName,
              image,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        imageUrl = supabase.storage.from('groups').getPublicUrl(fileName);
      }

      await supabase.from('groups').insert({
        'name': name,
        'description': description,
        'type': type.toString().split('.').last,
        'category': category.toString().split('.').last,
        'image_url': imageUrl,
        'owner_id': supabase.auth.currentUser!.id,
      });

      loadGroups();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateGroup({
    required String groupId,
    required String name,
    required String description,
    required GroupType type,
    required GroupCategory category,
    File? image,
  }) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = 'group_${DateTime.now().toIso8601String()}.$fileExt';

        await supabase.storage.from('groups').upload(
              fileName,
              image,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        imageUrl = supabase.storage.from('groups').getPublicUrl(fileName);
      }

      await supabase.from('groups').update({
        'name': name,
        'description': description,
        'type': type.toString().split('.').last,
        'category': category.toString().split('.').last,
        if (imageUrl != null) 'image_url': imageUrl,
      }).eq('id', groupId);

      loadGroups();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteGroup(String groupId) async {
    try {
      await supabase.from('groups').delete().eq('id', groupId);
      loadGroups();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      await supabase.from('group_members').insert({
        'group_id': groupId,
        'user_id': supabase.auth.currentUser!.id,
      });
      loadGroups();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> leaveGroup(String groupId) async {
    try {
      await supabase
          .from('group_members')
          .delete()
          .eq('group_id', groupId)
          .eq('user_id', supabase.auth.currentUser!.id);
      loadGroups();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Group Messages Provider
final groupMessagesProvider = StateNotifierProvider.family<
    GroupMessagesNotifier,
    AsyncValue<List<GroupMessage>>,
    String>((ref, groupId) {
  return GroupMessagesNotifier(groupId);
});

class GroupMessage {
  final String id;
  final String groupId;
  final String userId;
  final String content;
  final DateTime createdAt;

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  factory GroupMessage.fromMap(Map<String, dynamic> map) {
    return GroupMessage(
      id: map['id'],
      groupId: map['group_id'],
      userId: map['user_id'],
      content: map['content'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}

class GroupMessagesNotifier
    extends StateNotifier<AsyncValue<List<GroupMessage>>> {
  final String groupId;
  RealtimeChannel? _channel;

  GroupMessagesNotifier(this.groupId) : super(const AsyncValue.loading()) {
    loadMessages();
    _subscribeToMessages();
  }

  Future<void> loadMessages() async {
    try {
      final response = await supabase
          .from('group_messages')
          .select()
          .eq('group_id', groupId)
          .order('created_at', ascending: false);

      final messages =
          (response as List).map((msg) => GroupMessage.fromMap(msg)).toList();

      state = AsyncValue.data(messages);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  void _subscribeToMessages() {
    _channel = supabase.channel('group_messages:$groupId');

    _channel?.on(
      RealtimeListenTypes.postgresChanges,
      ChannelFilter(event: 'INSERT', schema: 'public', table: 'group_messages'),
      (payload, [ref]) {
        final newMessage = GroupMessage.fromMap(payload['new']);
        state.whenData((messages) {
          state = AsyncValue.data([newMessage, ...messages]);
        });
      },
    ).subscribe();
  }

  Future<void> sendMessage(String content) async {
    try {
      await supabase.from('group_messages').insert({
        'group_id': groupId,
        'user_id': supabase.auth.currentUser!.id,
        'content': content,
      });
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }
}
