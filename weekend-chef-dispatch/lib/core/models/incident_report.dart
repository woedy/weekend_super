class IncidentReport {
  const IncidentReport({
    required this.id,
    required this.assignmentId,
    required this.type,
    required this.description,
    required this.submittedAt,
    this.photoPath,
    this.resolution,
  });

  final String id;
  final String assignmentId;
  final String type;
  final String description;
  final DateTime submittedAt;
  final String? photoPath;
  final String? resolution;
}
