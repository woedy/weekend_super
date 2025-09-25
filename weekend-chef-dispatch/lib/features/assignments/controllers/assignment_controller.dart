import '../../../core/models/delivery_assignment.dart';
import '../../../core/models/incident_report.dart';
import '../../../core/models/proof_of_delivery.dart';
import '../../../core/services/app_state.dart';
import '../../../core/services/route_optimizer.dart';

class AssignmentController {
  AssignmentController(this._appState, {RouteOptimizer? optimizer})
      : _optimizer = optimizer ?? const RouteOptimizer();

  final AppState _appState;
  final RouteOptimizer _optimizer;

  List<DeliveryAssignment> assignmentsForStatus(DeliveryStatus status) {
    return _appState.assignments.where((assignment) => assignment.status == status).toList();
  }

  List<DeliveryAssignment> get inProgressAssignments {
    return _appState.assignments
        .where((assignment) =>
            assignment.status == DeliveryStatus.pickedUp || assignment.status == DeliveryStatus.enRoute)
        .toList();
  }

  List<DeliveryAssignment> get completedAssignments {
    return _appState.assignments
        .where((assignment) =>
            assignment.status == DeliveryStatus.delivered || assignment.status == DeliveryStatus.completed)
        .toList();
  }

  DeliveryAssignment assignment(String id) => _appState.assignmentById(id);

  DeliveryRoute optimizedRoute(DeliveryAssignment assignment) {
    return _optimizer.optimize(assignment.route);
  }

  void advanceStatus(String assignmentId) => _appState.advanceAssignmentStatus(assignmentId);

  void submitProof(String assignmentId, ProofOfDelivery proof) =>
      _appState.attachProofOfDelivery(assignmentId, proof);

  void logIncident(IncidentReport incident) => _appState.addIncident(incident);
}
