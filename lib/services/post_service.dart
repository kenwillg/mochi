import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:mochi/models/post.dart';

/// Service that performs network calls to the JSONPlaceholder REST API.
class PostService {
  PostService({http.Client? client}) : _client = client ?? http.Client();

  static const _baseUrl = 'https://jsonplaceholder.typicode.com';
  final http.Client _client;

  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$_baseUrl/posts?_limit=20');
    final response = await _client.get(uri);

    _throwOnError(response);

    final List<dynamic> decoded = json.decode(response.body) as List<dynamic>;
    return decoded
        .map((jsonMap) => Post.fromJson(jsonMap as Map<String, dynamic>))
        .toList(growable: false);
  }

  Future<Post> createPost(PostDraft draft) async {
    final uri = Uri.parse('$_baseUrl/posts');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(draft.toJson()),
    );

    _throwOnError(response, expectedStatus: 201);

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;

    return Post.fromJson({
      ...draft.toJson(),
      ...decoded,
      'id': decoded['id'] ?? 101,
    });
  }

  Future<Post> updatePost({
    required int id,
    required PostDraft draft,
  }) async {
    final uri = Uri.parse('$_baseUrl/posts/$id');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: json.encode(draft.toJson()),
    );

    _throwOnError(response);

    final Map<String, dynamic> decoded =
        json.decode(response.body) as Map<String, dynamic>;

    return Post.fromJson({
      'id': id,
      ...draft.toJson(),
      ...decoded,
    });
  }

  void _throwOnError(http.Response response, {int expectedStatus = 200}) {
    if (response.statusCode != expectedStatus) {
      throw http.ClientException(
        'Request failed with status ${response.statusCode}',
        response.request?.url,
      );
    }
  }
}
