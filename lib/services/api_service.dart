import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cat.dart';
import '../models/breed.dart';
import 'api_constants.dart';

class ApiService {
  Future<Cat> getRandomCat() async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.imagesSearch}?has_breeds=1&limit=1',
        ),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        if (data.isEmpty) {
          throw Exception('No cats found');
        }
        return Cat.fromJson(data[0] as Map<String, dynamic>);
      } else {
        throw Exception(
          'Failed to load cat: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Breed>> getAllBreeds() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.breeds}'),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((breed) => Breed.fromJson(breed as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load breeds: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<Cat>> getCatsByBreed(String breedId) async {
    try {
      final response = await http.get(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.imagesSearch}?breed_ids=$breedId&limit=5',
        ),
        headers: ApiConstants.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((cat) => Cat.fromJson(cat as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Failed to load cats: ${response.statusCode} - ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
