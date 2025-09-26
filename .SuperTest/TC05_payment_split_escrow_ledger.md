# Test Case TC05: Payment Split and Escrow Ledger Integrity

- **User Story Reference:** US-CLIENT-4 Payment breakdown, US-COOK-4 Grocery advance, US-ADMIN-2 Commission config
- **Acceptance Criteria Covered:** AC-7.1, AC-7.2, AC-7.4, AC-18.2

## Objective
Confirm the backend processes payments by allocating funds to grocery advance, platform fees, and cook payout ledgers with accurate reporting for admins.

## Preconditions
- Order submitted from TC04 in Pending status with authorized payment intent.
- Finance admin account with permission to review escrow ledger.
- Payment processor sandbox configured to allow capture/settlement.

## Test Data
- Commission tier: 20% platform fee
- Grocery advance: $40
- Remaining payout upon completion: Calculated from order total

## Steps
1. In the admin console, locate the pending order from TC04 and trigger **Capture Grocery Advance**.
2. Verify the ledger entries for grocery advance disbursement to cook wallet.
3. Simulate order completion via backend (status Completed) and trigger **Release Final Payout**.
4. Confirm platform fee deduction and payout amounts are logged correctly.
5. Export the order financial report and verify the captured values align with ledger entries.

## Expected Results
- Escrow ledger entries show distinct records for grocery advance, platform fee, and final payout.
- Captured amounts reconcile with payment intent totals and commission configuration.
- Audit events include admin actor, timestamps, and transaction IDs.
- Exported report matches ledger and can be imported into accounting tooling without adjustment.

## Postconditions
- Cook wallet balance reflects total payout minus platform fee.
- Payment provider dashboard shows successful capture and transfer events.

## Notes
- Negative test: attempt double capture to confirm safeguards prevent duplicate payouts.
