class Task {
  final int? id;
  final int? userId;
  final String title;
  final String? description;
  final DateTime executionDate;
  final bool repeat;
  final bool favorite;
  final String status;
  final String? username;
  final bool? isToday;
  final bool? isOverdue;
  final bool? isUpcoming;
  final String? dateString;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Task({
    this.id,
    this.userId,
    required this.title,
    this.description,
    required this.executionDate,
    this.repeat = false,
    this.favorite = false,
    this.status = 'pending',
    this.username,
    this.isToday = false,
    this.isOverdue = false,
    this.isUpcoming = false,
    this.dateString,
    this.createdAt,
    this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      executionDate: json['execution_date'] != null
          ? DateTime.parse(json['execution_date'])
          : DateTime.now(),
      repeat: json['repeat'] ?? false,
      favorite: json['favorite'] ?? false,
      status: json['status'] ?? 'pending',
      username: json['username'],
      isToday: json['is_today'] ?? false,
      isOverdue: json['is_overdue'] ?? false,
      isUpcoming: json['is_upcoming'] ?? false,
      dateString: json['date_string'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'repeat': repeat,
      'favorite': favorite,
      'description': description,
      'execution_date': executionDate.toIso8601String(),
    };
  }

  Task copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    DateTime? executionDate,
    bool? repeat,
    bool? favorite,
    String? status,
    String? username,
    // bool? isToday,
    // bool? isOverdue,
    // bool? isUpcoming,
    // String? dateString,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      executionDate: executionDate ?? this.executionDate,
      repeat: repeat ?? this.repeat,
      favorite: favorite ?? this.favorite,
      status: status ?? this.status,
      username: username ?? this.username,
      // isToday: isToday ?? this.isToday,
      // isOverdue: isOverdue ?? this.isOverdue,
      // isUpcoming: isUpcoming ?? this.isUpcoming,
      // dateString: dateString ?? this.dateString,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}