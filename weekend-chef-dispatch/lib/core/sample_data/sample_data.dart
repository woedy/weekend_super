import '../models/contact.dart';
import '../models/delivery_assignment.dart';
import '../models/dispatcher_profile.dart';
import '../models/incident_report.dart';
import '../models/proof_of_delivery.dart';
import '../models/geo_point.dart';
import '../services/app_state.dart';

AppState buildSampleAppState() {
  final dispatcherProfile = DispatcherProfile(
    name: 'Jordan Adekoya',
    email: 'dispatch@weekendchef.app',
    phone: '+1 (555) 010-3333',
    serviceAreas: const ['Midtown', 'Downtown', 'Uptown'],
    completedDeliveries: 186,
    onTimeRate: 0.94,
  );

  final cookContact = Contact(
    id: 'cook-1',
    name: 'Chef Laila',
    role: ContactRole.cook,
    maskedPhone: '+1 (555) 010-9010',
  );
  final clientContact = Contact(
    id: 'client-1',
    name: 'Marcus Reid',
    role: ContactRole.client,
    maskedPhone: '+1 (555) 010-4477',
  );
  final dispatcherContact = Contact(
    id: 'dispatcher-1',
    name: dispatcherProfile.name,
    role: ContactRole.dispatcher,
    maskedPhone: dispatcherProfile.phone,
  );

  final assignment1 = DeliveryAssignment(
    id: 'assignment-101',
    orderNumber: 'ORD-101',
    clientName: clientContact.name,
    cookName: cookContact.name,
    cuisine: 'West African bowls',
    route: DeliveryRoute(
      pickup: DeliveryStop(
        label: 'Chef studio',
        address: '22B 5th Ave, Midtown',
        coordinate: const GeoPoint(40.7411, -73.9897),
        isPickup: true,
      ),
      dropoff: DeliveryStop(
        label: 'Client drop-off',
        address: '601 W 57th St, New York',
        coordinate: const GeoPoint(40.7713, -73.9882),
      ),
      distanceKm: 4.8,
      estimatedDuration: const Duration(minutes: 18),
      polyline: _manhattanPolyline,
    ),
    status: DeliveryStatus.readyForPickup,
    scheduledWindowStart: DateTime.now().add(const Duration(minutes: 20)),
    scheduledWindowEnd: DateTime.now().add(const Duration(minutes: 50)),
    maskedClientPhone: clientContact.maskedPhone!,
    maskedCookPhone: cookContact.maskedPhone!,
    notes: 'Client requested reusable containers be returned.',
    rush: true,
    events: [
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
        message: 'Cook accepted order and began prep.',
      ),
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        message: 'Cook marked as Ready for pickup.',
      ),
    ],
  );

  final assignment2 = DeliveryAssignment(
    id: 'assignment-102',
    orderNumber: 'ORD-102',
    clientName: 'Nyah Chen',
    cookName: 'Chef Mateo',
    cuisine: 'Plant-based tacos',
    route: DeliveryRoute(
      pickup: DeliveryStop(
        label: 'Chef Mateo kitchen',
        address: '145 Orchard St, New York',
        coordinate: const GeoPoint(40.7209, -73.9906),
        isPickup: true,
      ),
      dropoff: DeliveryStop(
        label: 'Client drop-off',
        address: '30 Hudson Yards, New York',
        coordinate: const GeoPoint(40.7540, -74.0027),
      ),
      distanceKm: 6.2,
      estimatedDuration: const Duration(minutes: 22),
      polyline: _lowerManhattanPolyline,
    ),
    status: DeliveryStatus.enRoute,
    scheduledWindowStart: DateTime.now().subtract(const Duration(minutes: 10)),
    scheduledWindowEnd: DateTime.now().add(const Duration(minutes: 25)),
    maskedClientPhone: '+1 (555) 010-9966',
    maskedCookPhone: '+1 (555) 010-2234',
    events: [
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 55)),
        message: 'Cook accepted order.',
      ),
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
        message: 'Dispatcher picked up order and started route.',
      ),
    ],
  );

  final assignment3 = DeliveryAssignment(
    id: 'assignment-103',
    orderNumber: 'ORD-103',
    clientName: 'Corporate tasting room',
    cookName: 'Chef Laila',
    cuisine: 'Vegan sampler',
    route: DeliveryRoute(
      pickup: DeliveryStop(
        label: 'Chef studio',
        address: '22B 5th Ave, Midtown',
        coordinate: const GeoPoint(40.7411, -73.9897),
        isPickup: true,
      ),
      dropoff: DeliveryStop(
        label: 'Hudson Co-working',
        address: '500 W 36th St, New York',
        coordinate: const GeoPoint(40.7553, -73.9980),
      ),
      distanceKm: 3.7,
      estimatedDuration: const Duration(minutes: 14),
      polyline: _midtownPolyline,
    ),
    status: DeliveryStatus.completed,
    scheduledWindowStart: DateTime.now().subtract(const Duration(hours: 2)),
    scheduledWindowEnd: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    maskedClientPhone: '+1 (555) 010-2222',
    maskedCookPhone: '+1 (555) 010-9010',
    proofOfDelivery: ProofOfDelivery(
      capturedAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
      notes: 'Left with front desk concierge.',
    ),
    events: [
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 15)),
        message: 'Cook marked ready for pickup.',
      ),
      AssignmentEvent(
        timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
        message: 'Delivery completed and proof submitted.',
      ),
    ],
  );

  final threads = [
    ChatThread(
      id: 'thread-101',
      assignmentId: assignment1.id,
      subject: 'Questions about cutlery',
      participants: [dispatcherContact, cookContact, clientContact],
      messages: [
        ChatMessage(
          id: 'msg-1',
          sender: clientContact,
          body: 'Please include compostable forks with the order.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        ChatMessage(
          id: 'msg-2',
          sender: cookContact,
          body: 'Included! Packed with the sauces.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 28)),
        ),
      ],
    ),
    ChatThread(
      id: 'thread-102',
      assignmentId: assignment2.id,
      subject: 'Route running slightly late',
      participants: [
        dispatcherContact,
        Contact(
          id: 'cook-2',
          name: 'Chef Mateo',
          role: ContactRole.cook,
          maskedPhone: assignment2.maskedCookPhone,
        ),
        Contact(
          id: 'client-2',
          name: 'Nyah Chen',
          role: ContactRole.client,
          maskedPhone: assignment2.maskedClientPhone,
        ),
      ],
      messages: [
        ChatMessage(
          id: 'msg-3',
          sender: dispatcherContact,
          body: 'Hit traffic on 9th Ave, ETA 6 mins beyond window. Keeping you posted.',
          sentAt: DateTime.now().subtract(const Duration(minutes: 6)),
          isFromDispatcher: true,
        ),
      ],
    ),
  ];

  final incidents = [
    IncidentReport(
      id: 'incident-1',
      assignmentId: 'assignment-098',
      type: 'Delayed pickup',
      description: 'Cook requested an extra 10 minutes to finish packaging.',
      submittedAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      resolution: 'Schedule buffer added and client notified.',
    ),
  ];

  return AppState(
    assignments: [assignment1, assignment2, assignment3],
    chatThreads: threads,
    dispatcherProfile: dispatcherProfile,
    incidents: incidents,
  );
}

final _manhattanPolyline = const [
  GeoPoint(40.7411, -73.9897),
  GeoPoint(40.7484, -73.9857),
  GeoPoint(40.7540, -73.9865),
  GeoPoint(40.7625, -73.9899),
  GeoPoint(40.7713, -73.9882),
];

final _lowerManhattanPolyline = const [
  GeoPoint(40.7209, -73.9906),
  GeoPoint(40.7253, -73.9921),
  GeoPoint(40.7327, -73.9965),
  GeoPoint(40.7416, -74.0002),
  GeoPoint(40.7484, -74.0039),
  GeoPoint(40.7540, -74.0027),
];

final _midtownPolyline = const [
  GeoPoint(40.7411, -73.9897),
  GeoPoint(40.7440, -73.9920),
  GeoPoint(40.7496, -73.9936),
  GeoPoint(40.7553, -73.9980),
];
