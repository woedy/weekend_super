# Implementation Tasklist for Weekend Chef Platform

This checklist consolidates the core work needed to take the Weekend Chef multi-sided marketplace from the current codebase to an investor-ready, go-to-market product. Tasks are grouped by theme and reference key user stories (US) with acceptance criteria (AC) that should be satisfied before marking a task complete. For the detailed narratives and persona-specific acceptance criteria, refer to [Sample_User_Stories.md](./Sample_User_Stories.md).

> Legend: `US-x` references the user story ID, `AC-x.y` references acceptance criteria items for that story. Check off tasks only when all linked acceptance criteria are demonstrably met (code, tests, or documentation).

## 1. Platform Foundations

- [x] **FND-1 Harden configuration and secrets management**
  * Covers: secure env handling for all services.  
  * Acceptance:  
    - AC-1.1 All secrets (Django SECRET_KEY, API keys, DB creds) sourced from environment or secret manager.  
    - AC-1.2 Production-ready settings disable `DEBUG`, enforce explicit `ALLOWED_HOSTS`, and use HTTPS-related headers.  
    - AC-1.3 Committed repository is free of live database files, keys, and `node_modules`.
- [x] **FND-2 Reproducible builds & CI pipeline**
  * Acceptance:
    - AC-2.1 Backend dependencies pinned (e.g., `requirements.txt` generated via `pip-tools`).
    - AC-2.2 Flutter and web packages have explicit versions.
    - AC-2.3 CI workflow runs linting, tests, and build checks for backend, Flutter apps, and admin console on every push.
  * Implementation notes:
    - Maintain `requirements.in` + `requirements.txt` with `pip-compile` to keep versions reproducible.
    - GitHub Actions workflow `.github/workflows/ci.yml` runs backend checks, Flutter analyze/tests, and admin build.
- [x] **FND-3 Production-ready containerization & deployment docs**
  * Acceptance:  
    - AC-3.1 Dockerfiles build runnable images for backend, admin web, and ancillary services (Celery worker, Channels worker).  
    - AC-3.2 docker-compose (or K8s manifests) consistent with repository contents and support local dev + staging.  
    - AC-3.3 Ops README documents setup, migrations, scaling, and secret provisioning.

## 2. Core Domain APIs (Django Backend)

- [x] **API-1 Account & authentication flows**
  * User stories: US-ACC-1 (Client registration), US-ACC-2 (Cook onboarding), US-ACC-3 (Dispatcher onboarding).  
  * Acceptance:  
    - AC-4.1 Email/phone verification supported.  
    - AC-4.2 Role-based access control enforced for protected endpoints.  
    - AC-4.3 Profile CRUD APIs return validation errors via DRF serializers.
- [x] **API-2 Cook profile management**
  * User story: US-COOK-1 profile creation & verification.  
  * Acceptance:  
    - AC-5.1 Chefs can submit specialties, certifications, availability.  
    - AC-5.2 Admin review state tracked (pending/approved/rejected).  
    - AC-5.3 File uploads (certificates/photos) stored securely.
- [x] **API-3 Menu & dish customization**
  * User stories: US-CLIENT-2 (menu customization), US-COOK-2 (menu management).  
  * Acceptance:  
    - AC-6.1 Menu items support options (portion size, spice, dietary toggles).  
    - AC-6.2 Pricing calculations validated server-side; grocery budget estimate derived per item.  
    - AC-6.3 Versioned menu history preserved for audit.
- [x] **API-4 Order lifecycle & payment split**
  * User stories: US-CLIENT-3 scheduling, US-CLIENT-4 payment breakdown, US-COOK-3 order acceptance, US-COOK-4 grocery advance, US-DISP-1 delivery assignment.  
  * Acceptance:  
    - AC-7.1 Order statuses modeled (Pending → Accepted → Cooking → Ready → Dispatched → Delivered → Completed).  
    - AC-7.2 Escrow ledger records grocery advance, platform fee, final payout.  
    - AC-7.3 Scheduler enforces delivery windows and prevents double-booking cooks.  
    - AC-7.4 Payment provider integration handles split payouts and refunds.
- [x] **API-5 Order tracking & notifications**
  * User stories: US-CLIENT-5 order tracking, US-COOK-5 progress updates, US-DISP-2 delivery proof, US-NOTIF-1 real-time alerts.  
  * Acceptance:  
    - AC-8.1 Realtime updates via WebSockets/FCM for status changes.  
    - AC-8.2 Delivery proof supports photo/signature upload and links to payout release.  
    - AC-8.3 Notification preferences stored per user.
- [x] **API-6 Ratings, reviews, and dispute resolution**
  * User stories: US-CLIENT-7 reviews, US-COOK-7 issue reporting, US-ADMIN-3 dispute dashboard.  
  * Acceptance:  
    - AC-9.1 Post-delivery rating flow gated by delivery confirmation.  
    - AC-9.2 Dispute tickets capture chat log, evidence, and resolution state.  
    - AC-9.3 Admin overrides can adjust payouts and notify stakeholders.

## 3. Mobile App – Client (Flutter `weekend-chef-client`)

- [x] **CLI-1 Onboarding & discovery**
  * User stories: US-CLIENT-1 browsing, US-ACC-1 registration.  
  * Acceptance:  
    - AC-10.1 Auth screens with OTP/email verification.  
    - AC-10.2 Home feed surfaces recommended cooks, filters by cuisine/diet/location.  
    - AC-10.3 Accessibility and localization ready (base strings externalized).
