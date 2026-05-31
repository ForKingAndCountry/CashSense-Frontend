enum ReportType {
  summary,
  transactions;

  String get label => switch (this) {
        ReportType.summary => 'Monthly summary',
        ReportType.transactions => 'Transaction detail',
      };
}

class ReportEntity {
  const ReportEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.periodStart,
    required this.periodEnd,
    required this.createdAt,
    required this.fileName,
  });

  final String id;
  final String title;
  final ReportType type;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime createdAt;
  final String fileName;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'type': type.name,
        'period_start': periodStart.millisecondsSinceEpoch,
        'period_end': periodEnd.millisecondsSinceEpoch,
        'created_at': createdAt.millisecondsSinceEpoch,
        'file_name': fileName,
      };

  factory ReportEntity.fromMap(Map map) {
    return ReportEntity(
      id: map['id'] as String,
      title: map['title'] as String,
      type: ReportType.values.byName(map['type'] as String),
      periodStart: DateTime.fromMillisecondsSinceEpoch(map['period_start'] as int),
      periodEnd: DateTime.fromMillisecondsSinceEpoch(map['period_end'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      fileName: map['file_name'] as String,
    );
  }
}
