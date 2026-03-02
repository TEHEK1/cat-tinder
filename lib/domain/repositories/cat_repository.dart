import '../entities/cat.dart';
import '../entities/breed.dart';

abstract class CatRepository {
  Future<Cat> getRandomCat();
  Future<List<Breed>> getAllBreeds();
  Future<List<Cat>> getCatsByBreed(String breedId);
}
