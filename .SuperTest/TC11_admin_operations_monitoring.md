# Test Case TC11: Admin Operations Monitoring Dashboard

- **User Story Reference:** US-ADMIN-3 Disputes monitoring, US-ADMIN-4 Promotions and KPI reporting
- **Acceptance Criteria Covered:** AC-19.1, AC-19.2, AC-19.3

## Objective
Validate that operations admins can monitor active orders, payouts, and disputes while issuing refunds or promos and exporting KPI reports.

## Preconditions
- Admin operations account with full permissions.
- Existing active orders, disputes, and payout data (from TC04-TC09).
- Analytics export endpoint accessible.

## Steps
1. Log into the admin console and open the **Operations Dashboard**.
2. Review live metrics for active orders, on-time delivery rate, and open disputes.
3. Issue a partial refund on the disputed order and apply a promo code to a different active order.
4. Verify payout adjustments reflect in cook earnings and ledger entries.
5. Export KPI report (CSV) for the last 7 days and confirm metrics align with on-screen data.

## Expected Results
- Dashboard auto-refreshes key metrics with WebSocket or polling updates.
- Refund and promo actions require confirmation and produce audit records.
- KPI export includes GMV, repeat client rate, average rating, and dispute resolution time.
- Data integrity maintained between dashboard view and exported report.

## Postconditions
- Refund processed through payment provider sandbox and recorded in financial systems.
- Promo code usage reflected in client order history.

## Notes
- Stress test by simulating high order volume to observe performance and chart responsiveness.
