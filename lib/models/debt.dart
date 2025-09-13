class Debt {
  final String? id;
  final String debtorName;
  final String? debtorEmail;
  final String? debtorPhone;
  final String? debtorNotes;
  final String? facebookProfile;
  final double amount;
  final String currency;
  final DateTime createdAt;
  final DateTime? dueDate;
  final DebtStatus status;
  final String userId;

  Debt({
    this.id,
    required this.debtorName,
    this.debtorEmail,
    this.debtorPhone,
    this.debtorNotes,
    this.facebookProfile,
    required this.amount,
    this.currency = 'USD',
    required this.createdAt,
    this.dueDate,
    this.status = DebtStatus.active,
    required this.userId,
  });

  factory Debt.fromJson(Map<String, dynamic> json) {
    return Debt(
      id: json['id'],
      debtorName: json['debtor_name'],
      debtorEmail: json['debtor_email'],
      debtorPhone: json['debtor_phone'],
      debtorNotes: json['debtor_notes'],
      facebookProfile: json['facebook_profile'],
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      createdAt: DateTime.parse(json['created_at']),
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
      status: DebtStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DebtStatus.active,
      ),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'debtor_name': debtorName,
      'debtor_email': debtorEmail,
      'debtor_phone': debtorPhone,
      'debtor_notes': debtorNotes,
      'facebook_profile': facebookProfile,
      'amount': amount,
      'currency': currency,
      'created_at': createdAt.toIso8601String(),
      'due_date': dueDate?.toIso8601String(),
      'status': status.name,
      'user_id': userId,
    };
  }

  Debt copyWith({
    String? id,
    String? debtorName,
    String? debtorEmail,
    String? debtorPhone,
    String? debtorNotes,
    String? facebookProfile,
    double? amount,
    String? currency,
    DateTime? createdAt,
    DateTime? dueDate,
    DebtStatus? status,
    String? userId,
  }) {
    return Debt(
      id: id ?? this.id,
      debtorName: debtorName ?? this.debtorName,
      debtorEmail: debtorEmail ?? this.debtorEmail,
      debtorPhone: debtorPhone ?? this.debtorPhone,
      debtorNotes: debtorNotes ?? this.debtorNotes,
      facebookProfile: facebookProfile ?? this.facebookProfile,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      userId: userId ?? this.userId,
    );
  }
}

enum DebtStatus {
  active,
  settled,
  overdue,
}

extension DebtStatusExtension on DebtStatus {
  String get displayName {
    switch (this) {
      case DebtStatus.active:
        return 'Active';
      case DebtStatus.settled:
        return 'Settled';
      case DebtStatus.overdue:
        return 'Overdue';
    }
  }
}
