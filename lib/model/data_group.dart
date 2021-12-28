import 'dart:convert';

class DataGroup {
  String text;
  String? date;
  DataGroup({
    required this.text,
    this.date,
  });

  DataGroup copyWith({
    String? text,
    String? date,
  }) {
    return DataGroup(
      text: text ?? this.text,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'date': date,
    };
  }

  factory DataGroup.fromMap(Map<String, dynamic> map) {
    return DataGroup(
      text: map['text'],
      date: map['date'] ?? null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DataGroup.fromJson(String source) =>
      DataGroup.fromMap(json.decode(source));

  @override
  String toString() => 'DataGroup(text: $text, date: $date)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DataGroup && other.text == text && other.date == date;
  }

  @override
  int get hashCode => text.hashCode ^ date.hashCode;
}
