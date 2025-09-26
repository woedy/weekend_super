# Test Case TC04: Client Menu Customization and Checkout

- **User Story Reference:** US-CLIENT-2 Menu customization, US-CLIENT-3 Scheduling, US-CLIENT-4 Payment breakdown
- **Acceptance Criteria Covered:** AC-6.1, AC-6.2, AC-6.3, AC-11.1, AC-11.2, AC-11.3, AC-7.3

## Objective
Validate that clients can customize dishes, schedule service windows, review grocery versus platform fees, and submit payment successfully.

## Preconditions
- Client user authenticated (reuse account from TC01).
- At least one approved cook with menu items and availability slots (e.g., from TC02).
- Payment processor sandbox credentials configured for the mobile app.

## Test Data
- Menu item: "Lemongrass Chicken" base price $80
- Customizations: Family size, Gluten-free adjustment, Extra spice
- Desired service date: Next Friday 6pm-8pm
- Payment method: Sandbox Visa 4242 4242 4242 4242

## Steps
1. Navigate to Priya Raman’s profile and select "Lemongrass Chicken".
2. Open the customization modal and adjust portion size, dietary toggles, and spice level.
3. Observe live price updates showing grocery advance and remainder due.
4. Proceed to scheduling, choose an available slot, and attempt to overbook to confirm validation prevents conflicts.
5. Enter payment details and confirm saved billing address.
6. Submit the order and capture the order confirmation number.

## Expected Results
- Price calculator updates in real time and reflects adjustments in the order summary.
- Scheduling screen blocks unavailable slots and surfaces alternative suggestions.
- Checkout displays escrow breakdown (grocery advance, platform fee, remaining balance) matching backend calculations.
- Payment succeeds via sandbox gateway and triggers order creation with status Pending.
- Confirmation page offers add-to-calendar and share options.

## Postconditions
- Order record stored with selected customizations, price components, and scheduled window.
- Payment intent recorded with gateway reference ID and marked as authorized.

## Notes
- Re-run with saved payment method to ensure tokenization flows succeed.
