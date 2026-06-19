class Announcement {
  final String id;
  final String title;
  final String content;
  final String author;
  final DateTime date;
  final bool isPinned;
  final String? category;
  final String? imageUrl;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.author,
    required this.date,
    required this.isPinned,
    this.category,
    this.imageUrl,
  });
}
