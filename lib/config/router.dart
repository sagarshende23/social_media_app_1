import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:social_media_app_1/features/auth/presentation/screens/login_screen.dart';
import 'package:social_media_app_1/features/auth/presentation/screens/register_screen.dart';
import 'package:social_media_app_1/features/auth/presentation/screens/profile_screen.dart';
import 'package:social_media_app_1/features/auth/presentation/screens/edit_profile_screen.dart';
import 'package:social_media_app_1/features/feed/presentation/screens/feed_screen.dart';
import 'package:social_media_app_1/features/post/presentation/screens/create_post_screen.dart';
import 'package:social_media_app_1/features/group/presentation/screens/group_list_screen.dart';
import 'package:social_media_app_1/features/group/presentation/screens/group_details_screen.dart';
import 'package:social_media_app_1/features/group/presentation/screens/group_form_screen.dart';
import 'package:social_media_app_1/features/auth/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isAuthRoute) return '/auth/login';
      if (isLoggedIn && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const FeedScreen(),
      ),
      GoRoute(
        path: '/auth/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/create-post',
        builder: (context, state) => const CreatePostScreen(),
      ),
      // Group Routes
      GoRoute(
        path: '/groups',
        builder: (context, state) => const GroupListScreen(),
      ),
      GoRoute(
        path: '/groups/create',
        builder: (context, state) => const GroupFormScreen(),
      ),
      GoRoute(
        path: '/groups/edit',
        builder: (context, state) => const GroupFormScreen(isEditing: true),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) => const GroupDetailsScreen(),
      ),
      GoRoute(
        path: '/editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );
});
