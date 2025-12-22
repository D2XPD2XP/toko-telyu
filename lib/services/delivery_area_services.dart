import 'package:toko_telyu/repositories/delivery_area_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/delivery_area.dart';

class DeliveryAreaService {
  final DeliveryAreaRepository _repository;
  final Uuid _uuid;

  DeliveryAreaService({
    DeliveryAreaRepository? repository,
    Uuid? uuid,
  })  : _repository = repository ?? DeliveryAreaRepository(),
        _uuid = uuid ?? const Uuid();

  Future<void> createArea(String name, double fee) async {
    final generatedId = _uuid.v4();
    final area = DeliveryArea(generatedId, name, fee);
    await _repository.addDeliveryArea(area);
  }

  Future<List<DeliveryArea>> fetchAllAreas() async {
    return await _repository.getAllAreas();
  }

  Future<DeliveryArea?> fetchArea(String id) async {
    return await _repository.getAreaById(id);
  }

  Future<void> updateArea(String id, String name, double fee) async {
    final area = DeliveryArea(id, name, fee);
    await _repository.updateDeliveryArea(area);
  }

  Future<void> deleteArea(String id) async {
    await _repository.deleteDeliveryArea(id);
  }
}

