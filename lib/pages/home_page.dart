import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentPage = 1;
  int currentLimit = 5;

  final String getAlbums = r"""
    query getAlbums($page: Int, $limit: Int) {
      albums(options: { paginate: { page: $page, limit: $limit } }) {
        data {
          id
          title
          user {
            name
            username
            email
          }
        }
      }
    }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Albums')),
      body: Query(
        options: QueryOptions(
          document: gql(getAlbums),
          variables: {'page': currentPage, 'limit': currentLimit},
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          List albums = result.data?['albums']?['data'] ?? [];

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return ListTile(
                      title: Text(album['title']),
                      subtitle: Text(album['user']['name']),
                    );
                  },
                ),
              ),
              Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Página: "),
                    DropdownButton<int>(
                      value: currentPage,
                      items: List.generate(10, (index) {
                        int value = index + 1;
                        return DropdownMenuItem(value: value, child: Text(value.toString()));
                      }),
                      onChanged: (value) {
                        setState(() {
                          currentPage = value!;
                        });
                      },
                    ),
                    SizedBox(width: 20),
                    Text("Límite: "),
                    DropdownButton<int>(
                      value: currentLimit,
                      items:
                          [2, 5, 10, 20].map((limit) {
                            return DropdownMenuItem(value: limit, child: Text(limit.toString()));
                          }).toList(),
                      onChanged: (value) {
                        setState(() {
                          currentLimit = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
