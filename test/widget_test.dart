import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:mock_graphql_for_tests/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<GraphQLClient>(),
])
void main() {
  late MockGraphQLClient mockGraphQLClient;

  setUpAll(() {
    mockGraphQLClient = MockGraphQLClient();
  });

  void mockQueryResponse({
    required Map<String, dynamic>? data,
    bool isLoading = false,
    String? errorMessage,
  }) {
    final options = QueryOptions(
      document: gql(queryCharacterNames),
    );
    when(
      mockGraphQLClient.query(options),
    ).thenAnswer(
      (_) => Future.value(
        QueryResult(
          options: options,
          source:
              isLoading ? QueryResultSource.loading : QueryResultSource.network,
          data: data,
          exception: errorMessage != null
              ? OperationException(
                  graphqlErrors: [
                    GraphQLError(message: errorMessage),
                  ],
                )
              : null,
        ),
      ),
    );
  }

  testWidgets(
      'renders ListTiles with correct character names when request is successful',
      (WidgetTester tester) async {
    mockQueryResponse(data: data);
    await tester.pumpWidget(
      MyHomePage(client: mockGraphQLClient),
    );
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'Rick Sanchez'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Morty Smith'), findsOneWidget);
    expect(find.byType(ListTile), findsNWidgets(2));
  });

  testWidgets('renders CircularProgressIndicator when request is loading',
      (WidgetTester tester) async {
    mockQueryResponse(data: null, isLoading: true);
    await tester.pumpWidget(
      MyHomePage(client: mockGraphQLClient),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('renders Text with error message when request has error',
      (WidgetTester tester) async {
    const errorMessage = 'custom error message';
    mockQueryResponse(data: null, errorMessage: errorMessage);
    await tester.pumpWidget(
      MyHomePage(client: mockGraphQLClient),
    );
    await tester.pump();

    expect(find.text(errorMessage), findsOneWidget);
  });
}

const data = {
  "characters": {
    "results": [
      {"name": "Rick Sanchez"},
      {"name": "Morty Smith"},
    ]
  }
};
