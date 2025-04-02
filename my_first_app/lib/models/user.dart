class ChatUser {
  final String id;
  final String username;
  final String? email;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatUser({
    required this.id,
    required this.username,
    this.email,
    this.avatarUrl,
    this.isOnline = false,
    this.lastSeen,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      avatarUrl: json['avatar_url'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null ? DateTime.parse(json['last_seen']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar_url': avatarUrl,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}