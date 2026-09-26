class PaginationMeta {
  final int page;
  final int limit;
  final int total;
  final int totalPage;

  const PaginationMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPage,
  });

  bool get hasNextPage => page < totalPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      total: json['total'] ?? 0,
      totalPage: json['totalPage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'total': total,
      'totalPage': totalPage,
    };
  }
}
