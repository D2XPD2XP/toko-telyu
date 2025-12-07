class DeliveryArea {
  String _areaId;
  String _areaName;
  double _deliveryFee;

  DeliveryArea(this._areaId, this._areaName, this._deliveryFee);

  // Getters
  String getAreaId() => _areaId;
  String getAreaname() => _areaName;
  double getDeliveryfee() => _deliveryFee;

  // Setters
  void setAreaId(String areaId) {
    _areaId = areaId;
  }

  void setAreaname(String areaName) {
    _areaName = areaName;
  }

  void setDeliveryfee(double fee) {
    _deliveryFee = fee;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'areaId': _areaId,
      'areaName': _areaName,
      'deliveryFee': _deliveryFee,
    };
  }
  
  static DeliveryArea fromFirestore(Map<String, dynamic> data) {
    return DeliveryArea(
      data['areaId'] as String,
      data['areaName'] as String,
      (data['deliveryFee'] as num).toDouble(),
    );
  }
}
