class ClassMasterUser {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? studentId;
  final String? institution;
  final DateTime? lastSyncTime;

  const ClassMasterUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.studentId,
    this.institution,
    this.lastSyncTime,
  });

  ClassMasterUser copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? studentId,
    String? institution,
    DateTime? lastSyncTime,
  }) {
    return ClassMasterUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      studentId: studentId ?? this.studentId,
      institution: institution ?? this.institution,
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'studentId': studentId,
      'institution': institution,
      'lastSyncTime': lastSyncTime?.toIso8601String(),
    };
  }

  factory ClassMasterUser.fromJson(Map<String, dynamic> json) {
    return ClassMasterUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      studentId: json['studentId'] as String?,
      institution: json['institution'] as String?,
      lastSyncTime: json['lastSyncTime'] != null
          ? DateTime.parse(json['lastSyncTime'] as String)
          : null,
    );
  }
}
