# Test Case TC14: Data Privacy and Food Safety Compliance Controls

- **User Story Reference:** QA-2 Data privacy & food safety compliance
- **Acceptance Criteria Covered:** AC-23.1, AC-23.2, AC-23.3

## Objective
Validate consent management, PII retention policies, and allergen reporting workflows meet regulatory expectations and provide auditability.

## Preconditions
- Compliance playbook accessible for reference.
- Backend seeded with test clients and cooks.
- Consent versioning enabled in notification preferences API.

## Steps
1. Via client app, update notification preferences toggling marketing opt-in; verify consent timestamp and source recorded.
2. Submit a data deletion request through profile settings and confirm acknowledgement email is delivered.
3. As admin, review data retention dashboard to ensure deletion request enters queue with SLA timer.
4. Place an order specifying nut allergy and verify cook receives allergen checklist requiring explicit acknowledgement.
5. Confirm allergen acknowledgement stored per order and surfaced in compliance reports.

## Expected Results
- Consent updates propagate to backend with version metadata and can be exported for audits.
- Data deletion workflow masks PII immediately while scheduling hard deletion per retention policy.
- Allergen checklist requires cook confirmation before order can proceed to Ready status.
- Compliance reports show full trace of consent changes and allergen confirmations.

## Postconditions
- Consent history reflects latest state with previous versions archived.
- Deletion request remains trackable until completion, with follow-up notification sent post-fulfillment.

## Notes
- Execute negative test by attempting to edit order allergen notes after acknowledgement to ensure versioning captures changes.
