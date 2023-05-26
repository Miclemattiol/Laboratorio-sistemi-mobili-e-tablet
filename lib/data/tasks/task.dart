class Task {
  final String title;
  final DateTime from;
  final DateTime to;
  final bool repeating;
  final String? description;
  final List<String> assignedTo;

  const Task({
    required this.title,
    required this.from,
    required this.to,
    required this.repeating,
    required this.description,
    required this.assignedTo,
  });
}
