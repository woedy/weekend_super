# Test Case TC06: Real-time Order Tracking and Notifications

- **User Story Reference:** US-CLIENT-5 Order tracking, US-COOK-5 Progress updates, US-DISP-2 Delivery proof, US-NOTIF-1 Real-time alerts
- **Acceptance Criteria Covered:** AC-8.1, AC-8.2, AC-8.3, AC-12.1

## Objective
Ensure status updates propagate across client, cook, and dispatcher apps with push notifications and WebSocket events reflecting order progress.

## Preconditions
- Order from TC04 moved to Accepted status by cook.
- WebSocket gateway and Firebase Cloud Messaging configured for staging.
- Test devices for client, cook, and dispatcher apps logged in with respective roles.

## Steps
1. On the cook app, move the order through statuses: Accepted → Cooking → Ready.
2. Observe push notifications on the client app and confirm timeline updates in real time.
3. In the dispatcher app, assign the order and mark as Dispatched.
4. Client app should display map with dispatcher location updates and ETA adjustments.
5. Upon delivery, dispatcher captures photo/signature and marks order Delivered.
6. Confirm final notification prompts client for delivery confirmation.

## Expected Results
- Each status change triggers immediate push notification with localized message content.
- Client timeline updates without manual refresh, showing latest status and timestamps.
- Delivery proof assets upload successfully and become viewable to client and admin.
- Notification preferences respected; opt-out users receive only transactional messages.

## Postconditions
- Order status is Delivered with proof-of-delivery stored and accessible.
- Notification logs show successful delivery to all parties.

## Notes
- Validate fallback polling behavior by temporarily disabling WebSocket connection.
