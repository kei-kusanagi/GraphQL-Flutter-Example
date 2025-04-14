import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:graphql_querys/pages/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final HttpLink httpLink = HttpLink('https://graphqlzero.almansi.me/api');

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final ValueNotifier<GraphQLClient> client = ValueNotifier<GraphQLClient>(
      GraphQLClient(cache: GraphQLCache(), link: httpLink),
    );

    return GraphQLProvider(client: client, child: MaterialApp(title: 'GrapQL', home: HomePage()));
  }
}
