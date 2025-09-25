import 'dart:collection';

import 'package:flutter/foundation.dart';

import '../models/contact.dart';
import '../models/delivery_assignment.dart';
import '../models/dispatcher_profile.dart';
import '../models/incident_report.dart';
import '../models/proof_of_delivery.dart';

class AppState extends ChangeNotifier {
  AppState({
    required List<DeliveryAssignment> assignments,
    required List<ChatThread> chatThreads,
    required DispatcherProfile dispatcherProfile,
    List<IncidentReport>? incidents,
  })  : _assignments = assignments,
        _chatThreads = {for (final thread in chatThreads) thread.id: thread},
        _dispatcherProfile = dispatcherProfile,
        _incidents = incidents ?? [];

  final List<DeliveryAssignment> _assignments;
  final Map<String, ChatThread> _chatThreads;
  final DispatcherProfile _dispatcherProfile;
  final List<IncidentReport> _incidents;

  UnmodifiableListView<DeliveryAssignment> get assignments =>
      UnmodifiableListView(_assignments);
  List<ChatThread> get chatThreads => _chatThreads.values.toList(growable: false);
  DispatcherProfile get dispatcherProfile => _dispatcherProfile;
  UnmodifiableListView<IncidentReport> get incidents =>
      UnmodifiableListView(_incidents);

  ChatThread? chatThreadById(String id) => _chatThreads[id];

  DeliveryAssignment assignmentById(String id) {
    return _assignments.firstWhere((assignment) => assignment.id == id);
  }

  void updateAssignment(DeliveryAssignment updated) {
    final index = _assignments.indexWhere((assignment) => assignment.id == updated.id);
    if (index == -1) return;
    _assignments[index] = updated;
    notifyListeners();
  }

  void advanceAssignmentStatus(String id) {
    final assignment = assignmentById(id);
    final nextStatus = assignment.status.advance();
    updateAssignment(
      assignment.copyWith(
        status: nextStatus,
        events: [
          ...assignment.events,
          AssignmentEvent(
            timestamp: DateTime.now(),
            message: 'Status updated to ${nextStatus.label}',
          ),
        ],
      ),
    );
  }

  void attachProofOfDelivery(String id, ProofOfDelivery proof) {
    final assignment = assignmentById(id);
    updateAssignment(
      assignment
          .addEvent(
            AssignmentEvent(
              timestamp: proof.capturedAt,
              message: 'Proof of delivery submitted',
            ),
          )
          .copyWith(
            proofOfDelivery: proof,
            status: DeliveryStatus.completed,
          ),
    );
  }

  void addIncident(IncidentReport incident) {
    _incidents.add(incident);
    notifyListeners();
  }

  void appendMessage(String threadId, ChatMessage message) {
    final thread = _chatThreads[threadId];
    if (thread == null) return;
    _chatThreads[threadId] = thread.copyWith(
      messages: [...thread.messages, message],
    );
    notifyListeners();
  }
}
