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
}
