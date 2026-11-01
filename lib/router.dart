import 'package:go_router/go_router.dart';

import 'models/book_query.dart';
import 'models/list_query.dart';
import 'screens/author_detail_screen.dart';
import 'screens/author_form_screen.dart';
import 'screens/author_list_screen.dart';
import 'screens/book_detail_screen.dart';
import 'screens/book_form_screen.dart';
import 'screens/book_list_screen.dart';
import 'screens/genre_detail_screen.dart';
import 'screens/genre_form_screen.dart';
import 'screens/genre_list_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/publisher_detail_screen.dart';
import 'screens/publisher_form_screen.dart';
import 'screens/publisher_list_screen.dart';
import 'screens/reader_detail_screen.dart';
import 'screens/reader_form_screen.dart';
import 'screens/reader_list_screen.dart';
import 'widgets/app_shell.dart';

int _id(GoRouterState state) => int.tryParse(state.pathParameters['id']!) ?? 0;

ListQuery _query(GoRouterState state, String sort) =>
    ListQuery.fromParams(state.uri.path, sort, state.uri.queryParameters);

final appRouter = GoRouter(
  initialLocation: '/books',
  errorBuilder: (context, state) =>
      NotFoundScreen(location: state.uri.toString()),
  routes: [
    GoRoute(path: '/', redirect: (context, state) => '/books'),
    ShellRoute(
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        GoRoute(
          path: '/books',
          builder: (context, state) => BookListScreen(
            query: BookQuery.fromParams(state.uri.queryParameters),
          ),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const BookFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => BookDetailScreen(id: _id(state)),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => BookFormScreen(id: _id(state)),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/authors',
          builder: (context, state) =>
              AuthorListScreen(query: _query(state, 'fullName')),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const AuthorFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => AuthorDetailScreen(id: _id(state)),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      AuthorFormScreen(id: _id(state)),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/genres',
          builder: (context, state) =>
              GenreListScreen(query: _query(state, 'name')),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const GenreFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => GenreDetailScreen(id: _id(state)),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) => GenreFormScreen(id: _id(state)),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/publishers',
          builder: (context, state) =>
              PublisherListScreen(query: _query(state, 'name')),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const PublisherFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) =>
                  PublisherDetailScreen(id: _id(state)),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      PublisherFormScreen(id: _id(state)),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          path: '/readers',
          builder: (context, state) =>
              ReaderListScreen(query: _query(state, 'fullName')),
          routes: [
            GoRoute(
              path: 'new',
              builder: (context, state) => const ReaderFormScreen(),
            ),
            GoRoute(
              path: ':id',
              builder: (context, state) => ReaderDetailScreen(id: _id(state)),
              routes: [
                GoRoute(
                  path: 'edit',
                  builder: (context, state) =>
                      ReaderFormScreen(id: _id(state)),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);
