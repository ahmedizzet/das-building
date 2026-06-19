import 'package:isar/isar.dart';
import '../../domain/entities/amenity.dart' as entity;
import '../../domain/repositories/amenity_repository.dart';
import '../models/amenity.dart' as model;

class IsarAmenityRepository implements AmenityRepository {
  final Isar isar;

  IsarAmenityRepository(this.isar);

  @override
  Future<List<entity.Amenity>> getAmenities() async {
    final amenities = await isar.amenitys.where().filter().isDeletedEqualTo(false).findAll();
    return amenities.map((e) => _toEntity(e)).toList();
  }

  @override
  Stream<List<entity.Amenity>> watchAmenities() {
    return isar.amenitys
        .where()
        .filter()
        .isDeletedEqualTo(false)
        .watch(fireImmediately: true)
        .map((amenities) => amenities.map((e) => _toEntity(e)).toList());
  }

  entity.Amenity _toEntity(model.Amenity m) {
    return entity.Amenity(
      id: m.serverId,
      title: m.title,
      imageUrl: m.imageUrl,
      policy: m.policy,
    );
  }
}
