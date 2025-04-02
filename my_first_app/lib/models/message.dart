class Message {
  final String id;
  final String content;
  final String senderId;
  final String senderName;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.content,
    required this.senderId,
    required this.senderName,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}