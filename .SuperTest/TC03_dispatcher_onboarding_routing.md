# Test Case TC03: Dispatcher Onboarding and Routing Setup

- **User Story Reference:** US-ACC-3 Dispatcher onboarding, US-DISP-1 Assignment & routing
- **Acceptance Criteria Covered:** AC-4.1, AC-16.1, AC-16.2

## Objective
Verify dispatchers can register, receive role-appropriate access, and configure navigation integrations for route planning.

## Preconditions
- Dispatcher mobile app (`weekend-chef-dispatch`) installed on device with location services enabled.
- Google Maps or Waze API keys configured for staging environment.
- At least one ready-for-pickup order seeded in the backend.

## Test Data
- Dispatcher name: Luis Martinez
- Email: luis.martinez+dispatch@weekendchef.test
- Phone: +1-555-0122

## Steps
1. Launch dispatcher app and register via phone/email verification flow.
2. Accept required location permissions and background tracking prompts.
3. Review the active order queue and ensure at least one order appears with pickup and drop-off addresses.
4. Tap **Start Route** for the top order and select preferred navigation provider (Google Maps, Waze).
5. Confirm the navigation app launches with the correct coordinates and estimated travel time.
6. Return to the dispatcher app and observe live route progress updates and ETA adjustments.

## Expected Results
- Dispatcher role assigned automatically based on invite code or admin provisioning; unauthorized access prevented.
- Order queue displays real-time data from backend with status badges.
- Navigation deep link correctly transmits pickup location; subsequent steps show drop-off transition prompts.
- Background location tracking updates order timeline and is reflected in client tracking view.

## Postconditions
- Dispatcher session remains active with push token registered for future assignments.
- Audit log captures route start timestamp and navigation provider selection.

## Notes
- Repeat with navigation provider offline to validate fallback routing instructions.
