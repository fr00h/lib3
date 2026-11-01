class BookQuery {
  final String search;
  final int? genreId;
  final int? publisherId;
  final int? yearFrom;
  final int? yearTo;
  final String sortField;
  final bool sortAscending;
  final int page;
  final int size;
  final bool includeDeleted;

  const BookQuery({
    this.search = '',
    this.genreId,
    this.publisherId,
    this.yearFrom,
    this.yearTo,
    this.sortField = 'title',
    this.sortAscending = true,
    this.page = 1,
    this.size = 10,
    this.includeDeleted = false,
  });

  BookQuery copyWith({
    String? search,
    Object? genreId = _unset,
    Object? publisherId = _unset,
    Object? yearFrom = _unset,
    Object? yearTo = _unset,
    String? sortField,
    bool? sortAscending,
    int? page,
    int? size,
    bool? includeDeleted,
  }) {
    return BookQuery(
      search: search ?? this.search,
      genreId: genreId == _unset ? this.genreId : genreId as int?,
      publisherId:
          publisherId == _unset ? this.publisherId : publisherId as int?,
      yearFrom: yearFrom == _unset ? this.yearFrom : yearFrom as int?,
      yearTo: yearTo == _unset ? this.yearTo : yearTo as int?,
      sortField: sortField ?? this.sortField,
      sortAscending: sortAscending ?? this.sortAscending,
      page: page ?? 1,
      size: size ?? this.size,
      includeDeleted: includeDeleted ?? this.includeDeleted,
    );
  }

  static const _unset = Object();

  factory BookQuery.fromParams(Map<String, String> p) {
    final sort = (p['sort'] ?? 'title,asc').split(',');
    return BookQuery(
      search: p['search'] ?? '',
      genreId: int.tryParse(p['genreId'] ?? ''),
      publisherId: int.tryParse(p['publisherId'] ?? ''),
      yearFrom: int.tryParse(p['yearFrom'] ?? ''),
      yearTo: int.tryParse(p['yearTo'] ?? ''),
      sortField: sort.first,
      sortAscending: sort.length < 2 || sort[1] != 'desc',
      page: int.tryParse(p['page'] ?? '') ?? 1,
      size: int.tryParse(p['size'] ?? '') ?? 10,
      includeDeleted: p['includeDeleted'] == 'true',
    );
  }

  Map<String, String> toParams() => {
        if (search.isNotEmpty) 'search': search,
        if (genreId != null) 'genreId': '$genreId',
        if (publisherId != null) 'publisherId': '$publisherId',
        if (yearFrom != null) 'yearFrom': '$yearFrom',
        if (yearTo != null) 'yearTo': '$yearTo',
        if (sortField != 'title' || !sortAscending)
          'sort': '$sortField,${sortAscending ? 'asc' : 'desc'}',
        if (page != 1) 'page': '$page',
        if (size != 10) 'size': '$size',
        if (includeDeleted) 'includeDeleted': 'true',
      };

  String get location {
    final params = toParams();
    if (params.isEmpty) return '/books';
    final query = params.entries
        .map((e) =>
            '${e.key}=${Uri.encodeComponent(e.value).replaceAll('%2C', ',')}')
        .join('&');
    return '/books?$query';
  }
}
