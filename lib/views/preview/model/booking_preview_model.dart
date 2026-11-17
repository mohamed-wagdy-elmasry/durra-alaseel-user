import 'package:get/get.dart';
import '../../../base/widgets/custom_drop_down.dart';
import '../../../languages/locale_service.dart';

String _asString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value;
  return value.toString();
}

String _asLocalizedString(dynamic value, {String fallback = ''}) {
  if (value == null) return fallback;
  if (value is String) return value.isEmpty ? fallback : value;
  if (value is Map) {
    final lang = Get.find<LocaleService>().currentLanguageCode;
    final localized = value[lang] ?? value['en'] ?? value.values.firstWhere(
      (v) => v != null && v.toString().isNotEmpty,
      orElse: () => null,
    );
    if (localized != null) return localized.toString();
    return fallback;
  }
  return fallback;
}

int _asInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) {
    final parsed = int.tryParse(value);
    if (parsed != null) return parsed;
    final parsedDouble = double.tryParse(value);
    if (parsedDouble != null) return parsedDouble.toInt();
  }
  return fallback;
}

double _asDouble(dynamic value, {double fallback = 0.0}) {
  if (value == null) return fallback;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) {
    final parsed = double.tryParse(value);
    if (parsed != null) return parsed;
  }
  return fallback;
}

bool _asBool(dynamic value, {bool fallback = false}) {
  if (value == null) return fallback;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 'yes') return true;
    if (normalized == 'false' || normalized == '0' || normalized == 'no') return false;
  }
  return fallback;
}

class BookingPreviewModel {
  List<String> message;
  Data data;
  String type;

  BookingPreviewModel({
    required this.message,
    required this.data,
    required this.type,
  });

  factory BookingPreviewModel.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing BookingPreviewModel - Full JSON keys: ${json.keys.toList()}');
      print('  - message type: ${json["message"].runtimeType}');
      print('  - message value: ${json["message"]}');
      
      // Handle message field - can be List or single String
      List<String> messages = [];
      if (json["message"] is List) {
        messages = List<String>.from(json["message"]);
      } else if (json["message"] is String) {
        messages = [json["message"]];
      } else if (json["message"] is Map) {
        // If it's a Map, extract values as list
        messages = (json["message"] as Map).values.map((e) => e.toString()).toList();
      }
      
      return BookingPreviewModel(
        message: messages,
        data: Data.fromJson((json["data"] as Map?)?.cast<String, dynamic>() ?? const {}),
        type: _asString(json["type"], fallback: ''),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing BookingPreviewModel: $e');
      print('📋 JSON data: $json');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "message": message,
    "data": data.toJson(),
    "type": type,
  };
}

class Data {
  String? token;
  BookingDetails bookingDetails;
  String bookingCurrency;
  Car? car;
  User user;
  UserBalance? userBalance;
  DeliveryInfo? deliveryInfo;
  InsuranceBreakdown? insuranceBreakdown;
  PricingBreakdown? pricingBreakdown;
  PaymentType paymentType;
  List<PaymentGateway> paymentGateways;

