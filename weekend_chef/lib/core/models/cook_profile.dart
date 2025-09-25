import 'package:flutter/material.dart';

import '../../constants.dart';

enum ApprovalStatus { draft, pending, approved, rejected }

class DocumentUpload {
  const DocumentUpload({
    required this.label,
    required this.fileName,
    required this.uploadedAt,
  });

  final String label;
  final String fileName;
  final DateTime uploadedAt;

  DocumentUpload copyWith({
    String? label,
    String? fileName,
    DateTime? uploadedAt,
  }) {
    return DocumentUpload(
      label: label ?? this.label,
      fileName: fileName ?? this.fileName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}

class AvailabilityWindow {
  const AvailabilityWindow({
    required this.day,
    required this.start,
    required this.end,
  }) : assert(
          start.hour * 60 + start.minute < end.hour * 60 + end.minute,
          'Availability window start must be before end time',
        );

  final String day;
  final TimeOfDay start;
  final TimeOfDay end;

  AvailabilityWindow copyWith({
    String? day,
    TimeOfDay? start,
    TimeOfDay? end,
  }) {
    return AvailabilityWindow(
      day: day ?? this.day,
      start: start ?? this.start,
      end: end ?? this.end,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AvailabilityWindow &&
        other.day == day &&
        other.start == start &&
        other.end == end;
  }

  @override
  int get hashCode => Object.hash(day, start.hashCode, end.hashCode);

  String get displayLabel => '$day ${_format(start)}–${_format(end)}';

  static String _format(TimeOfDay value) {
    final hour = value.hourOfPeriod == 0 ? 12 : value.hourOfPeriod;
    final minute = value.minute.toString().padLeft(2, '0');
    final suffix = value.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }
}

class CookProfile {
  const CookProfile({
    required this.legalName,
    required this.kitchenName,
    required this.bio,
    required this.specialties,
    required this.serviceAreas,
    required this.approvalStatus,
    required this.availability,
    this.idDocument,
    this.certificationDocument,
    this.approvalMessage,
    this.submittedAt,
  });

  final String legalName;
  final String kitchenName;
  final String bio;
  final List<String> specialties;
  final List<String> serviceAreas;
  final ApprovalStatus approvalStatus;
  final List<AvailabilityWindow> availability;
  final DocumentUpload? idDocument;
  final DocumentUpload? certificationDocument;
  final String? approvalMessage;
  final DateTime? submittedAt;

  bool get hasSubmittedDocuments => idDocument != null && certificationDocument != null;

  bool get readyForReview =>
      legalName.isNotEmpty &&
      kitchenName.isNotEmpty &&
      specialties.isNotEmpty &&
      serviceAreas.isNotEmpty &&
      availability.isNotEmpty &&
      hasSubmittedDocuments;

  CookProfile copyWith({
    String? legalName,
    String? kitchenName,
    String? bio,
    List<String>? specialties,
    List<String>? serviceAreas,
    ApprovalStatus? approvalStatus,
    List<AvailabilityWindow>? availability,
    DocumentUpload? idDocument,
    DocumentUpload? certificationDocument,
    String? approvalMessage,
    DateTime? submittedAt,
  }) {
    return CookProfile(
      legalName: legalName ?? this.legalName,
      kitchenName: kitchenName ?? this.kitchenName,
      bio: bio ?? this.bio,
      specialties: specialties ?? List<String>.from(this.specialties),
      serviceAreas: serviceAreas ?? List<String>.from(this.serviceAreas),
      approvalStatus: approvalStatus ?? this.approvalStatus,
      availability: availability ?? List<AvailabilityWindow>.from(this.availability),
      idDocument: idDocument ?? this.idDocument,
      certificationDocument: certificationDocument ?? this.certificationDocument,
      approvalMessage: approvalMessage ?? this.approvalMessage,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }

  String approvalCopy() {
    switch (approvalStatus) {
      case ApprovalStatus.approved:
        return 'Verified — you can accept new orders without restrictions.';
      case ApprovalStatus.pending:
        return approvalMessage ??
            'Your documents are under review. Expect feedback from the team within 24 hours.';
      case ApprovalStatus.rejected:
        return approvalMessage ??
            'Updates required. Please review feedback, update your documents, and resubmit.';
      case ApprovalStatus.draft:
        return 'Complete verification to start receiving orders. Upload your ID, certifications, and availability.';
    }
  }
}

CookProfile initialProfile() {
  return CookProfile(
    legalName: 'Adaora Eze',
    kitchenName: 'Adaora Kitchen Collective',
    bio:
        'Campus-based personal chef specializing in Nigerian comfort dishes with athlete-friendly meal prep.',
    specialties: const ['Nigerian classics', 'Meal prep', 'Athlete fuel'],
    serviceAreas: const ['Campus North', 'Campus South', 'Tech Park'],
    approvalStatus: ApprovalStatus.draft,
    availability: const [
      AvailabilityWindow(
        day: 'Monday',
        start: TimeOfDay(hour: 10, minute: 0),
        end: TimeOfDay(hour: 14, minute: 0),
      ),
      AvailabilityWindow(
        day: 'Wednesday',
        start: TimeOfDay(hour: 16, minute: 0),
        end: TimeOfDay(hour: 20, minute: 0),
      ),
      AvailabilityWindow(
        day: 'Friday',
        start: TimeOfDay(hour: 12, minute: 0),
        end: TimeOfDay(hour: 18, minute: 0),
      ),
    ],
    idDocument: null,
    certificationDocument: null,
    approvalMessage: null,
    submittedAt: null,
  );
}

List<String> combinedServiceAreas() => defaultServiceAreas;
