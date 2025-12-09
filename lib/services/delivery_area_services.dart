import 'package:toko_telyu/repositories/delivery_area_repositories.dart';
import 'package:uuid/uuid.dart';
import '../models/delivery_area.dart';

class DeliveryAreaService {
  final DeliveryAreaRepository _repository = DeliveryAreaRepository();
  final Uuid _uuid = const Uuid();

  // CREATE dengan UUID v4 yang digenerate di Service
  Future<void> createArea(String name, double fee) async {
    final generatedId = _uuid.v4();
    final area = DeliveryArea(generatedId, name, fee);
    await _repository.addDeliveryArea(area);
  }

  // READ ALL
  Future<List<DeliveryArea>> fetchAllAreas() async {
    return await _repository.getAllAreas();
  }

  // READ ONE
  Future<DeliveryArea?> fetchArea(String id) async {
    return await _repository.getAreaById(id);
  }

  // UPDATE (id tetap dipassing secara manual)
  Future<void> updateArea(String id, String name, double fee) async {
    final area = DeliveryArea(id, name, fee);
    await _repository.updateDeliveryArea(area);
  }

  // DELETE
  Future<void> deleteArea(String id) async {
    await _repository.deleteDeliveryArea(id);
  }
}
