# Sample User Stories for Weekend Chef Platform

This companion document to `AGENTS.md` captures the core user stories and acceptance criteria that drive the implementation checklist. Stories are grouped by persona to make sprint planning and validation clearer.

## Client (Diner)

### US-CLIENT-1 — Browse & discover cooks
- **Story**: As a client, I want to browse available cooks by cuisine, dietary preference, location, and rating so I can quickly find someone who matches my needs.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-1.1 Filters for cuisine types, dietary tags, price range, and delivery windows are available and can be combined.
  - [ ] AC-CLIENT-1.2 Search results show cook profile cards with hero image, badges, rating, response time, and next available slot.
  - [ ] AC-CLIENT-1.3 Selecting a cook opens a detailed profile with menu preview, certifications, and past reviews.

### US-CLIENT-2 — Customize dishes and build an order
- **Story**: As a client, I want to customize dishes (portion size, spice level, ingredient swaps) before placing an order so the meal matches my preferences.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-2.1 Dish detail screens surface configurable options with pricing impacts reflected instantly.
  - [ ] AC-CLIENT-2.2 Ingredient substitutions trigger cook approval when they materially change prep time or cost.
  - [ ] AC-CLIENT-2.3 Cart summary highlights grocery advance estimate versus remaining balance.

### US-CLIENT-3 — Schedule delivery
- **Story**: As a client, I want to select a delivery date and time window so I receive the meal when it’s convenient.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-3.1 Date/time pickers only show slots that respect cook availability and delivery lead times.
  - [ ] AC-CLIENT-3.2 Clients receive confirmation of their selected slot and can edit until the cook begins preparation.
  - [ ] AC-CLIENT-3.3 Conflicting slot selections raise actionable validation errors.

### US-CLIENT-4 — Understand payment breakdown & escrow
- **Story**: As a client, I want to see a transparent payment breakdown (grocery advance, platform fee, final payout) so I know what I’m paying for.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-4.1 Checkout displays subtotal, grocery advance, platform fee, taxes, and remaining balance before confirmation.
  - [ ] AC-CLIENT-4.2 Payment receipt emailed/in-app message mirrors the breakdown and indicates escrow status.
  - [ ] AC-CLIENT-4.3 Clients can cancel within policy and see how refunds affect each component.

### US-CLIENT-5 — Track order progress
- **Story**: As a client, I want to track the status of my order so I know when to expect my meal.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-5.1 Order detail view shows a status timeline (Pending → Accepted → Cooking → Ready → Dispatched → Delivered).
  - [ ] AC-CLIENT-5.2 Push notifications are triggered at each state change.
  - [ ] AC-CLIENT-5.3 Delivery stage includes live map or ETA updates when available.

### US-CLIENT-6 — Confirm delivery or raise an issue
- **Story**: As a client, I want to confirm delivery or report an issue so payouts are handled correctly.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-6.1 Client can mark delivery successful or submit an issue (late, missing items, quality concerns).
  - [ ] AC-CLIENT-6.2 Issue submission supports photos, notes, and severity tagging, triggering support workflows.
  - [ ] AC-CLIENT-6.3 Successful confirmation releases final payment automatically.

### US-CLIENT-7 — Rate and review cooks
- **Story**: As a client, I want to rate the cook and leave feedback so future clients benefit from my experience.
- **Acceptance Criteria**:
  - [ ] AC-CLIENT-7.1 Review prompt appears after delivery confirmation and cannot be bypassed without response.
  - [ ] AC-CLIENT-7.2 Ratings capture overall score plus optional tags (e.g., “Great packaging”, “On-time”).
  - [ ] AC-CLIENT-7.3 Reviews support photo uploads and are moderated per platform guidelines.

## Cook (Chef)

### US-COOK-1 — Create and verify profile
- **Story**: As a cook, I want to create a profile with specialties, certifications, and availability so clients can evaluate me.
- **Acceptance Criteria**:
  - [ ] AC-COOK-1.1 Profile form collects personal details, cuisine specialties, and service areas.
  - [ ] AC-COOK-1.2 Upload flows capture IDs, hygiene certificates, and kitchen photos for admin review.
  - [ ] AC-COOK-1.3 Status indicator communicates whether the profile is pending, approved, or requires changes.

### US-COOK-2 — Manage menus and pricing
- **Story**: As a cook, I want to create, update, and price menu items so clients can order meals I can produce.
- **Acceptance Criteria**:
  - [ ] AC-COOK-2.1 Menu editor supports dish descriptions, lead times, and photos.
  - [ ] AC-COOK-2.2 Pricing rules account for portion sizes and automatically generate grocery budget estimates.
  - [ ] AC-COOK-2.3 Version history tracks changes for audit and rollback.

### US-COOK-3 — Review and accept orders
- **Story**: As a cook, I want to review incoming orders with custom requests so I can accept only those I can fulfill.
- **Acceptance Criteria**:
  - [ ] AC-COOK-3.1 Order requests show client notes, requested delivery window, and grocery advance amount.
  - [ ] AC-COOK-3.2 Accept/decline actions update the client in real time and adjust availability.
  - [ ] AC-COOK-3.3 Declines require selecting a reason to inform support analytics.

### US-COOK-4 — Access grocery advance and track spending
- **Story**: As a cook, I want to receive an advance immediately after accepting an order so I can buy ingredients without cash flow strain.
- **Acceptance Criteria**:
  - [ ] AC-COOK-4.1 Upon acceptance, an advance payout is triggered to the cook’s preferred payment method.
  - [ ] AC-COOK-4.2 Cooks can upload receipts or mark ingredients as purchased.
  - [ ] AC-COOK-4.3 Discrepancies between estimated and actual spend trigger alerts for review.

