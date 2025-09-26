# Test Case TC09: Client Post-Delivery Review and Dispute Resolution

- **User Story Reference:** US-CLIENT-6 Delivery confirmation, US-CLIENT-7 Review submission, US-COOK-7 Issue reporting, US-ADMIN-3 Dispute dashboard
- **Acceptance Criteria Covered:** AC-9.1, AC-9.2, AC-9.3, AC-12.2, AC-12.3

## Objective
Verify that clients can confirm delivery, leave a rating/review, and escalate disputes with evidence while admins manage resolution.

## Preconditions
- Order delivered in TC08 with proof on file.
- Admin dispute manager account available.
- Support SLA notifications configured.

## Steps
1. In the client app, open the delivered order and confirm receipt.
2. Submit a 5-star rating with text feedback and optional tip adjustment.
3. Reopen the order and trigger **Report an Issue** to simulate a missing side dish; attach photo evidence.
4. Ensure support chat opens and logs conversation with dispatcher/cook if needed.
5. Admin logs into dispute dashboard, reviews submission, adjusts payout (partial refund), and communicates resolution.
6. Client receives resolution notification and views updated order summary.

## Expected Results
- Review submission gated by delivery confirmation; duplicate reviews prevented.
- Dispute record captures timeline, chat transcripts, and attachments.
- Admin resolution updates payout ledger and sends templated notification to all parties.
- Client sees resolution status (e.g., Resolved with Refund) and adjusted charges.

## Postconditions
- Order flagged with resolved dispute; refund recorded in payment provider sandbox.
- Review remains visible in cook profile with dispute note if applicable.

## Notes
- Test SLA breach scenario to ensure escalation emails fire when unresolved beyond threshold.
