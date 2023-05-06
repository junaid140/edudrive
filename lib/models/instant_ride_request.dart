class InstantRideRequest {
  String? requestStatus;
  String? driverId;
  Dropoff? dropoff;
  String? createdAt;
  String? pickupAddress;
  Dropoff? pickup;
  String? id;
  String? dropoffAddress;
  String? parentId;
  String? paymentMethod;
  String? parentName;
  String? parentPhone;

  InstantRideRequest(
      {this.requestStatus,
        this.driverId,
        this.dropoff,
        this.createdAt,
        this.pickupAddress,
        this.pickup,
        this.id,
        this.dropoffAddress,
        this.parentId,
        this.parentName,
        this.parentPhone,
        this.paymentMethod});

  InstantRideRequest.fromJson(Map<String, dynamic> json) {
    requestStatus = json['request_status'];
    driverId = json['driver_id'];
    dropoff =
    json['dropoff'] != null ? new Dropoff.fromJson(json['dropoff']) : null;
    createdAt = json['created_at'];
    pickupAddress = json['pickup_address'];
    pickup =
    json['pickup'] != null ? new Dropoff.fromJson(json['pickup']) : null;
    id = json['id'];
    dropoffAddress = json['dropoff_address'];
    parentId = json['parentId'];
    paymentMethod = json['payment_method'];
    paymentMethod = json['name']??"";
    paymentMethod = json['parentPhone']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['request_status'] = this.requestStatus;
    data['driver_id'] = this.driverId;
    if (this.dropoff != null) {
      data['dropoff'] = this.dropoff!.toJson();
    }
    data['created_at'] = this.createdAt;
    data['pickup_address'] = this.pickupAddress;
    if (this.pickup != null) {
      data['pickup'] = this.pickup!.toJson();
    }
    data['id'] = this.id;
    data['dropoff_address'] = this.dropoffAddress;
    data['parentId'] = this.parentId;
    data['payment_method'] = this.paymentMethod;
    return data;
  }
}

class Dropoff {
  double? latitude;
  double? longitude;

  Dropoff({this.latitude, this.longitude});

  Dropoff.fromJson(Map<String, dynamic> json) {
    latitude = json['latitude'];
    longitude = json['longitude'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['latitude'] = this.latitude;
    data['longitude'] = this.longitude;
    return data;
  }
}
