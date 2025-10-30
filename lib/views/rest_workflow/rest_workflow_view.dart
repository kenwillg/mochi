import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mochi/controllers/post_controller.dart';
import 'package:mochi/models/post.dart';

class RestWorkflowView extends ConsumerWidget {
  const RestWorkflowView({super.key});

  static const routeName = '/rest-workflow';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(postControllerProvider);
    final posts = postsAsync.valueOrNull;

    if (posts == null && postsAsync.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('REST with Riverpod')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (posts == null && postsAsync.hasError) {
      return Scaffold(
        appBar: AppBar(title: const Text('REST with Riverpod')),
        body: _ErrorState(
          error: postsAsync.error,
          onRetry: () =>
              ref.read(postControllerProvider.notifier).refresh(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('REST with Riverpod')),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () =>
                ref.read(postControllerProvider.notifier).refresh(),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _IntroCard(),
                const SizedBox(height: 16),
                const PostComposerCard(),
                const SizedBox(height: 16),
                if (posts != null)
                  ...posts
                      .map((post) => _PostListTile(post: post))
                      .toList(growable: false),
              ],
            ),
          ),
          if (postsAsync.isLoading)
            const Positioned(
              left: 0,
              right: 0,
              child: LinearProgressIndicator(minHeight: 2),
            ),
          if (postsAsync.hasError && posts != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _SnackBarError(
                message: postsAsync.error.toString(),
              ),
            ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Explore a REST workflow',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This screen loads posts from jsonplaceholder.typicode.com using '
              'an injectable service. The Riverpod notifier exposes loading '
              'and error states to the UI so you can follow the network flow '
              'end-to-end.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Text(
              'Try refreshing, creating a new post, or updating an existing one '
              'to watch the notifier emit new states.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class PostComposerCard extends ConsumerStatefulWidget {
  const PostComposerCard({super.key});

  @override
  ConsumerState<PostComposerCard> createState() => _PostComposerCardState();
}

class _PostComposerCardState extends ConsumerState<PostComposerCard> {
  final _createFormKey = GlobalKey<FormState>();
  final _updateFormKey = GlobalKey<FormState>();
  final _createUserIdController = TextEditingController(text: '1');
  final _createTitleController = TextEditingController();
  final _createBodyController = TextEditingController();
  final _updateIdController = TextEditingController(text: '1');
  final _updateTitleController = TextEditingController();
  final _updateBodyController = TextEditingController();

  @override
  void dispose() {
    _createUserIdController.dispose();
    _createTitleController.dispose();
    _createBodyController.dispose();
    _updateIdController.dispose();
    _updateTitleController.dispose();
    _updateBodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postsAsync = ref.watch(postControllerProvider);
    final isLoading = postsAsync.isLoading;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a post',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Form(
              key: _createFormKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _createUserIdController,
                          decoration: const InputDecoration(
                            labelText: 'User ID',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _positiveNumberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _createTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Title',
                          ),
                          validator: _nonEmptyValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _createBodyController,
                    decoration: const InputDecoration(
                      labelText: 'Body',
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: _nonEmptyValidator,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitCreate,
                      icon: const Icon(Icons.send),
                      label: const Text('POST new entry'),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 32),
            Text(
              'Update via POST',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Form(
              key: _updateFormKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: TextFormField(
                          controller: _updateIdController,
                          decoration: const InputDecoration(
                            labelText: 'Post ID',
                          ),
                          keyboardType: TextInputType.number,
                          validator: _positiveNumberValidator,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _updateTitleController,
                          decoration: const InputDecoration(
                            labelText: 'New title',
                          ),
                          validator: _nonEmptyValidator,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _updateBodyController,
                    decoration: const InputDecoration(
                      labelText: 'New body',
                    ),
                    minLines: 2,
                    maxLines: 4,
                    validator: _nonEmptyValidator,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : _submitUpdate,
                      icon: const Icon(Icons.cloud_upload),
                      label: const Text('POST update'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitCreate() {
    if (!_createFormKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(postControllerProvider.notifier);
    final draft = PostDraft(
      userId: int.parse(_createUserIdController.text),
      title: _createTitleController.text,
      body: _createBodyController.text,
    );

    notifier.createPost(draft).then((_) {
      _createTitleController.clear();
      _createBodyController.clear();
    });
  }

  void _submitUpdate() {
    if (!_updateFormKey.currentState!.validate()) {
      return;
    }

    final notifier = ref.read(postControllerProvider.notifier);
    final id = int.parse(_updateIdController.text);
    final draft = PostDraft(
      userId: 1,
      title: _updateTitleController.text,
      body: _updateBodyController.text,
    );

    notifier.updatePost(id: id, draft: draft);
  }

  String? _nonEmptyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  String? _positiveNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null || parsed <= 0) {
      return 'Enter a positive number';
    }
    return null;
  }
}

class _PostListTile extends StatelessWidget {
  const _PostListTile({required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(post.title),
        subtitle: Text(post.body),
        leading: CircleAvatar(
          child: Text(post.id.toString()),
        ),
        trailing: Text('#${post.userId}'),
      ),
    );
  }
}

class _SnackBarError extends StatelessWidget {
  const _SnackBarError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48),
          const SizedBox(height: 12),
          Text(
            'Something went wrong',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
