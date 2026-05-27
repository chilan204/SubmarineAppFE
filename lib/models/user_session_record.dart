class UserSessionRecord {
  final int id;
  final int? userId;
  final String? transcript;
  final String? action;
  final String? direction;
  final num? value;
  final String? speaker;
  final double? speakerScore;
  final double? verificationScore;
  final bool? verified;
  final String? role;
  final String? commandStatus;
  final bool? executed;
  final DateTime? createdDate;

  const UserSessionRecord({
    required this.id,
    this.userId,
    this.transcript,
    this.action,
    this.direction,
    this.value,
    this.speaker,
    this.speakerScore,
    this.verificationScore,
    this.verified,
    this.role,
    this.commandStatus,
    this.executed,
    this.createdDate,
  });

  factory UserSessionRecord.fromJson(Map<String, dynamic> json) {
    return UserSessionRecord(
      id: json['id'] as int,
      userId: json['userId'] as int?,
      transcript: json['transcript'] as String?,
      action: json['action'] as String?,
      direction: json['direction'] as String?,
      value: json['value'] as num?,
      speaker: json['speaker'] as String?,
      speakerScore: (json['speakerScore'] as num?)?.toDouble(),
      verificationScore: (json['verificationScore'] as num?)?.toDouble(),
      verified: json['verified'] as bool?,
      role: json['role'] as String?,
      commandStatus: json['commandStatus'] as String?,
      executed: json['executed'] as bool?,
      createdDate: json['createdDate'] != null 
          ? DateTime.tryParse(json['createdDate'] as String) 
          : null,
    );
  }
}
