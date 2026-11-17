import 'dart:convert';

class HistoryModel {
  Message message;
  Data data;
  String type;

  HistoryModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) => HistoryModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "message": message.toJson(),
        "data": data.toJson(),
        "type": type,
      };
}

class Data {
  List<History> history;

  Data({
    required this.history,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        history:
            List<History>.from(json["history"].map((x) => History.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "history": List<dynamic>.from(history.map((x) => x.toJson())),
      };
}

class History {
  int id;
  int carId;
  dynamic branchId;
  int userId;
  String slug;
  String phone;
  String email;
  int tripId;
  int bookingId;
  int rentalDays;
  dynamic allowanceKm;
  String carModel;
  String carNumber;
  String location;
  double pickupLatitude;
  double pickupLongitude;
  String pickupAddress;
  String destination;
  String paymentType;
  String trxId;
  dynamic amount;
  dynamic charges;
  dynamic deliveryFee;
  dynamic taxAmount;
  dynamic taxPercentage;
  dynamic subtotal;
  dynamic totalAmount;
  dynamic balanceDeducted;
  bool isDelivery;
  bool paidFromBalance;
  dynamic distance;
  String pickupTime;
  dynamic roundPickupTime;
  DateTime pickupDate;
  dynamic roundPickupDate;
  String message;
  int status;
  dynamic returnDate;
  dynamic originalRentalDays;
  int extensionCount;
  int totalExtensionDays;
  bool isExtendable;
  int daysRemaining;
  dynamic totalExtensionCost;
  dynamic rejectionReason;
  DateTime createdAt;
  DateTime updatedAt;
  Cars cars;

  History({
    required this.id,
    required this.carId,
    this.branchId,
    required this.userId,
    required this.slug,
    required this.phone,
    required this.email,
    required this.tripId,
    required this.bookingId,
    required this.rentalDays,
    this.allowanceKm,
    required this.carModel,
    required this.carNumber,
    required this.location,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.destination,
    required this.paymentType,
    required this.trxId,
    required this.amount,
    required this.charges,
    required this.deliveryFee,
    required this.taxAmount,
    required this.taxPercentage,
    required this.subtotal,
    required this.totalAmount,
    this.balanceDeducted,
    required this.isDelivery,
    required this.paidFromBalance,
    required this.distance,
    required this.pickupTime,
    this.roundPickupTime,
    required this.pickupDate,
    this.roundPickupDate,
    required this.message,
    required this.status,
    this.returnDate,
    this.originalRentalDays,
    required this.extensionCount,
    required this.totalExtensionDays,
    required this.isExtendable,
    required this.daysRemaining,
    this.totalExtensionCost,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    required this.cars,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
        id: json["id"] ?? 0,
        carId: json["car_id"] ?? 0,
        branchId: json["branch_id"],
        userId: json["user_id"] ?? 0,
        slug: json["slug"] ?? '',
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        tripId: json["trip_id"] ?? 0,
        bookingId: int.tryParse(json["booking_id"]?.toString() ?? '0') ?? 0,
        rentalDays: json["rental_days"] ?? 0,
        allowanceKm: json["allowance_km"],
        carModel: json["car_model"] ?? '',
        carNumber: json["car_number"] ?? '',
        location: json["location"] ?? '',
        pickupLatitude: (json["pickup_latitude"] ?? 0).toDouble(),
        pickupLongitude: (json["pickup_longitude"] ?? 0).toDouble(),
        pickupAddress: json["pickup_address"] ?? '',
        destination: json["destination"] ?? '',
        paymentType: json["payment_type"] ?? '',
        trxId: json["trx_id"] ?? '',
        amount: json["amount"],
        charges: json["charges"],
        deliveryFee: json["delivery_fee"],
        taxAmount: json["tax_amount"],
        taxPercentage: json["tax_percentage"],
        subtotal: json["subtotal"],
        totalAmount: json["total_amount"],
        balanceDeducted: json["balance_deducted"],
        isDelivery: json["is_delivery"] ?? false,
        paidFromBalance: json["paid_from_balance"] ?? false,
        distance: json["distance"],
        pickupTime: json["pickup_time"] ?? '',
        roundPickupTime: json["round_pickup_time"],
        pickupDate: DateTime.parse(json["pickup_date"]),
        roundPickupDate: json["round_pickup_date"],
        message: json["message"] ?? '',
        status: json["status"] ?? 0,
        returnDate: json["return_date"],
        originalRentalDays: json["original_rental_days"],
        extensionCount: json["extension_count"] ?? 0,
        totalExtensionDays: json["total_extension_days"] ?? 0,
        isExtendable: json["is_extendable"] ?? false,
        daysRemaining: json["days_remaining"] ?? 0,
        totalExtensionCost: json["total_extension_cost"],
        rejectionReason: json["rejection_reason"],
        createdAt: DateTime.tryParse(json["created_at"] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json["updated_at"] ?? '') ?? DateTime.now(),
        cars: Cars.fromJson(json["cars"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "car_id": carId,
        "branch_id": branchId,
        "user_id": userId,
        "slug": slug,
        "phone": phone,
        "email": email,
        "trip_id": tripId,
        "booking_id": bookingId,
        "rental_days": rentalDays,
        "allowance_km": allowanceKm,
        "car_model": carModel,
        "car_number": carNumber,
        "location": location,
        "pickup_latitude": pickupLatitude,
        "pickup_longitude": pickupLongitude,
        "pickup_address": pickupAddress,
        "destination": destination,
        "payment_type": paymentType,
        "trx_id": trxId,
        "amount": amount,
        "charges": charges,
        "delivery_fee": deliveryFee,
        "tax_amount": taxAmount,
        "tax_percentage": taxPercentage,
        "subtotal": subtotal,
        "total_amount": totalAmount,
        "balance_deducted": balanceDeducted,
        "is_delivery": isDelivery,
        "paid_from_balance": paidFromBalance,
        "distance": distance,
        "pickup_time": pickupTime,
        "round_pickup_time": roundPickupTime,
        "pickup_date":
            "${pickupDate.year.toString().padLeft(4, '0')}-${pickupDate.month.toString().padLeft(2, '0')}-${pickupDate.day.toString().padLeft(2, '0')}",
        "round_pickup_date": roundPickupDate,
        "message": message,
        "status": status,
        "return_date": returnDate,
        "original_rental_days": originalRentalDays,
        "extension_count": extensionCount,
        "total_extension_days": totalExtensionDays,
        "is_extendable": isExtendable,
        "days_remaining": daysRemaining,
        "total_extension_cost": totalExtensionCost,
        "rejection_reason": rejectionReason,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "cars": cars.toJson(),
      };
}

class Cars {
  int id;
  int vendorId;
  dynamic carAreaId;
  dynamic branchId;
  int carTypeId;
  int carModelId;
  String slug;
  Map<String, dynamic> carTitle;
  dynamic carModel;
  dynamic carNumber;
  String carType;
  int seat;
  int year;
  dynamic experience;
  String fees;
  String pricePerDay;
  String pricePerWeek;
  String pricePerMonth;
  dynamic allowanceKm;
  dynamic allowancePricePerKm;
  String image;
  int status;
  int approval;
  String branchName;
  double branchLatitude;
  double branchLongitude;
  bool deliveryEnabled;
  dynamic deliveryRadiusKm;
  DateTime createdAt;
  DateTime updatedAt;
  String imageUrl;
  Vendor? vendor;
  Branch? branch;

  Cars({
    required this.id,
    required this.vendorId,
    this.carAreaId,
    this.branchId,
    required this.carTypeId,
    required this.carModelId,
    required this.slug,
    required this.carTitle,
    this.carModel,
    this.carNumber,
    required this.carType,
    required this.seat,
    required this.year,
    this.experience,
    required this.fees,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    this.allowanceKm,
    this.allowancePricePerKm,
    required this.image,
    required this.status,
    required this.approval,
    required this.branchName,
    required this.branchLatitude,
    required this.branchLongitude,
    required this.deliveryEnabled,
    this.deliveryRadiusKm,
    required this.createdAt,
    required this.updatedAt,
    required this.imageUrl,
    this.vendor,
    this.branch,
  });

  factory Cars.fromJson(Map<String, dynamic> json) => Cars(
        id: json["id"] ?? 0,
        vendorId: json["vendor_id"] ?? 0,
        carAreaId: json["car_area_id"],
        branchId: json["branch_id"],
        carTypeId: json["car_type_id"] ?? 0,
        carModelId: json["car_model_id"] ?? 0,
        slug: json["slug"] ?? '',
        carTitle: json["car_title"] is Map
            ? Map<String, dynamic>.from(json["car_title"])
            : (json["car_title"] is String && json["car_title"].toString().isNotEmpty
                ? Map<String, dynamic>.from(jsonDecode(json["car_title"] as String))
                : <String, dynamic>{}),        carModel: json["car_model"],
        carNumber: json["car_number"],
        carType: json["car_type"] ?? '',
        seat: json["seat"] ?? 0,
        year: json["year"] ?? 0,
        experience: json["experience"],
        fees: json["fees"]?.toString() ?? '0',
        pricePerDay: json["price_per_day"]?.toString() ?? '0',
        pricePerWeek: json["price_per_week"]?.toString() ?? '0',
        pricePerMonth: json["price_per_month"]?.toString() ?? '0',
        allowanceKm: json["allowance_km"],
        allowancePricePerKm: json["allowance_price_per_km"],
        image: json["image"] ?? '',
        status: json["status"] ?? 0,
        approval: json["approval"] ?? 0,
        branchName: json["branch_name"] ?? '',
        branchLatitude: (json["branch_latitude"] ?? 0).toDouble(),
        branchLongitude: (json["branch_longitude"] ?? 0).toDouble(),
        deliveryEnabled: json["delivery_enabled"] ?? false,
        deliveryRadiusKm: json["delivery_radius_km"],
        createdAt: DateTime.parse(json["created_at"] ?? DateTime.now().toIso8601String()),
        updatedAt: DateTime.parse(json["updated_at"] ?? DateTime.now().toIso8601String()),
        imageUrl: json["image_url"] ?? '',
        vendor: json["vendor"] != null ? Vendor.fromJson(json["vendor"]) : null,
        branch: json["branch"] != null ? Branch.fromJson(json["branch"]) : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "vendor_id": vendorId,
        "car_area_id": carAreaId,
        "branch_id": branchId,
        "car_type_id": carTypeId,
        "car_model_id": carModelId,
        "slug": slug,
        "car_title": carTitle,
        "car_model": carModel,
        "car_number": carNumber,
        "car_type": carType,
        "seat": seat,
        "year": year,
        "experience": experience,
        "fees": fees,
        "price_per_day": pricePerDay,
        "price_per_week": pricePerWeek,
        "price_per_month": pricePerMonth,
        "allowance_km": allowanceKm,
        "allowance_price_per_km": allowancePricePerKm,
        "image": image,
        "status": status,
        "approval": approval,
        "branch_name": branchName,
        "branch_latitude": branchLatitude,
        "branch_longitude": branchLongitude,
        "delivery_enabled": deliveryEnabled,
        "delivery_radius_km": deliveryRadiusKm,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "image_url": imageUrl,
        "vendor": vendor?.toJson(),
        "branch": branch?.toJson(),
      };
}

class Vendor {
  int id;
  String firstname;
  String lastname;
  String fullname;
  String email;
  String userImage;

  Vendor({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.email,
    required this.userImage,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: json["id"] ?? 0,
        firstname: json["firstname"] ?? '',
        lastname: json["lastname"] ?? '',
        fullname: json["fullname"] ?? '',
        email: json["email"] ?? '',
        userImage: json["userImage"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "firstname": firstname,
        "lastname": lastname,
        "fullname": fullname,
        "email": email,
        "userImage": userImage,
      };
}

class Branch {
  int id;
  String name;
  String slug;
  String? address;
  String phone;
  String email;
  String latitude;
  String longitude;
  bool deliveryEnabled;
  bool status;

  Branch({
    required this.id,
    required this.name,
    required this.slug,
    this.address,
    required this.phone,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.deliveryEnabled,
    required this.status,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        slug: json["slug"] ?? '',
        address: json["address"],
        phone: json["phone"] ?? '',
        email: json["email"] ?? '',
        latitude: json["latitude"]?.toString() ?? '0',
        longitude: json["longitude"]?.toString() ?? '0',
        deliveryEnabled: json["delivery_enabled"] ?? false,
        status: json["status"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "address": address,
        "phone": phone,
        "email": email,
        "latitude": latitude,
        "longitude": longitude,
        "delivery_enabled": deliveryEnabled,
        "status": status,
      };
}

class Message {
  List<String> success;

  Message({
    required this.success,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: List<String>.from(json["success"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "success": List<dynamic>.from(success.map((x) => x)),
      };
}
