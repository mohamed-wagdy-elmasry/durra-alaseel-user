class BranchModel {
  final Message message;
  final Data data;
  final int statusCode;

  BranchModel({
    required this.message,
    required this.data,
    required this.statusCode,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) => BranchModel(
        message: Message.fromJson(json["message"]),
        data: Data.fromJson(json["data"]),
        statusCode: json["status_code"],
      );
}

class Data {
  final List<Branch> branches;

  Data({
    required this.branches,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        branches: List<Branch>.from(
            json["branches"].map((x) => Branch.fromJson(x))),
      );
}

class Branch {
  final int id;
  final String name;
  final String slug;
  final String address;
  final int status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? lastEditBy;

  Branch({
    required this.id,
    required this.name,
    required this.slug,
    required this.address,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.lastEditBy,
  });

  factory Branch.fromJson(Map<String, dynamic> json) => Branch(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        address: json["address"],
        status: json["status"] ?? 1,
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        lastEditBy: json["last_edit_by"],
      );

  @override
  String toString() => name;
}

class Message {
  final List<String> success;

  Message({
    required this.success,
  });

  factory Message.fromJson(Map<String, dynamic> json) => Message(
        success: List<String>.from(json["success"].map((x) => x)),
      );
}
