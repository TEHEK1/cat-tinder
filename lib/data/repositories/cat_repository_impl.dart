import '../../domain/entities/cat.dart';
import '../../domain/entities/breed.dart';
import '../../domain/repositories/cat_repository.dart';
import '../datasources/cat_api_datasource.dart';

class CatRepositoryImpl implements CatRepository {
  final CatApiDataSource _dataSource;

  CatRepositoryImpl(this._dataSource);

  @override
  Future<Cat> getRandomCat() => _dataSource.getRandomCat();

  @override
  Future<List<Breed>> getAllBreeds() => _dataSource.getAllBreeds();

  @override
  Future<List<Cat>> getCatsByBreed(String breedId) =>
      _dataSource.getCatsByBreed(breedId);
}