- [x] **CLI-2 Menu customization & ordering**
  * User stories: US-CLIENT-2, US-CLIENT-3, US-CLIENT-4.  
  * Acceptance:  
    - AC-11.1 Configurable dish builder with live pricing breakdown (grocery advance vs remainder).  
    - AC-11.2 Scheduling picker enforces available slots.  
    - AC-11.3 Checkout integrates secure payment flow and displays escrow summary.
- [x] **CLI-3 Post-order experience**
  * User stories: US-CLIENT-5 tracking, US-CLIENT-6 delivery confirmation, US-CLIENT-7 review.  
  * Acceptance:  
    - AC-12.1 Order status timeline with realtime updates.  
    - AC-12.2 Delivery confirmation with issue reporting workflow (photo upload, chat support).  
    - AC-12.3 Rating & review UI with prompts for favorites/reorders.

## 4. Mobile App – Cook (Flutter `weekend_chef`)

- [x] **COOK-1 Onboarding & verification**
  * User stories: US-ACC-2, US-COOK-1.
  * Acceptance:
    - AC-13.1 KYC capture (ID upload, certifications).
    - AC-13.2 Availability calendar and service area setup.
    - AC-13.3 Admin approval status displayed with guidance.
- [x] **COOK-2 Menu & inventory management**
  * User story: US-COOK-2.
  * Acceptance:
    - AC-14.1 CRUD for dishes, ingredients, lead times.
    - AC-14.2 Pricing suggestions based on historical orders.
    - AC-14.3 Inventory warnings for low stock items.
- [x] **COOK-3 Order execution workflow**
  * User stories: US-COOK-3, US-COOK-4, US-COOK-5, US-COOK-6 payouts.
  * Acceptance:
    - AC-15.1 Order detail view with special instructions and chat.
    - AC-15.2 One-tap status updates (Accepted → Cooking → Ready).
    - AC-15.3 Grocery advance visibility and receipt upload.  
    - AC-15.4 Earnings dashboard showing pending/completed payouts and platform fees.

## 5. Mobile App – Dispatcher (Flutter `weekend-chef-dispatch`)

- [x] **DSP-1 Assignment & routing**
  * User stories: US-DISP-1, US-DISP-2.
  * Acceptance:
    - AC-16.1 Queue of ready-for-pickup orders with map view.
    - AC-16.2 Route optimization or integration with navigation apps.
    - AC-16.3 Proof-of-delivery capture (photo/signature) synced to backend.
- [x] **DSP-2 Issue reporting & communications**
  * Acceptance:
    - AC-17.1 In-app messaging or call masking with cook/client.
    - AC-17.2 Incident log submission for delays or failed deliveries.

## 6. Admin Console (Vite/React)

- [x] **ADM-1 User & cook verification dashboard**
  * User stories: US-ADMIN-1 identity checks, US-ADMIN-2 commission config.  
  * Acceptance:  
    - AC-18.1 Queue displaying pending cook applications with documents.  
    - AC-18.2 Ability to approve/flag accounts and set commission tiers.  
    - AC-18.3 Audit log for admin actions.
- [x] **ADM-2 Operations monitoring**
  * User stories: US-ADMIN-3 disputes, US-ADMIN-4 promotions.  
  * Acceptance:  
    - AC-19.1 Live dashboard of active orders, payouts, disputes.  
    - AC-19.2 Tools to issue refunds, adjust grocery advances, and apply promo codes.  
    - AC-19.3 Exportable reports for KPIs (GMV, on-time delivery rate, repeat clients).

## 7. Communications & Support

- [x] **COM-1 Unified messaging system**
  * Acceptance:  
    - AC-20.1 Secure chat threads per order across client/cook/dispatcher, with push notifications.  
    - AC-20.2 Templates for common updates ("running late", "ingredients substitute needed").
- [x] **COM-2 Knowledge base & onboarding content**
  * Acceptance:  
    - AC-21.1 In-app tutorials for all roles covering food safety, packaging, delivery etiquette.  
    - AC-21.2 Public FAQ and support contact pathways.

## 8. Quality Assurance & Compliance

- [x] **QA-1 Automated testing & monitoring**
  * Acceptance:  
    - AC-22.1 Backend unit/integration tests for critical flows (auth, orders, payouts).  
    - AC-22.2 Flutter widget/integration tests for high-traffic screens.  
    - AC-22.3 End-to-end smoke tests (e.g., Cypress) covering full order lifecycle.  
    - AC-22.4 Error monitoring (Sentry or equivalent) integrated across apps.
- [ ] **QA-2 Data privacy & food safety compliance**  
  * Acceptance:  
    - AC-23.1 PII handling documented, with data retention policies.  
    - AC-23.2 Consent flows for messaging/notifications.  
    - AC-23.3 Mechanism for clients to report allergens and for cooks to confirm compliance.

## 9. Go-To-Market Readiness

- [ ] **GTM-1 Demo environment & sample data**  
  * Acceptance:  
    - AC-24.1 Seed scripts generate realistic demo users, menus, and orders.  
    - AC-24.2 Demo walkthrough documentation/storyboard tailored for investors.  
    - AC-24.3 Reset scripts to refresh demo data quickly.
- [ ] **GTM-2 Launch playbook**  
  * Acceptance:  
    - AC-25.1 Rollout plan for initial city/university, including cook recruitment and client acquisition steps.  
    - AC-25.2 Support escalation matrix and on-call procedures.  
    - AC-25.3 KPI dashboard for early traction monitoring.

---

Use this document as the authoritative implementation checklist. Update with progress notes or additional acceptance criteria as the product scope evolves.