  Data({
    this.token,
    required this.bookingDetails,
    required this.bookingCurrency,
    this.car,
    required this.user,
    this.userBalance,
    this.deliveryInfo,
    this.insuranceBreakdown,
    this.pricingBreakdown,
    required this.paymentType,
    required this.paymentGateways,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing Data - Keys available: ${json.keys.toList()}');
      print('  - token: ${json["token"]}');
      print('  - booking_details: ${json["booking_details"] != null ? "EXISTS" : "NULL"}');
      print('  - booking_currency: ${json["booking_currency"]}');
      print('  - car: ${json["car"] != null ? "EXISTS" : "NULL"}');
      print('  - user: ${json["user"] != null ? "EXISTS" : "NULL"}');
      print('  - user_balance: ${json["user_balance"] != null ? "EXISTS" : "NULL"}');
      print('  - delivery_info: ${json["delivery_info"] != null ? "EXISTS" : "NULL"}');
      print('  - pricing_breakdown: ${json["pricing_breakdown"] != null ? "EXISTS" : "NULL"}');
      print('  - payment-type: ${json["payment-type"] != null ? "EXISTS" : "NULL"}');
      print('  - payment_gateways: ${json["payment_gateways"] != null ? "EXISTS" : "NULL"}');
      
      return Data(
        token: _asString(json["token"], fallback: ''),
        bookingDetails: BookingDetails.fromJson(
          (json["booking_details"] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
        bookingCurrency: _asString(json["booking_currency"], fallback: 'SAR'),
        car: json["car"] is Map ? Car.fromJson((json["car"] as Map).cast<String, dynamic>()) : null,
        user: User.fromJson((json["user"] as Map?)?.cast<String, dynamic>() ?? const {}),
        userBalance: json["user_balance"] is Map
            ? UserBalance.fromJson((json["user_balance"] as Map).cast<String, dynamic>())
            : null,
        deliveryInfo: json["delivery_info"] is Map
            ? DeliveryInfo.fromJson((json["delivery_info"] as Map).cast<String, dynamic>())
            : null,
        insuranceBreakdown: json["insurance_breakdown"] is Map
            ? InsuranceBreakdown.fromJson((json["insurance_breakdown"] as Map).cast<String, dynamic>())
            : null,
        pricingBreakdown: json["pricing_breakdown"] is Map
            ? PricingBreakdown.fromJson((json["pricing_breakdown"] as Map).cast<String, dynamic>())
            : null,
        paymentType: PaymentType.fromJson(
          (json["payment-type"] as Map?)?.cast<String, dynamic>() ??
              (json["payment_type"] as Map?)?.cast<String, dynamic>() ??
              const {},
        ),
        paymentGateways: (json["payment_gateways"] is List)
            ? List<PaymentGateway>.from(
                (json["payment_gateways"] as List)
                    .whereType<Map>()
                    .map((x) => PaymentGateway.fromJson(x.cast<String, dynamic>())),
              )
            : <PaymentGateway>[],
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing Data: $e');
      print('📋 Available keys: ${json.keys.toList()}');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "token": token,
    "booking_details": bookingDetails.toJson(),
    "booking_currency": bookingCurrency,
    "car": car?.toJson(),
    "user": user.toJson(),
    "user_balance": userBalance?.toJson(),
    "delivery_info": deliveryInfo?.toJson(),
    "insurance_breakdown": insuranceBreakdown?.toJson(),
    "pricing_breakdown": pricingBreakdown?.toJson(),
    "payment-type": paymentType.toJson(),
    "payment_gateways": List<dynamic>.from(paymentGateways.map((x) => x.toJson())),
  };
}

class BookingDetails {
  int carType;
  String pickupDate;
  String pickupTime;
  int rentalDays;
  PickupLocationData? pickupLocation;
  String? roundPickupDate;
  String? roundPickupTime;

  BookingDetails({
    required this.carType,
    required this.pickupDate,
    required this.pickupTime,
    required this.rentalDays,
    this.pickupLocation,
    this.roundPickupDate,
    this.roundPickupTime,
  });

  factory BookingDetails.fromJson(Map<String, dynamic> json) {
    try {
      print('🔍 Parsing BookingDetails');
      print('  - car_type: ${json["car_type"]} (type: ${json["car_type"].runtimeType})');
      print('  - pickup_time: ${json["pickup_time"]}');
      print('  - pickup_date: ${json["pickup_date"]}');
      print('  - rental_days: ${json["rental_days"]} (type: ${json["rental_days"].runtimeType})');
      print('  - pickup_location: ${json["pickup_location"] != null ? "EXISTS" : "NULL"}');
      print('  - round_pickup_date: ${json["round_pickup_date"]}');
      print('  - round_pickup_time: ${json["round_pickup_time"]}');
      
      return BookingDetails(
        carType: _asInt(json["car_type"], fallback: 0),
        pickupDate: _asString(json["pickup_date"], fallback: ''),
        pickupTime: _asString(json["pickup_time"], fallback: ''),
        rentalDays: _asInt(json["rental_days"], fallback: 1),
        pickupLocation: json["pickup_location"] is Map
            ? PickupLocationData.fromJson((json["pickup_location"] as Map).cast<String, dynamic>())
            : null,
        roundPickupDate: json["round_pickup_date"] == null ? null : _asString(json["round_pickup_date"]),
        roundPickupTime: json["round_pickup_time"] == null ? null : _asString(json["round_pickup_time"]),
      );
    } catch (e, stackTrace) {
      print('❌ Error parsing BookingDetails: $e');
      print('📋 JSON: $json');
      print('📍 Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "car_type": carType,
    "pickup_date": pickupDate,
    "pickup_time": pickupTime,
    "rental_days": rentalDays,
    "pickup_location": pickupLocation?.toJson(),
    "round_pickup_date": roundPickupDate,
    "round_pickup_time": roundPickupTime,
  };
}

class PickupLocationData {
  double latitude;
  double longitude;
  String address;

  PickupLocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  factory PickupLocationData.fromJson(Map<String, dynamic> json) => PickupLocationData(
    latitude: _asDouble(json["latitude"], fallback: 0.0),
    longitude: _asDouble(json["longitude"], fallback: 0.0),
    address: _asString(json["address"], fallback: ''),
  );

  Map<String, dynamic> toJson() => {
    "latitude": latitude,
    "longitude": longitude,
    "address": address,
  };
}

class Car {
  int id;
  int vendorId;
  int branchId;
  String? carTitle;
  String carModel;
  String carNumber;
  int seat;
  int year;
  String fees;
  String price;
  String pricePerDay;
  String pricePerWeek;
  String pricePerMonth;
  String? allowanceKm;
  String? allowancePricePerKm;
  String? image;
  String? imageUrl;
  int status;
  bool approval;
  String? slug;
  CarTypeInfo? carType;
  CarModelInfo? carModelInfo;
  AreaInfo? area;
  BranchInfo? branch;
  VendorInfo? vendor;
  DateTime? createdAt;

  Car({
    required this.id,
    required this.vendorId,
    required this.branchId,
    this.carTitle,
    required this.carModel,
    required this.seat,
    required this.carNumber,
    required this.year,
    required this.fees,
    required this.price,
    required this.pricePerDay,
    required this.pricePerWeek,
    required this.pricePerMonth,
    this.allowanceKm,
    this.allowancePricePerKm,
    this.image,
    this.imageUrl,
    required this.status,
    required this.approval,
    this.slug,
    this.carType,
    this.carModelInfo,
    this.area,
    this.branch,
    this.vendor,
    this.createdAt,
  });

  factory Car.fromJson(Map<String, dynamic> json) => Car(
    id: _asInt(json["id"]),
    vendorId: _asInt(json["vendor_id"]),
    branchId: _asInt(json["branch_id"]),
    carTitle: json["car_title"] == null ? null : _asLocalizedString(json["car_title"]),
    carModel: _asString(json["car_model"], fallback: ''),
    carNumber: _asString(json["car_number"], fallback: ''),
    seat: _asInt(json["seat"]),
    year: _asInt(json["year"]),
    fees: _asString(json["fees"], fallback: "0.00"),
    price: _asString(json["price"], fallback: "0.00"),
    pricePerDay: _asString(json["price_per_day"], fallback: "0.00"),
    pricePerWeek: _asString(json["price_per_week"], fallback: "0.00"),
    pricePerMonth: _asString(json["price_per_month"], fallback: "0.00"),
    allowanceKm: json["allowance_km"] == null ? null : _asString(json["allowance_km"]),
    allowancePricePerKm: json["allowance_price_per_km"] == null ? null : _asString(json["allowance_price_per_km"]),
    image: json["image"] == null ? null : _asString(json["image"]),
    imageUrl: json["image_url"] == null ? null : _asString(json["image_url"]),
    status: _asInt(json["status"], fallback: 0),
    approval: _asBool(json["approval"], fallback: false),
    slug: json["slug"] == null ? null : _asString(json["slug"]),
    carType: json["car_type"] is Map ? CarTypeInfo.fromJson((json["car_type"] as Map).cast<String, dynamic>()) : null,
    carModelInfo: json["car_model_info"] is Map ? CarModelInfo.fromJson((json["car_model_info"] as Map).cast<String, dynamic>()) : null,
    area: json["area"] is Map ? AreaInfo.fromJson((json["area"] as Map).cast<String, dynamic>()) : null,
    branch: json["branch"] is Map ? BranchInfo.fromJson((json["branch"] as Map).cast<String, dynamic>()) : null,
    vendor: json["vendor"] is Map ? VendorInfo.fromJson((json["vendor"] as Map).cast<String, dynamic>()) : null,
    createdAt: json["created_at"] == null ? null : DateTime.tryParse(_asString(json["created_at"])),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "vendor_id": vendorId,
    "branch_id": branchId,
    "car_title": carTitle,
    "car_model": carModel,
    "seat": seat,
    "car_number": carNumber,
    "year": year,
    "fees": fees,
    "price": price,
    "price_per_day": pricePerDay,
    "price_per_week": pricePerWeek,
    "price_per_month": pricePerMonth,
    "allowance_km": allowanceKm,
    "allowance_price_per_km": allowancePricePerKm,
    "image": image,
    "image_url": imageUrl,
    "status": status,
    "approval": approval,
    "slug": slug,
    "car_type": carType?.toJson(),
    "car_model_info": carModelInfo?.toJson(),
    "area": area?.toJson(),
    "branch": branch?.toJson(),
    "vendor": vendor?.toJson(),
    "created_at": createdAt?.toIso8601String(),
  };
}

class CarTypeInfo {
  int id;
  String name;
  String slug;

  CarTypeInfo({
    required this.id,
    required this.name,
    required this.slug,
  });

  factory CarTypeInfo.fromJson(Map<String, dynamic> json) => CarTypeInfo(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        slug: _asString(json['slug']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
      };
}

class CarModelInfo {
  int id;
  String name;
  String? imageUrl;

  CarModelInfo({
    required this.id,
    required this.name,
    this.imageUrl,
  });

  factory CarModelInfo.fromJson(Map<String, dynamic> json) => CarModelInfo(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        imageUrl: json['image_url'] == null ? null : _asString(json['image_url']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'image_url': imageUrl,
      };
}

class AreaInfo {
  int id;
  String name;

  AreaInfo({
    required this.id,
    required this.name,
  });

  factory AreaInfo.fromJson(Map<String, dynamic> json) => AreaInfo(
        id: _asInt(json['id']),
        name: _asString(json['name']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class BranchInfo {
  int id;
  String name;
  String slug;
  String? address;
  int status;

  BranchInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.address,
    required this.status,
  });

  factory BranchInfo.fromJson(Map<String, dynamic> json) => BranchInfo(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        slug: _asString(json['slug']),
        address: json['address'] == null ? null : _asString(json['address']),
        status: _asInt(json['status']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'slug': slug,
        'address': address,
        'status': status,
      };
}

class VendorInfo {
  int id;
  String name;
  String username;

  VendorInfo({
    required this.id,
    required this.name,
    required this.username,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) => VendorInfo(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        username: _asString(json['username']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'username': username,
      };
}

class PaymentGateway implements DropdownModel{
  int id;
  String type;
  String name;
  int crypto;
  dynamic desc;
  int status;
  List<Currency> currencies;

  PaymentGateway({
    required this.id,
    required this.type,
    required this.name,
    required this.crypto,
    required this.desc,
    required this.status,
    required this.currencies,

  });

  factory PaymentGateway.fromJson(Map<String, dynamic> json) => PaymentGateway(
    id: _asInt(json["id"]),
    type: _asString(json["type"], fallback: _asString(json["name"], fallback: '')),
    name: _asString(json["name"], fallback: ''),
    crypto: _asInt(json["crypto"], fallback: 0),
    desc: json["desc"],
    status: _asInt(json["status"], fallback: 0),
    currencies: (json["currencies"] is List)
        ? List<Currency>.from(
            (json["currencies"] as List)
                .whereType<Map>()
                .map((x) => Currency.fromJson(x.cast<String, dynamic>())),
          )
        : <Currency>[],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "name": name,
    "crypto": crypto,
    "desc": desc,
    "status": status,
    "currencies": List<dynamic>.from(currencies.map((x) => x.toJson())),
  };

  @override
  String get title => name;
}

class Currency implements DropdownModel{
  dynamic id;
  dynamic paymentGatewayId;
  String name;
  String alias;
  String currencyCode;
  String currencySymbol;
  dynamic image;
  dynamic minLimit;
  dynamic maxLimit;
  dynamic percentCharge;
  dynamic fixedCharge;
  dynamic rate;
  DateTime createdAt;
  DateTime updatedAt;

  Currency({
    required this.id,
    required this.paymentGatewayId,
    required this.name,
    required this.alias,
    required this.currencyCode,
    required this.currencySymbol,
    required this.image,
    required this.minLimit,
    required this.maxLimit,
    required this.percentCharge,
    required this.fixedCharge,
    required this.rate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    paymentGatewayId: json["payment_gateway_id"],
    name: _asString(json["name"], fallback: ''),
    alias: _asString(json["alias"], fallback: _asString(json["code"], fallback: '')),
    currencyCode: _asString(json["currency_code"], fallback: _asString(json["code"], fallback: '')),
    currencySymbol: _asString(json["currency_symbol"], fallback: ''),
    image: json["image"],
    minLimit: json["min_limit"],
    maxLimit: json["max_limit"],
    percentCharge: json["percent_charge"] ?? 0,
    fixedCharge: json["fixed_charge"] ?? 0,
    rate: json["rate"] ?? 1,
    createdAt: json["created_at"] == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : (DateTime.tryParse(_asString(json["created_at"])) ?? DateTime.fromMillisecondsSinceEpoch(0)),
    updatedAt: json["updated_at"] == null
        ? DateTime.fromMillisecondsSinceEpoch(0)
        : (DateTime.tryParse(_asString(json["updated_at"])) ?? DateTime.fromMillisecondsSinceEpoch(0)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_gateway_id": paymentGatewayId,
    "name": name,
    "alias": alias,
    "currency_code": currencyCode,
    "currency_symbol": currencySymbol,
    "image": image,
    "min_limit": minLimit,
    "max_limit": maxLimit,
    "percent_charge": percentCharge,
    "fixed_charge": fixedCharge,
    "rate": rate,
    "created_at": createdAt.toIso8601String(),
    "updated_at": updatedAt.toIso8601String(),
  };

  @override
  String get title => name;
}

class PaymentType {
  String onlinePayment;
  String cash;
  String balance;

  PaymentType({
    required this.onlinePayment,
    required this.cash,
    required this.balance,
  });

  factory PaymentType.fromJson(Map<String, dynamic> json) => PaymentType(
        onlinePayment: _asString(json["online-payment"], fallback: "online-payment"),
        cash: _asString(json["cash"], fallback: "cash"),
        balance: _asString(json["balance"], fallback: "balance"),
      );

  Map<String, dynamic> toJson() => {
        "online-payment": onlinePayment,
        "cash": cash,
        "balance": balance,
      };
}

class User {
  int id;
  String firstname;
  String lastname;
  String fullname;
  String email;
  String mobile;
  bool emailVerified;
  bool kycVerified;
  bool twoFactorVerified;

  User({
    required this.id,
    required this.firstname,
    required this.lastname,
    required this.fullname,
    required this.email,
    required this.mobile,
    required this.emailVerified,
    required this.kycVerified,
    required this.twoFactorVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: _asInt(json['id']),
        firstname: _asString(json['firstname']),
        lastname: _asString(json['lastname']),
        fullname: _asString(json['fullname']),
        email: _asString(json['email']),
        mobile: _asString(json['mobile']),
        emailVerified: _asBool(json['email_verified']),
        kycVerified: _asBool(json['kyc_verified']),
        twoFactorVerified: _asBool(json['two_factor_verified']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstname': firstname,
        'lastname': lastname,
        'fullname': fullname,
        'email': email,
        'mobile': mobile,
        'email_verified': emailVerified,
        'kyc_verified': kycVerified,
        'two_factor_verified': twoFactorVerified,
      };
}

class UserBalance {
  String balance;
  bool hasSufficientBalance;

  UserBalance({
    required this.balance,
    required this.hasSufficientBalance,
  });

  factory UserBalance.fromJson(Map<String, dynamic> json) => UserBalance(
    balance: _asString(json["balance"], fallback: "0.00"),
    hasSufficientBalance: _asBool(json["has_sufficient_balance"], fallback: false),
  );

  Map<String, dynamic> toJson() => {
    "balance": balance,
    "has_sufficient_balance": hasSufficientBalance,
  };
}

class DeliveryInfo {
  bool available;
  String price;

  DeliveryInfo({
    required this.available,
    required this.price,
  });

  factory DeliveryInfo.fromJson(Map<String, dynamic> json) => DeliveryInfo(
    available: _asBool(json["available"], fallback: false),
    price: _asString(json["price"], fallback: "0.00"),
  );

  Map<String, dynamic> toJson() => {
    "available": available,
    "price": price,
  };
}

class InsuranceBreakdown {
  String insuranceType;
  double dailyInsurance;
  double insuranceTotal;
  double deductibleInsurance;

  InsuranceBreakdown({
    required this.insuranceType,
    required this.dailyInsurance,
    required this.insuranceTotal,
    required this.deductibleInsurance,
  });

  factory InsuranceBreakdown.fromJson(Map<String, dynamic> json) => InsuranceBreakdown(
    insuranceType: _asString(json["insurance_type"], fallback: "daily"),
    dailyInsurance: _asDouble(json["daily_insurance"], fallback: 0.0),
    insuranceTotal: _asDouble(json["insurance_total"], fallback: 0.0),
    deductibleInsurance: _asDouble(json["deductible_insurance"], fallback: 0.0),
  );

  Map<String, dynamic> toJson() => {
    "insurance_type": insuranceType,
    "daily_insurance": dailyInsurance,
    "insurance_total": insuranceTotal,
    "deductible_insurance": deductibleInsurance,
  };
}

class PricingBreakdown {
  int rentalDays;
  String rentalFees;
  String deliveryPrice;
  String charges;
  String insuranceTotal;
  String subtotal;
  double taxPercentage;
  String taxAmount;
  String total;
  String priceRuleApplied;
  double taxRate;

  PricingBreakdown({
    required this.rentalDays,
    required this.rentalFees,
    required this.deliveryPrice,
    required this.charges,
    required this.insuranceTotal,
    required this.subtotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.total,
    required this.priceRuleApplied,
    required this.taxRate,
  });

  factory PricingBreakdown.fromJson(Map<String, dynamic> json) => PricingBreakdown(
    rentalDays: _asInt(json["rental_days"], fallback: 1),
    rentalFees: _asString(json["rental_fees"], fallback: "0.00"),
    deliveryPrice: _asString(json["delivery_price"], fallback: "0.00"),
    charges: _asString(json["charges"], fallback: "0.00"),
    insuranceTotal: _asString(json["insurance_total"], fallback: "0.00"),
    subtotal: _asString(json["subtotal"], fallback: "0.00"),
    taxPercentage: _asDouble(json["tax_percentage"], fallback: 0.0),
    taxAmount: _asString(json["tax_amount"], fallback: "0.00"),
    total: _asString(json["total"], fallback: "0.00"),
    priceRuleApplied: _asString(json["price_rule_applied"], fallback: "daily"),
    taxRate: _asDouble(json["tax_rate"], fallback: 0.0),
  );

  Map<String, dynamic> toJson() => {
    "rental_days": rentalDays,
    "rental_fees": rentalFees,
    "delivery_price": deliveryPrice,
    "charges": charges,
    "insurance_total": insuranceTotal,
    "subtotal": subtotal,
    "tax_percentage": taxPercentage,
    "tax_amount": taxAmount,
    "total": total,
    "price_rule_applied": priceRuleApplied,
    "tax_rate": taxRate,
  };
}
