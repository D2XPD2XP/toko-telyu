import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/delivery_area.dart';

class DeliveryAreaRepository {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('deliveryAreas');

  Future<void> addDeliveryArea(DeliveryArea area) async {
    await _collection.doc(area.getAreaId()).set(area.toFirestore());
  }

  Future<List<DeliveryArea>> getAllAreas() async {
    final querySnapshot = await _collection.get();
    return querySnapshot.docs
        .map((doc) => DeliveryArea.fromFirestore(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryArea?> getAreaById(String id) async {
    final doc = await _collection.doc(id).get();
    if (!doc.exists) return null;
    return DeliveryArea.fromFirestore(doc.data() as Map<String, dynamic>);
  }

  Future<void> updateDeliveryArea(DeliveryArea area) async {
    await _collection.doc(area.getAreaId()).update(area.toFirestore());
  }

  Future<void> deleteDeliveryArea(String id) async {
    await _collection.doc(id).delete();
  }
}
