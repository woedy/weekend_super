# Test Case TC08: Dispatcher Assignment and Delivery Proof Capture

- **User Story Reference:** US-DISP-1 Assignment workflow, US-DISP-2 Delivery proof
- **Acceptance Criteria Covered:** AC-16.1, AC-16.3, AC-17.1, AC-17.2

## Objective
Confirm dispatcher assignments flow smoothly, with communication tools available and delivery proof recorded to close the order lifecycle.

## Preconditions
- Order in Ready status awaiting pickup.
- Dispatcher Luis Martinez logged into app (from TC03).
- Client chat permissions enabled for dispatcher role.

## Steps
1. Dispatcher claims the Ready order and confirms pickup time.
2. Use in-app call masking or messaging to notify the cook of arrival.
3. After pickup, mark the order as In Transit; provide optional incident report to test logging.
4. Upon reaching client, capture photo and signature proof, then mark Delivered.
5. Submit final delivery notes including any delays or substitutions.

## Expected Results
- Claiming an order assigns it exclusively to dispatcher until released/completed.
- Communication tools function with logging for compliance.
- Incident reports store structured data accessible to support staff.
- Delivery proof files upload successfully and are viewable in client app and admin console.
- Final status change triggers payout release conditions downstream.

## Postconditions
- Order status set to Delivered with dispatcher confirmation details recorded.
- Incident log (if any) linked to order for future reference.

## Notes
- Validate that unassigned dispatchers cannot access the order details once claimed.
