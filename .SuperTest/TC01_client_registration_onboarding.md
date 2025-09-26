# Test Case TC01: Client Registration and Onboarding Flow

- **User Story Reference:** US-ACC-1 Client registration and onboarding
- **Acceptance Criteria Covered:** AC-4.1, AC-4.2, AC-10.1, AC-10.2

## Objective
Validate that a prospective client can register, verify contact information, and complete the onboarding experience with recommended cooks displayed based on preferences.

## Preconditions
- QA environment reset to a clean state with no existing profile for the test phone/email.
- SMS and email providers configured to deliver verification codes to test inboxes.
- Mobile app build (`weekend-chef-client`) deployed to test device with debug logging enabled.

## Test Data
- Client name: Jordan Avery
- Phone: +1-555-0100 (Twilio sandbox number)
- Email: jordan.avery+test@weekendchef.test
- Preferred cuisines: Thai, Mediterranean
- Location: Austin, TX 78701

## Steps
1. Launch the Weekend Chef client app on a fresh install.
2. Select **Sign Up** and enter the test email and phone number.
3. Trigger the verification code request and retrieve the SMS/Email OTP from provider logs.
4. Input the OTP codes and submit. Confirm that mismatched codes are rejected with appropriate error messaging.
5. Complete the profile setup form with name, address, dietary preferences, and notification consent toggles.
6. Grant required permissions (push notifications, location).
7. Land on the home feed and review recommended cooks, featured menus, and filtering controls.

## Expected Results
- Dual-channel OTP delivery arrives within 30 seconds and is accepted only when correctly entered.
- Upon successful verification, a JWT-authenticated session is created and persisted securely.
- Onboarding wizard collects dietary preferences and location; data stored in the backend via API-1 endpoints.
- Home feed displays at least three recommended cooks filtered by cuisine preferences; empty states or skeleton loaders appear if data is delayed.
- Notification consent is recorded against the client profile with source/version metadata for audit.

## Postconditions
- Client account exists with verified phone and email flags set to true.
- Push notification token registered for the device.
- Audit logs capture the signup event.

## Notes
- Capture screenshots of each screen for regression documentation.
- Validate accessibility labels (VoiceOver/TalkBack) during the flow.