### US-COOK-5 — Update cooking progress
- **Story**: As a cook, I want to update the order status as I prep and package meals so clients stay informed.
- **Acceptance Criteria**:
  - [ ] AC-COOK-5.1 Status updates (Accepted, Cooking, Ready for Pickup) are one tap with optional notes.
  - [ ] AC-COOK-5.2 Ready state prompts dispatcher assignment and sends packaging guidelines.
  - [ ] AC-COOK-5.3 Late prep triggers notifications to dispatcher and client support.

### US-COOK-6 — Monitor payouts and earnings
- **Story**: As a cook, I want to see pending and completed payouts, including platform fees, so I can manage my finances.
- **Acceptance Criteria**:
  - [ ] AC-COOK-6.1 Earnings dashboard shows grocery advances, final payouts, and fees per order.
  - [ ] AC-COOK-6.2 Cooks receive notifications when final payout is released or adjusted.
  - [ ] AC-COOK-6.3 Downloadable statements support personal bookkeeping.

### US-COOK-7 — Report issues
- **Story**: As a cook, I want to flag issues (ingredient shortages, client unreachable) so support can intervene early.
- **Acceptance Criteria**:
  - [ ] AC-COOK-7.1 Issue reporting is accessible from each order with predefined categories.
  - [ ] AC-COOK-7.2 Support is notified in real time and can join the order chat.
  - [ ] AC-COOK-7.3 Issue resolution outcomes are logged and visible to the cook.

## Dispatcher / Delivery Partner

### US-DISP-1 — Receive delivery assignments
- **Story**: As a dispatcher, I want to receive pickup and drop-off details once a meal is ready so I can plan routes efficiently.
- **Acceptance Criteria**:
  - [ ] AC-DISP-1.1 Assignment queue lists ready orders with pickup location, deadline, and client address.
  - [ ] AC-DISP-1.2 Dispatchers can accept/reject assignments with reason codes.
  - [ ] AC-DISP-1.3 Accepted assignments sync to navigation tools with traffic-aware ETAs.

### US-DISP-2 — Provide proof of delivery
- **Story**: As a dispatcher, I want to mark a delivery as completed with evidence so the platform can release payment.
- **Acceptance Criteria**:
  - [ ] AC-DISP-2.1 Completion flow captures photo, signature, or PIN confirmation.
  - [ ] AC-DISP-2.2 Delivery confirmation updates the order status and notifies client and cook.
  - [ ] AC-DISP-2.3 Failed deliveries trigger retry or escalation workflows.

## Admin / Platform Operations

### US-ADMIN-1 — Verify cooks and manage compliance
- **Story**: As an admin, I want to verify cook identities, certifications, and kitchens so the marketplace meets safety standards.
- **Acceptance Criteria**:
  - [ ] AC-ADMIN-1.1 Admin dashboard lists pending applications with document previews.
  - [ ] AC-ADMIN-1.2 Approval workflow logs reviewer, timestamp, and decision rationale.
  - [ ] AC-ADMIN-1.3 Rejected applications trigger automated feedback to the cook.

### US-ADMIN-2 — Configure business rules
- **Story**: As an admin, I want to configure commission rates, grocery advance percentages, and promotional offers so we can optimize revenue.
- **Acceptance Criteria**:
  - [ ] AC-ADMIN-2.1 Settings UI allows adjusting platform fee tiers per cook category or location.
  - [ ] AC-ADMIN-2.2 Grocery advance rules can be set globally or per dish type, with effective dates.
  - [ ] AC-ADMIN-2.3 Promo codes and loyalty rewards can be created, scheduled, and capped.

### US-ADMIN-3 — Monitor operations and resolve disputes
- **Story**: As an admin, I want visibility into active orders, disputes, and payouts so I can intervene quickly.
- **Acceptance Criteria**:
  - [ ] AC-ADMIN-3.1 Ops dashboard highlights stuck orders, delayed deliveries, and unresolved issues.
  - [ ] AC-ADMIN-3.2 Dispute management tools attach evidence, chat logs, and allow payout adjustments.
  - [ ] AC-ADMIN-3.3 Admin actions trigger audit logs and notifications to affected parties.

### US-ADMIN-4 — Manage customer acquisition & retention
- **Story**: As an admin, I want to run campaigns and loyalty programs so we can grow and retain both clients and cooks.
- **Acceptance Criteria**:
  - [ ] AC-ADMIN-4.1 Campaign builder supports segmentation by location, order history, or role.
  - [ ] AC-ADMIN-4.2 Campaign performance dashboards show conversion, retention, and ROI metrics.
  - [ ] AC-ADMIN-4.3 Loyalty rewards can be redeemed seamlessly within client and cook apps.

## Cross-Cutting Communications & Support

### US-NOTIF-1 — Receive timely notifications
- **Story**: As any user, I want real-time notifications for important events so I can stay informed without constantly checking the app.
- **Acceptance Criteria**:
  - [ ] AC-NOTIF-1.1 Notification preferences are configurable per channel (push, SMS, email).
  - [ ] AC-NOTIF-1.2 System sends templated messages for status updates, issues, and payouts.
  - [ ] AC-NOTIF-1.3 Users can mute non-essential notifications without losing critical alerts.

### US-SUP-1 — Get help when something goes wrong
- **Story**: As any user, I want quick access to support resources so I can resolve problems with my order or account.
- **Acceptance Criteria**:
  - [ ] AC-SUP-1.1 In-app help center includes searchable FAQs tailored to each role.
  - [ ] AC-SUP-1.2 Users can escalate to live support via chat or phone relay, with response-time SLAs.
  - [ ] AC-SUP-1.3 Support tickets track status and resolution summaries accessible to the requester.

---

Use this document alongside `AGENTS.md` to ensure each implementation task ties back to a validated user need with measurable acceptance criteria.
