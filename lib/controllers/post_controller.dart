import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:mochi/models/post.dart';
import 'package:mochi/services/post_service.dart';

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final postServiceProvider = Provider<PostService>((ref) {
  final client = ref.watch(httpClientProvider);
  return PostService(client: client);
});

final postControllerProvider =
    AutoDisposeAsyncNotifierProvider<PostController, List<Post>>(
  PostController.new,
);

class PostController extends AutoDisposeAsyncNotifier<List<Post>> {
  PostService get _service => ref.read(postServiceProvider);

  @override
  Future<List<Post>> build() async {
    return _service.fetchPosts();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_service.fetchPosts);
  }

  Future<void> createPost(PostDraft draft) async {
    final previousPosts = state.valueOrNull ?? [];
    state = AsyncValue<List<Post>>.loading(previous: state);
    state = await AsyncValue.guard(() async {
      final created = await _service.createPost(draft);
      return [created, ...previousPosts];
    });
  }

  Future<void> updatePost({
    required int id,
    required PostDraft draft,
  }) async {
    final previousPosts = state.valueOrNull ?? [];
    state = AsyncValue<List<Post>>.loading(previous: state);
    state = await AsyncValue.guard(() async {
      final updated = await _service.updatePost(id: id, draft: draft);
      return [
        for (final post in previousPosts)
          if (post.id == id) updated else post,
      ];
    });
  }
}
