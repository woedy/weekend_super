# Data Privacy & Food Safety Compliance Playbook

This document summarizes how the Weekend Chef platform satisfies QA-2 acceptance
criteria for personal data handling, notification consent, and allergen
controls.

## PII handling & retention (AC-23.1)

### Where PII lives
- **Accounts:** Core user attributes (email, phone, location) reside in the
  `accounts.User` model, while client profiles extend PII with addresses and
  dietary context via `clients.Client` and related models.【F:weekend-chef-backend/accounts/models.py†L52-L118】【F:weekend-chef-backend/clients/models.py†L24-L101】
- **Notifications:** Contact consent settings are isolated in
  `notifications.NotificationPreference` to avoid scattering opt-in state across
  the codebase.【F:weekend-chef-backend/notifications/models.py†L10-L24】
- **Orders:** Sensitive meal notes, including allergen declarations, are stored
  on `orders.OrderAllergenReport`, ensuring per-order visibility with explicit
  chef acknowledgement tracking.【F:weekend-chef-backend/orders/models.py†L122-L149】

### Retention & deletion guidance
- **User initiated deletion:** When a user account is removed, associated client
  profiles, notification preferences, and allergen reports cascade via foreign
  keys. Operators must follow the anonymization checklist in the ops runbook
  before hard deletes to preserve ledger integrity while honoring right-to-be
  forgotten requests.
- **Dormant accounts:** Accounts inactive for 18 months should be archived by
  disabling login and purging notification tokens, while retaining order history
  for financial compliance.
- **Allergen reports:** Retain allergen confirmations for 24 months after order
  completion to support food safety audits, then purge as part of the scheduled
  quarterly data minimization job documented in the ops maintenance checklist.
- **Backups:** Database snapshots must be encrypted at rest; restores into lower
  environments require anonymization scripts to strip contact info before use.

## Consent flows for messaging (AC-23.2)

- API clients use `GET/PATCH /api/v2/notifications/preferences/` to manage
  opt-ins. Updates capture the consent source, policy version, and timestamp in
  `NotificationPreference.consent_*` fields, providing an auditable trail for
  regulators.【F:weekend-chef-backend/notifications/api/v2/views.py†L1-L17】【F:weekend-chef-backend/notifications/api/v2/serializers.py†L1-L38】
- Default settings enable transactional alerts only; marketing updates are
  disabled until an explicit opt-in is submitted.
- For marketing email pushes, campaigns must filter for
  `marketing_updates=True` and store the matching `consent_version` in the blast
  metadata.

## Allergen reporting workflow (AC-23.3)

1. **Client submission:** `/api/v2/orders/{id}/report-allergens/` accepts a list
   of allergen IDs and optional free-form notes. The endpoint ensures only the
   client who placed the order can submit, records a timestamp, and resets any
   previous chef acknowledgement.【F:weekend-chef-backend/orders/api/v2/views.py†L48-L92】【F:weekend-chef-backend/orders/api/v2/serializers.py†L40-L79】
2. **Chef acknowledgement:** `/api/v2/orders/{id}/acknowledge-allergens/` is
   restricted to the assigned chef. Acknowledgement stores notes, timestamp, and
   flips the compliance flag used in kitchen dashboards.【F:weekend-chef-backend/orders/api/v2/views.py†L94-L111】
3. **Visibility:** Order payloads now embed `allergen_report` data so dispatch
   and admin tools can block hand-offs until the chef has confirmed compliance.

## Operational checklist
- Review consent exports monthly to validate opt-in health and policy version
  adoption.
- Include allergen acknowledgement status in pre-shift briefings; orders lacking
  chef confirmation should not begin grocery procurement.
- Keep this document version-controlled and update when privacy policies or food
  safety regulations change.
