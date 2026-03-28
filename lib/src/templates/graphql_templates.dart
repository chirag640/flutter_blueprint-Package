import '../config/blueprint_config.dart';

/// GraphQL scaffolding templates for flutter_blueprint.
///
/// Supports two GraphQL client libraries:
/// - `graphql_flutter` — decorator-style queries with `Query` / `Mutation` widgets
/// - `ferry`           — type-safe code-gen client (requires build_runner)
class GraphqlTemplates {
  GraphqlTemplates._();

  // ─────────────────────────────────────────────────────────────────────────
  // Public entry points
  // ─────────────────────────────────────────────────────────────────────────

  /// Returns all GraphQL scaffold files for [config].
  ///
  /// Called from mobile-template bundle builders via:
  /// ```dart
  /// if (config.includeGraphql) GraphqlTemplates.files(config)
  /// ```
  static Map<String, String> files(BlueprintConfig config) {
    return switch (config.graphqlClient) {
      GraphqlClient.graphqlFlutter => _graphqlFlutterFiles(config),
      GraphqlClient.ferry => _ferryFiles(config),
      GraphqlClient.none => {},
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // graphql_flutter client
  // ─────────────────────────────────────────────────────────────────────────

  static Map<String, String> _graphqlFlutterFiles(BlueprintConfig config) {
    return {
      'lib/core/graphql/graphql_client.dart': _graphqlFlutterClient(config),
      'lib/core/graphql/graphql_service.dart': _graphqlService(config),
      'lib/core/graphql/queries/example_queries.dart': _exampleQueries(config),
      'lib/core/graphql/mutations/example_mutations.dart':
          _exampleMutations(config),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ferry client
  // ─────────────────────────────────────────────────────────────────────────

  static Map<String, String> _ferryFiles(BlueprintConfig config) {
    return {
      'lib/core/graphql/graphql_client.dart': _ferryClient(config),
      'lib/core/graphql/graphql_service.dart': _ferryService(config),
      'lib/core/graphql/schema.graphql': _schemaGraphql(config),
      'lib/core/graphql/operations/example.graphql': _exampleOperations(config),
      'build.yaml': _buildYaml(config),
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // graphql_flutter: client setup
  // ─────────────────────────────────────────────────────────────────────────

  static String _graphqlFlutterClient(BlueprintConfig config) => '''
import 'package:graphql_flutter/graphql_flutter.dart';

/// Initialises and exposes the [GraphQLClient] singleton.
///
/// Usage:
/// ```dart
/// await GraphqlClientSetup.init(endpoint: 'https://api.example.com/graphql');
/// ```
class GraphqlClientSetup {
  GraphqlClientSetup._();

  static late GraphQLClient _client;

  /// Call once before [runApp].
  static Future<void> init({
    required String endpoint,
    String? authToken,
  }) async {
    await initHiveForFlutter();

    final httpLink = HttpLink(endpoint);

    final authLink = AuthLink(
      getToken: () async => authToken != null ? 'Bearer \$authToken' : null,
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  /// The configured [GraphQLClient] instance.
  static GraphQLClient get client => _client;

  /// Wraps the widget tree so all [Query] / [Mutation] widgets work.
  static ValueNotifier<GraphQLClient> get clientNotifier =>
      ValueNotifier(_client);
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // graphql_flutter: service wrapper
  // ─────────────────────────────────────────────────────────────────────────

  static String _graphqlService(BlueprintConfig config) => '''
import 'package:graphql_flutter/graphql_flutter.dart';
import 'graphql_client.dart';

/// Programmatic wrapper around [GraphQLClient] for use outside widget tree.
///
/// For widget-tree queries, prefer [Query] / [Mutation] widgets directly.
class GraphqlService {
  GraphqlService._();

  static final GraphqlService instance = GraphqlService._();

  GraphQLClient get _client => GraphqlClientSetup.client;

  /// Execute a query.
  Future<T> query<T>({
    required String document,
    Map<String, dynamic> variables = const {},
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(document),
        variables: variables,
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException) {
      throw GraphqlException(result.exception.toString());
    }

    return parser(result.data!);
  }

  /// Execute a mutation.
  Future<T> mutate<T>({
    required String document,
    Map<String, dynamic> variables = const {},
    required T Function(Map<String, dynamic> data) parser,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(document),
        variables: variables,
      ),
    );

    if (result.hasException) {
      throw GraphqlException(result.exception.toString());
    }

    return parser(result.data!);
  }
}

class GraphqlException implements Exception {
  GraphqlException(this.message);
  final String message;

  @override
  String toString() => 'GraphqlException: \$message';
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // graphql_flutter: example queries
  // ─────────────────────────────────────────────────────────────────────────

  static String _exampleQueries(BlueprintConfig config) => '''
/// Example GraphQL query strings.
///
/// Replace these with your actual schema queries.
class ExampleQueries {
  ExampleQueries._();

  static const String getUser = r"""
    query GetUser(\$id: ID!) {
      user(id: \$id) {
        id
        name
        email
      }
    }
  """;

  static const String listPosts = r"""
    query ListPosts(\$limit: Int, \$offset: Int) {
      posts(limit: \$limit, offset: \$offset) {
        id
        title
        body
        createdAt
      }
    }
  """;
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // graphql_flutter: example mutations
  // ─────────────────────────────────────────────────────────────────────────

  static String _exampleMutations(BlueprintConfig config) => '''
/// Example GraphQL mutation strings.
///
/// Replace these with your actual schema mutations.
class ExampleMutations {
  ExampleMutations._();

  static const String createPost = r"""
    mutation CreatePost(\$title: String!, \$body: String!) {
      createPost(title: \$title, body: \$body) {
        id
        title
        body
        createdAt
      }
    }
  """;

  static const String updateUser = r"""
    mutation UpdateUser(\$id: ID!, \$name: String, \$email: String) {
      updateUser(id: \$id, name: \$name, email: \$email) {
        id
        name
        email
      }
    }
  """;
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // ferry: client setup
  // ─────────────────────────────────────────────────────────────────────────

  static String _ferryClient(BlueprintConfig config) => '''
import 'package:ferry/ferry.dart';
import 'package:gql_http_link/gql_http_link.dart';

/// Ferry client factory.
///
/// Usage:
/// ```dart
/// final client = FerryClientSetup.create(
///   endpoint: 'https://api.example.com/graphql',
/// );
/// ```
class FerryClientSetup {
  FerryClientSetup._();

  /// Create and return a Ferry [Client] with optional auth token.
  static Client create({
    required String endpoint,
    String? authToken,
  }) {
    final httpLink = HttpLink(
      endpoint,
      defaultHeaders: authToken != null
          ? {'Authorization': 'Bearer \$authToken'}
          : {},
    );

    return Client(link: httpLink);
  }
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // ferry: service wrapper
  // ─────────────────────────────────────────────────────────────────────────

  static String _ferryService(BlueprintConfig config) => '''
import 'package:ferry/ferry.dart';

// ignore: depend_on_referenced_packages
import 'package:gql_exec/gql_exec.dart';

/// Thin wrapper around ferry [Client] for imperative usage alongside streams.
///
/// In most cases you'll consume [client.request] streams directly in your
/// state management layer; this class is a convenience for one-shot calls.
class FerryService {
  FerryService(this._client);

  final Client _client;

  /// Execute a one-shot request and return the first non-loading response.
  Future<OperationResponse<TData, TVars>>
      execute<TData, TVars>(OperationRequest<TData, TVars> request) {
    return _client
        .request(request)
        .firstWhere((response) => !response.loading);
  }
}

class FerryException implements Exception {
  FerryException(this.message);
  final String message;

  @override
  String toString() => 'FerryException: \$message';
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // ferry: SDL schema scaffold
  // ─────────────────────────────────────────────────────────────────────────

  static String _schemaGraphql(BlueprintConfig config) => '''
# GraphQL Schema — replace with your actual schema.
#
# Ferry code-gen reads this file. After modifying run:
#   dart run build_runner build --delete-conflicting-outputs

type Query {
  user(id: ID!): User
  posts(limit: Int, offset: Int): [Post!]!
}

type Mutation {
  createPost(title: String!, body: String!): Post!
  updateUser(id: ID!, name: String, email: String): User!
}

type User {
  id: ID!
  name: String!
  email: String!
}

type Post {
  id: ID!
  title: String!
  body: String!
  createdAt: String!
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // ferry: example operations
  // ─────────────────────────────────────────────────────────────────────────

  static String _exampleOperations(BlueprintConfig config) => '''
# Example operations — ferry will generate type-safe Dart classes from these.
# Run after changes:
#   dart run build_runner build --delete-conflicting-outputs

query GetUser(\$id: ID!) {
  user(id: \$id) {
    id
    name
    email
  }
}

mutation CreatePost(\$title: String!, \$body: String!) {
  createPost(title: \$title, body: \$body) {
    id
    title
    body
    createdAt
  }
}
''';

  // ─────────────────────────────────────────────────────────────────────────
  // ferry: build.yaml for code generation
  // ─────────────────────────────────────────────────────────────────────────

  static String _buildYaml(BlueprintConfig config) => '''
# build.yaml — ferry code-gen configuration.
# Run: dart run build_runner build --delete-conflicting-outputs

targets:
  \$default:
    builders:
      ferry_generator|ferry:
        enabled: true
        options:
          schema: ${config.appName}|lib/core/graphql/schema.graphql
          type_overrides:
            ID:
              name: String
''';
}
