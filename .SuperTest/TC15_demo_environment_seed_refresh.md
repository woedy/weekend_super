# Test Case TC15: Demo Environment Seeding and Refresh Workflow

- **User Story Reference:** GTM-1 Demo environment & sample data
- **Acceptance Criteria Covered:** AC-24.1, AC-24.2, AC-24.3

## Objective
Validate that demo data seed and reset commands produce a consistent investor-ready environment with scripted walkthrough support.

## Preconditions
- Access to staging demo environment with CLI access.
- Latest seed scripts deployed (`seed_demo_data`, `reset_demo_data`).
- Demo walkthrough documentation available.

## Steps
1. Execute `python manage.py reset_demo_data` and confirm command completes without errors, clearing previous demo records.
2. Run `python manage.py seed_demo_data` and review console output for created entities (clients, cooks, dispatchers, orders).
3. Launch the client app in demo mode and walk through the scripted investor scenario, verifying seeded data matches storyline.
4. Validate marketing site demo dashboard reflects seeded KPIs (GMV, order volume).
5. Rerun reset command to ensure idempotency and that persistent configuration (feature flags) remains intact.

## Expected Results
- Reset command safely archives previous demo users/orders and repopulates baseline reference data.
- Seeded accounts include realistic personas with narrative notes for presenters.
- Demo walkthrough flows without missing assets or 404s, covering ordering, tracking, and reviews.
- KPI dashboard pulls from seeded dataset and aligns with documentation.

## Postconditions
- Demo environment returns to pristine state ready for next presentation.
- Logs capture command execution timestamps for auditing.

## Notes
- Schedule automated nightly refresh and monitor for failures via alerting integration.
