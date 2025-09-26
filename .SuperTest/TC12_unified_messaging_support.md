# Test Case TC12: Unified Messaging and Support Escalations

- **User Story Reference:** US-NOTIF-1 Real-time alerts, US-DISP-2 Communications, COM-1 Unified messaging system
- **Acceptance Criteria Covered:** AC-20.1, AC-20.2, AC-17.1

## Objective
Confirm all parties can communicate through secure chat threads per order with templated quick responses and escalation pathways.

## Preconditions
- Active order in Cooking status with client, cook, and dispatcher assigned.
- Support agent account available in admin console.

## Steps
1. Client opens order chat and sends a question about spice level adjustment.
2. Cook replies using a templated response (e.g., "Ingredient substitution needed").
3. Dispatcher joins chat to coordinate delivery timing and uses call masking to place a voice call.
4. Escalate to support by tapping **Need Help**; ensure support agent receives alert in admin console.
5. Support agent joins thread, posts resolution steps, and closes the escalation.

## Expected Results
- Chat messages deliver instantly with read receipts and typing indicators.
- Templates appear contextually for cook/dispatcher roles and log usage analytics.
- Call masking routes through telephony provider without revealing personal numbers.
- Support escalation creates ticket with SLA timers and status transitions.
- Conversation history archived and accessible for compliance review.

## Postconditions
- Support ticket marked resolved with transcript stored in knowledge base if flagged as FAQ candidate.
- Chat thread remains accessible in order history for all participants.

## Notes
- Verify offline push notifications for chat when app is backgrounded.
