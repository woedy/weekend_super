# Test Case TC10: Admin Verification Dashboard and Commission Configuration

- **User Story Reference:** US-ADMIN-1 Identity checks, US-ADMIN-2 Commission management
- **Acceptance Criteria Covered:** AC-18.1, AC-18.2, AC-18.3, AC-5.2

## Objective
Ensure admin users can review pending cook applications, configure commission tiers, and audit approval actions.

## Preconditions
- Admin console deployed with test admin account (role: Compliance Manager).
- Pending cook applications available (rerun TC02 up to submission stage if needed).

## Steps
1. Log into the admin console and navigate to **Cook Applications**.
2. Review Priya Raman’s application details, including uploaded documents and availability.
3. Add reviewer notes and approve the application while setting commission tier to 20%.
4. Access the audit log and verify the approval action is recorded with before/after states.
5. Update commission tier to 18% and confirm change is tracked in history.

## Expected Results
- Application view displays all required metadata with download links for documents.
- Approval workflow enforces dual-control if configured (e.g., second reviewer required) or logs override.
- Commission changes propagate to pricing calculators and future orders.
- Audit log entries include admin identity, timestamps, and justification notes.

## Postconditions
- Cook profile status updated to Approved with commission tier 18%.
- Compliance report export includes approval details for regulatory review.

## Notes
- Attempt unauthorized access with lower-privileged admin to confirm RBAC enforcement.
