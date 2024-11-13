import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app_1/features/auth/providers/auth_provider.dart';
import 'package:social_media_app_1/features/post/providers/post_provider.dart';
import 'package:social_media_app_1/features/market/widgets/market_overview.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app_1/features/common/widgets/bottom_nav.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.post_add),
              title: const Text('Create Post'),
              onTap: () {
                context.pop();
                context.push('/create-post');
              },
            ),
            ListTile(
              leading: const Icon(Icons.group_add),
              title: const Text('Create Trading Group'),
              onTap: () {
                context.pop();
                context.push('/create-group');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final postsAsync = ref.watch(postsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('StockSocial Feed'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(postsProvider.notifier).loadPosts();
        },
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: MarketOverview(),
            ),
            postsAsync.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: Center(child: Text('Error: $error')),
              ),
              data: (posts) => SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final post = posts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child:
                                  Text(post.userEmail?[0].toUpperCase() ?? '?'),
                            ),
                            title: Text(post.userEmail ?? 'Unknown'),
                            subtitle: Text(timeago.format(post.createdAt)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.bookmark_border),
                                  onPressed: () {},
                                ),
                                IconButton(
                                  icon: const Icon(Icons.share),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                          if (post.content != null && post.content!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              child: Text(post.content!),
                            ),
                          if (post.imageUrl != null)
                            CachedNetworkImage(
                              imageUrl: post.imageUrl!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                TextButton.icon(
                                  icon: const Icon(Icons.thumb_up_outlined),
                                  label: const Text('Like'),
                                  onPressed: () {},
                                ),
                                TextButton.icon(
                                  icon: const Icon(Icons.comment_outlined),
                                  label: const Text('Comment'),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: posts.length,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateOptions(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 0),
    );
  }
}
