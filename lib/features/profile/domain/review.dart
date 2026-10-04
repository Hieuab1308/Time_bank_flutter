class Review {
  final String author;
  final String text;
  final int rating; // 1..5
  final DateTime date;

  Review({required this.author, required this.text, required this.rating, required this.date});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        author: json['author'] as String,
        text: json['text'] as String,
        rating: (json['rating'] as int),
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'author': author,
        'text': text,
        'rating': rating,
        'date': date.toIso8601String(),
      };
}
