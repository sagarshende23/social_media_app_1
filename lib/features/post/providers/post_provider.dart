import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:social_media_app_1/features/post/models/post.dart';

final supabase = Supabase.instance.client;

final postsProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier();
});

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PostsNotifier() : super(const AsyncValue.loading()) {
    loadPosts();
  }

  Future<void> loadPosts() async {
    try {
      final response = await supabase
          .from('posts')
          .select('*, users:user_id(email)')
          .order('created_at', ascending: false);

      final posts =
          (response as List).map((post) => Post.fromMap(post)).toList();

      state = AsyncValue.data(posts);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> createPost(String? content, File? image) async {
    try {
      String? imageUrl;

      if (image != null) {
        final fileExt = image.path.split('.').last;
        final fileName = '${DateTime.now().toIso8601String()}.$fileExt';

        await supabase.storage.from('posts').upload(
              fileName,
              image,
              fileOptions:
                  const FileOptions(cacheControl: '3600', upsert: false),
            );

        imageUrl = supabase.storage.from('posts').getPublicUrl(fileName);
      }

      await supabase.from('posts').insert({
        'content': content,
        'image_url': imageUrl,
        'user_id': supabase.auth.currentUser!.id,
      });

      loadPosts();
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}
