# Test Case TC07: Cook Order Execution Workflow

- **User Story Reference:** US-COOK-3 Order acceptance, US-COOK-4 Grocery advance, US-COOK-5 Progress updates, US-COOK-6 Payout visibility
- **Acceptance Criteria Covered:** AC-15.1, AC-15.2, AC-15.3, AC-15.4

## Objective
Validate that cooks can accept orders, manage prep steps, log grocery receipts, and track earnings throughout fulfillment.

## Preconditions
- Order assigned to cook Priya Raman in Accepted status with grocery advance available.
- Cook wallet configured in payout provider sandbox.
- Receipt upload storage bucket accessible.

## Steps
1. Open the cook app and view the order detail; confirm special instructions and chat history load.
2. Tap **Start Grocery Run** to acknowledge the grocery advance and upload receipt photo.
3. Progress the order statuses from Cooking to Ready with optional meal prep checkpoints.
4. Review the earnings dashboard to ensure grocery advance and projected payout update after each milestone.
5. Engage with client via in-app chat to confirm communication channel functionality.

## Expected Results
- Grocery advance acknowledgement records timestamp and requires receipt before final payout release.
- Status transitions are gated by required actions (e.g., cannot mark Ready without completing required prep tasks).
- Earnings dashboard updates in real time, reflecting both pending and available balances.
- Chat messages sync across client and cook apps with push notifications.

## Postconditions
- Order marked Ready for dispatcher pickup with all prep tasks completed.
- Receipt stored securely and linked to the order record.

## Notes
- Attempt to skip receipt upload to ensure validation prevents Ready status.
