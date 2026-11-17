class ExtendConfirmModel {
  final String message;

  const ExtendConfirmModel({required this.message});

  factory ExtendConfirmModel.fromJson(Map<String, dynamic> json) {
    final msg = json['message'];
    String messageText = '';

    if (msg is Map) {
      final success = msg['success'];
      messageText = (success is List && success.isNotEmpty)
          ? success.first.toString()
          : '';
    } else if (msg is List && msg.isNotEmpty) {
      messageText = msg.first.toString();
    } else if (msg is String) {
      messageText = msg;
    }

    return ExtendConfirmModel(message: messageText);
  }
}
