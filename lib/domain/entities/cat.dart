import 'breed.dart';

class Cat {
  final String id;
  final String url;
  final List<Breed> breeds;

  Cat({required this.id, required this.url, required this.breeds});

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'] as String,
      url: json['url'] as String,
      breeds:
          (json['breeds'] as List<dynamic>?)
              ?.map((breed) => Breed.fromJson(breed as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'url': url,
      'breeds': breeds.map((breed) => breed.toJson()).toList(),
    };
  }

  bool get hasBreed => breeds.isNotEmpty;

  Breed? get primaryBreed => breeds.isNotEmpty ? breeds.first : null;
}
