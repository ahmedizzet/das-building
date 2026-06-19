import '../entities/amenity.dart';

abstract class AmenityRepository {
  Future<List<Amenity>> getAmenities();
  Stream<List<Amenity>> watchAmenities();
}
