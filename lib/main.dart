import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() {
  const url = 'https://rickandmortyapi.com/graphql';

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: HttpLink(url),
      cache: GraphQLCache(),
    ),
  );

  runApp(
    MyHomePage(
      client: client.value,
    ),
  );
}

class MyHomePage extends StatefulWidget {
  final GraphQLClient client;

  const MyHomePage({required this.client, super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<QueryResult<Object?>> query;

  @override
  void initState() {
    super.initState();
    query = widget.client.query(
      QueryOptions(
        document: gql(queryCharacterNames),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Demo Home Page'),
        ),
        body: FutureBuilder(
          future: query,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              if (snapshot.data!.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.data!.hasException) {
                return Text(snapshot.data!.exception!.graphqlErrors.first.message);
              }

              List? characters = snapshot.data!.data?['characters']?['results'];

              if (characters == null) {
                return const Center(
                  child: Text('No characters found'),
                );
              }

              return ListView.builder(
                itemCount: characters.length,
                itemBuilder: (context, index) {
                  final character = characters[index];
                  return ListTile(title: Text(character['name'] ?? ''));
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}

String queryCharacterNames = '''
query {
  characters {
    results {
      name
    }
  }
}
''';
