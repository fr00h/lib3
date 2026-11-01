import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'core/api_client.dart';
import 'models/author.dart';
import 'models/genre.dart';
import 'models/publisher.dart';
import 'models/reader.dart';
import 'repositories/api_book_repository.dart';
import 'repositories/api_entity_repository.dart';
import 'repositories/book_repository.dart';
import 'repositories/entity_repository.dart';
import 'router.dart';
import 'state/book_list_notifier.dart';
import 'state/entity_list_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  String? token;
  final dio = buildDio(tokenProvider: () => token);
  token = await loginAsAdmin(dio);

  runApp(
    MultiProvider(
      providers: [
        Provider<Dio>.value(value: dio),
        ProxyProvider<Dio, BookRepository>(
          update: (context, dio, previous) => ApiBookRepository(dio),
        ),
        ProxyProvider<Dio, EntityRepository<Author>>(
          update: (context, dio, previous) => ApiEntityRepository<Author>(
            dio,
            '/authors',
            Author.fromJson,
            (a) => a.toJson(),
            (a) => a.id,
          ),
        ),
        ProxyProvider<Dio, EntityRepository<Genre>>(
          update: (context, dio, previous) => ApiEntityRepository<Genre>(
            dio,
            '/genres',
            Genre.fromJson,
            (g) => g.toJson(),
            (g) => g.id,
          ),
        ),
        ProxyProvider<Dio, EntityRepository<Publisher>>(
          update: (context, dio, previous) => ApiEntityRepository<Publisher>(
            dio,
            '/publishers',
            Publisher.fromJson,
            (p) => p.toJson(),
            (p) => p.id,
          ),
        ),
        ProxyProvider<Dio, EntityRepository<Reader>>(
          update: (context, dio, previous) => ApiEntityRepository<Reader>(
            dio,
            '/readers',
            Reader.fromJson,
            (r) => r.toJson(),
            (r) => r.id,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BookListNotifier(
            context.read<BookRepository>(),
            context.read<EntityRepository<Author>>(),
            context.read<EntityRepository<Genre>>(),
            context.read<EntityRepository<Publisher>>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EntityListNotifier<Author>(context.read<EntityRepository<Author>>()),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EntityListNotifier<Genre>(context.read<EntityRepository<Genre>>()),
        ),
        ChangeNotifierProvider(
          create: (context) => EntityListNotifier<Publisher>(
            context.read<EntityRepository<Publisher>>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              EntityListNotifier<Reader>(context.read<EntityRepository<Reader>>()),
        ),
      ],
      child: const LibraryApp(),
    ),
  );
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Библиотека',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
