import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app_1/features/group/models/group.dart';
import 'package:social_media_app_1/features/group/providers/group_provider.dart';

class GroupListScreen extends ConsumerWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create-group');
            },
          ),
        ],
      ),
      body: groupsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(child: Text('No groups found'));
          }

          return ListView.builder(
            itemCount: groups.length,
            itemBuilder: (context, index) {
              final group = groups[index];
              return GroupListTile(group: group);
            },
          );
        },
      ),
    );
  }
}

class GroupListTile extends ConsumerWidget {
  final Group group;

  const GroupListTile({super.key, required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: group.imageUrl != null
          ? CircleAvatar(backgroundImage: NetworkImage(group.imageUrl!))
          : CircleAvatar(child: Text(group.name[0])),
      title: Text(group.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            group.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${group.type.name} • ${group.category.name}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${group.memberCount}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            'members',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      onTap: () {
        ref.read(selectedGroupProvider.notifier).state = group;
        Navigator.pushNamed(context, '/group-details');
      },
    );
  }
}
