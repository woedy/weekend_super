# GTM-2 Launch Playbook

The launch playbook orchestrates the first four weeks of Weekend Chef's rollout at **UT Austin (West Campus)**. It aligns
culinary recruiting, client growth, operations, and data monitoring to hit the MVP traction targets agreed with leadership.

## 1. Launch timeline & milestones

| Week | Focus | Key Deliverables |
|------|-------|------------------|
| -4 to -3 | Market validation | Confirm permitting requirements, secure shared kitchen partners, validate payment processor coverage, and identify 20 seed cooks. |
| -2 | Cook pipeline | Complete background checks, food handler verification, menu QA, and onboarding sessions for 12 launch-ready cooks (8 dinner, 4 lunch). |
| -1 | Client waitlist & logistics | Announce launch date to 500+ students/residents, finalize delivery zones, and dry-run dispatch shifts. |
| Launch week | Soft launch | Open ordering to the first 150 beta clients, monitor kitchen throughput in real time, and hold daily standups. |
| +1 | Scale & iterate | Expand delivery windows, add two new cuisines based on waitlist demand, and publish public order schedule. |
| +2 | Growth sprint | Launch referral incentives, begin corporate catering outreach, and optimize CAC via channel testing. |
| +3 | KPI review | Compare traction against North Star metrics, document learnings, and greenlight next neighborhood. |

## 2. Cook recruitment & onboarding (AC-25.1)

1. **Sourcing channels**
   - Culinary school partnerships (Auguste Escoffier Austin campus) and local Facebook chef groups.
   - Referral program: $200 bonus per cook delivering 10 orders in first two weeks.
2. **Screening checklist** (completed in Notion board `Cook Pipeline`)
   - Application review → phone screen → tasting menu submission → kitchen compliance review.
   - Background check vendor: Checkr (2 business day SLA).
   - Required documents: Food handler certificate, liability insurance, bank info (Stripe Connect onboarding), photo ID.
3. **Training & enablement**
   - Two 90-minute Zoom cohorts covering order management, allergen reporting, and packaging SOPs.
   - Provide launch kit (branded packaging, temperature log sheets, delivery handoff script).
4. **Operational readiness gates**
   - Each cook assigned to a culinary mentor for first 5 services.
   - Availability captured in admin console; kitchen slots balanced not to exceed 4 concurrent dinners per venue.

## 3. Client acquisition & retention plan (AC-25.1)

1. **Pre-launch waitlist**
   - Landing page (Webflow) with UT email validation and cuisine preferences.
   - Incentive: first meal 20% off for waitlist subscribers; track conversions in HubSpot list `UT Austin Beta`.
2. **Channel mix**
   - Campus ambassadors distributing QR flyers in dorms & Greek houses (daily coverage schedule).
   - Instagram/TikTok ads targeting 18–28 in Austin with $1,500 initial budget; optimize creative twice weekly.
   - Partnerships with two co-living operators for in-building tasting events.
3. **Retention loops**
   - Automated post-meal NPS survey (24h) with promo for 2nd order.
   - Weekly "New menus" email featuring limited runs and chef spotlights.
   - Referral program: give $15, get $15 after first referred order.

## 4. Launch day operations checklist

- Dry run dispatch using 10 dummy orders via staging environment two days prior.
- Confirm Stripe payouts in sandbox and live mode (test $1 transfers).
- Backup generator & cold storage checks completed by facilities partner.
- Staff command center at shared kitchen with Ops lead, dispatcher, and QA specialist from 3–10 PM.
- Spin up #launch-war-room Slack channel with stakeholders across ops, product, engineering, and support.

## 5. Support escalation & on-call (AC-25.2)

### 5.1 Escalation matrix

| Issue Type | First Responder | Backup | Tertiary / Exec | SLA |
|------------|-----------------|--------|-----------------|-----|
| Food safety / allergen alert | Culinary Ops Lead (Maya Patel) | Head of Culinary (Luis Romero) | COO (Avery Chen) | Immediate notification; resolve within 30 min |
| Payment failure / payout delay | Support Lead (Jonah Ellis) | Finance Manager (Priya Singh) | CEO (Nina Alvarez) | Initial response < 15 min; resolution < 2 hrs |
| Delivery incident (late/missing) | Dispatcher on duty | Ops Lead | COO | Update client within 10 min; resolution < 1 hr |
| App outage / critical bug | Engineering On-Call (pager) | CTO (Devon Lee) | CEO | Triage < 10 min; hotfix or rollback < 60 min |
| PR / social escalation | Marketing Manager (Sara Kim) | COO | CEO | Response plan drafted < 1 hr |

### 5.2 On-call schedule & tooling

- **Coverage model:** 24/7 pager rotation for engineering; 12-hour shifts (10a–10p, 10p–10a) for Ops/Support during launch month.
- **Tooling:** PagerDuty (service `Weekend Chef Production`), Slack channel `#on-call`, shared Google Voice hotline for clients.
- **Handoffs:** Daily 9:00 AM standup covering unresolved incidents, scheduled via Notion template `Launch On-Call Handoff`.
- **Runbooks:** Link PagerDuty alerts to Notion runbooks for outages, refund overrides, Stripe disputes, and allergen protocol.

## 6. KPI dashboard & monitoring (AC-25.3)

1. **North Star & health metrics**
   - GMV (daily & weekly), average order value, repeat purchase rate, and cook utilization.
   - On-time delivery rate, CSAT/NPS, refund rate, allergen incident count.
2. **Data pipeline**
   - Segment events from apps/website → RudderStack → BigQuery dataset `launch_ut_austin`.
   - Daily dbt job materializes tables `fact_orders`, `fact_deliveries`, `fact_support_tickets`.
   - Mode Analytics dashboard `UT Austin Launch` pulls from curated tables; refresh hourly 10a–10p.
3. **Ownership & rituals**
   - Growth PM reviews dashboards twice daily and posts highlights in `#launch-war-room`.
   - Friday stakeholder sync to inspect trends, experiment results, and backlog adjustments.
   - KPI guardrails: trigger incident review if on-time delivery < 90% or NPS < 45.

## 7. Post-launch retrospective

- Collect qualitative feedback from cooks, clients, and dispatchers (structured interviews within 72 hours of launch week).
- Document experiment outcomes (channels, promos) with CAC/LTV impact.
- Update this playbook before expanding to the next neighborhood or university market.
