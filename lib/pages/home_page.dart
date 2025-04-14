import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

// Pantalla principal que muestra la lista de álbumes con paginación manual
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables que controlan la página actual y la cantidad de elementos por página
  int currentPage = 1;
  int currentLimit = 5;

  // Consulta GraphQL con variables para paginación ($page y $limit)
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

      // El cuerpo hace una consulta a GraphQL usando el widget Query
      body: Query(
        options: QueryOptions(
          document: gql(getAlbums), // Pasa la consulta
          variables: {'page': currentPage, 'limit': currentLimit}, // Pasa las variables
        ),
        builder: (QueryResult result, {fetchMore, refetch}) {
          // Si hay error, lo muestra
          if (result.hasException) {
            return Center(child: Text(result.exception.toString()));
          }

          // Si está cargando, muestra un spinner
          if (result.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          // Obtiene la lista de álbumes desde los datos recibidos
          List albums = result.data?['albums']?['data'] ?? [];

          return Column(
            children: [
              // Lista expandible con los álbumes obtenidos
              Expanded(
                child: ListView.builder(
                  itemCount: albums.length,
                  itemBuilder: (context, index) {
                    final album = albums[index];
                    return ListTile(
                      title: Text(album['title']), // Título del álbum
                      subtitle: Text(album['user']['name']), // Nombre del usuario que lo subió
                    );
                  },
                ),
              ),

              // Línea divisora entre la lista y la parte inferior
              Divider(height: 1),

              // Parte inferior con los controles para seleccionar página y límite
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Selector de página
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
                        }); // Cambia de página y vuelve a ejecutar la consulta
                      },
                    ),

                    SizedBox(width: 20),

                    // Selector de cantidad de elementos por página
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
                        }); // Cambia el límite y vuelve a ejecutar la consulta
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
