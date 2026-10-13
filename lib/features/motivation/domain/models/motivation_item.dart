enum MotivationType {
  quran,
  hadith,
  study,
  discipline;

  String get displayName {
    switch (this) {
      case MotivationType.quran:
        return 'কুরআনুল কারীম';
      case MotivationType.hadith:
        return 'হাদীস শরীফ';
      case MotivationType.study:
        return 'জ্ঞানার্জন';
      case MotivationType.discipline:
        return 'সময় ও অধ্যবসায়';
    }
  }
}

class MotivationItem {
  final String id;
  final MotivationType type;
  final String text;
  final String source;
  final String reference;
  final String language;
  final bool active;

  const MotivationItem({
    required this.id,
    required this.type,
    required this.text,
    required this.source,
    required this.reference,
    this.language = 'bn',
    this.active = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'text': text,
      'source': source,
      'reference': reference,
      'language': language,
      'active': active,
    };
  }

  factory MotivationItem.fromJson(Map<String, dynamic> json) {
    return MotivationItem(
      id: json['id'] as String,
      type: MotivationType.values.byName(json['type'] as String? ?? 'hadith'),
      text: json['text'] as String,
      source: json['source'] as String,
      reference: json['reference'] as String,
      language: json['language'] as String? ?? 'bn',
      active: json['active'] as bool? ?? true,
    );
  }
}
