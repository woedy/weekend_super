# Test Case TC02: Cook Onboarding, KYC, and Approval Workflow

- **User Story Reference:** US-ACC-2 Cook onboarding, US-COOK-1 Profile creation & verification
- **Acceptance Criteria Covered:** AC-5.1, AC-5.2, AC-5.3, AC-13.1, AC-13.2, AC-13.3

## Objective
Ensure a prospective cook can submit identity documentation, define availability, and progress through the admin approval flow with secure storage of uploaded assets.

## Preconditions
- Cook mobile app (`weekend_chef`) installed on test device.
- Admin reviewer account available in the web console with permission to approve cooks.
- Test AWS S3 bucket configured for file uploads in staging environment.

## Test Data
- Cook name: Priya Raman
- Email: priya.raman+chef@weekendchef.test
- Phone: +1-555-0111
- Documents: Driver’s license image (JPEG), Food handler certificate (PDF)
- Availability: Weekdays 4pm-9pm, Zip codes 78701-78705

## Steps
1. Launch the cook app and register with the provided email and phone number.
2. Complete KYC prompts by capturing or uploading the license image and certification PDF.
3. Enter service area zip codes, cuisine specialties, and pricing baseline.
4. Configure availability calendar slots and set maximum weekly orders.
5. Submit the application and confirm receipt of a pending review status.
6. Log into the admin console as a reviewer, open the pending cook queue, inspect Priya Raman’s submission, and approve the profile.
7. Return to the cook app, refresh the dashboard, and confirm status transitions to approved with onboarding checklist cleared.

## Expected Results
- File uploads are encrypted in transit and stored in the secure bucket with signed URLs.
- Validation errors surface inline (e.g., missing certification) and block submission.
- Admin console shows all submitted metadata, including availability calendar and documents.
- Approval action triggers push/email notification to the cook and unlocks order acceptance features.
- Audit trail records the admin reviewer, timestamp, and status change.

## Postconditions
- Cook account is active with verified credentials and availability slots published.
- Compliance documents associated with the cook profile in the backend.

## Notes
- Repeat the test with a rejection scenario to validate error messaging and resubmission flow.
