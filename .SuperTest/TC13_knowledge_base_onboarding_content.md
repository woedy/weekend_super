# Test Case TC13: Knowledge Base and In-App Onboarding Content

- **User Story Reference:** COM-2 Knowledge base & onboarding content
- **Acceptance Criteria Covered:** AC-21.1, AC-21.2

## Objective
Ensure role-specific onboarding tutorials and knowledge base articles are accessible, localized, and cover mandatory topics like food safety and delivery etiquette.

## Preconditions
- Knowledge base CMS populated with latest articles.
- Client, cook, and dispatcher apps installed with localization pack (English/Spanish).

## Steps
1. Log into each app (client, cook, dispatcher) and navigate to onboarding tutorials.
2. Confirm food safety, packaging, and delivery etiquette modules play with interactive checkpoints.
3. Switch device locale to Spanish and verify localization applies to tutorials and article listings.
4. Access the public FAQ web portal and search for "allergen policy".
5. Submit a feedback rating on an article and ensure it logs to analytics.

## Expected Results
- Tutorials render with accessible captions and support resuming progress.
- Mandatory modules require completion acknowledgement before allowing order participation.
- Localization covers titles, body content, and UI chrome without truncation.
- FAQ portal search returns relevant articles with contact escalation options.
- Article feedback stored with user role metadata for content optimization.

## Postconditions
- Completion status recorded for each user and visible to support/admin dashboards.
- Feedback analytics updated with submission data.

## Notes
- Confirm offline caching of tutorials for cooks operating in low-connectivity kitchens.
