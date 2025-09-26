# GTM Demo Environment & Sample Data

This folder packages everything needed to stand up an investor-facing demo of Weekend Chef.
Use the management commands and walkthrough below to generate realistic data, narrate the
product story, and quickly reset between meetings.

## 1. Prerequisites

1. Activate your virtualenv and install backend requirements (`pip install -r requirements.txt`).
2. Ensure database migrations have been applied (`python manage.py migrate`).

## 2. Seeding the demo

Run the Django management command from the backend directory:

```bash
python manage.py seed_demo_data
```

The command will:

- create dedicated demo accounts for two clients, two chefs, a dispatcher, and an admin host;
- publish a curated catalog of comfort-classic and wellness dishes with costed ingredients;
- attach allergen preferences and certifications; and
- generate two narrative orders with escrow ledger entries and allergen acknowledgements.

All demo accounts share the password `cookdemo123` for ease of presentation.

## 3. Investor walkthrough storyboard

Use the scripted flow below to highlight each persona in ~8 minutes.

1. **Investor host (Avery Stone)** opens the admin dashboard to confirm both chefs are approved and available.
2. **Client Aria Nguyen** reviews the delivered order `GTM-DEMO-ORDER-1`, confirming the allergen handling
   notes and viewing the grocery advance vs. final payout split.
3. **Chef Lina Hart** showcases her comfort classics menu, pointing to certifications and service radius to
   illustrate trust and coverage.
4. **Client Marco Diaz** has an upcoming wellness bowl delivery `GTM-DEMO-ORDER-2`; demonstrate how dispatch
   coordination and allergen preferences flow automatically to the kitchen.
5. **Dispatcher Jules Kim** checks the accepted order queue, confirming delivery windows, before handing the
   narrative back to the host for closing KPIs.

## 4. Quick reset tooling

To clear and rebuild the demo in one step run:

```bash
./ops/demo/refresh_demo.sh
```

The helper script executes `python manage.py reset_demo_data` followed by `seed_demo_data`, ensuring a pristine
state before each presentation. You can also run the commands individually if you want to inspect the database
between steps.

## 5. Manual reset

If you prefer to wipe the demo data without immediately reseeding:

```bash
python manage.py reset_demo_data
```

The reset command removes demo users, catalog items, carts, orders, escrow ledger entries, and supporting
reference data such as certifications and dietary preferences.

## 6. Troubleshooting tips

- If the commands fail due to missing tables, run migrations and retry.
- When running via Docker, prefix commands with `docker compose run --rm backend`.
- The commands are idempotent; rerunning `seed_demo_data` safely refreshes all demo records.
