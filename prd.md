# OTP-Verified Lead Form — PRD
**Project owner:** Pratham Bhalotia  
**Stakeholders:** Product, Data, Engineering, CRM/Ops, Dealers, Legal/Compliance  
**Date:** 2025-09-xx

---

## 1. Overview / Problem
Dealers receive a large volume of leads, many of which are unreachable, duplicate or low-intent (fake phone numbers, bots, casual browse submissions). This reduces dealer ROI, increases complaints, and damages the marketplace experience.

## 2. Goal / Success criteria
**Primary goal:** Improve lead quality (more reachable, higher intent) for dealer-side conversions.  
**Primary success metric:** **Qualified Lead Rate (QLR)** — proportion of leads that are OTP-verified and result in a dealer contact attempt.  
**Target (expected):** +10–15% QLR (estimate to be validated with an A/B test).  
**Guardrails:** total leads should not drop >5%; cost per verified lead must be within budget.

## 3. User stories
- **Buyer:** As a buyer, I want to verify my phone via OTP so dealers can contact me reliably.  
- **Dealer:** As a dealer, I want fewer fake leads so I spend less time on invalid contacts.  
- **Ops:** As Ops, I want event logs and dashboards to measure lead quality and manage exceptions.

## 4. Proposed solution (high level)
Add an OTP verification step in the lead submission flow. Flow variant B (experiment) will require OTP verification before final lead creation; variant A remains current flow (control).

Screens:
1. Lead form (name, phone, city, optional message)  
2. OTP entry (6-digit OTP sent to phone)  
3. Confirmation (lead created + dealer contact CTA)

## 5. Metrics (definition)
- **Lead Form Views** — count of users who opened the lead form.  
- **Lead Submissions** — users who attempted to submit (clicked submit).  
- **OTP Sent** — SMS request events, per phone.  
- **OTP Verified** — user verified OTP successfully.  
- **Qualified Lead** — lead record with `otp_verified = true` and `dealer_contact_attempted = true`.  
- **Qualified Lead Rate (QLR)** = qualified_leads / total_leads (as percentage).  
- **Lead Form Abandonment Rate** = (lead_form_views - lead_submissions) / lead_form_views.

## 6. Requirements
### Functional
- Send OTP on submission attempt using SMS provider.
- Verify OTP (6-digit) within TTL (e.g., 5 minutes).
- Allow resend with rate limit (e.g., max 3 resends / 15 minutes).
- Create lead record only after OTP verified (for experiment variant).
- For logged-in users, pre-fill phone; still enforce OTP if not recently verified.
- Track analytics events for every step.

### Non-functional
- OTP deliverability > 95% (monitor SMS provider).
- Latency: OTP send request < 2s to provider (backend async acceptable).
- Data privacy: mask phone numbers in UI & logs.

## 7. Out of scope
- Rewriting dealer UI / CRM integration beyond passing verified leads.
- Payment or identity KYC flows.

## 8. Analytics / Tracking (Event plan)
(Event names below — exact naming should match instrumentation standards)
- `lead_form_view` { user_id, session_id, car_id, channel }
- `lead_submit_attempt` { user_id, phone_masked, car_id, channel }
- `otp_sent` { phone_masked, provider_response, attempt_id }
- `otp_verified` { user_id, phone_masked, attempt_id }
- `lead_created` { lead_id, user_id, phone_masked, otp_verified }
- `dealer_contact_attempted` { lead_id, dealer_id, timestamp }

## 9. A/B Test Plan (summary)
- **Hypothesis:** Requiring OTP before lead creation increases QLR by X% (expected +10–15%).  
- **Experiment design:** Randomize users at session cookie level into Control (A) vs OTP (B).  
- **Primary metric:** QLR. Secondary: lead volume, lead_form_abandonment_rate, OTP success rate, dealer complaints.  
- **Guardrails / rollback:** If total leads drop >10% OR dealer NPS declines OR SMS cost > budget, pause.

## 10. Risks & Mitigations
- **Risk:** OTP introduces friction and reduces total lead volume. *Mitigation:* Run A/B test, monitor guardrails, enable lighter verification for high-intent channels.  
- **Risk:** SMS delivery issues. *Mitigation:* Add secondary provider fallback & show clear retry messaging.  
- **Risk:** Increased cost. *Mitigation:* Monitor cost per verified lead and use throttling/geo-based rollout.

## 11. Acceptance criteria
- PRD reviewed & approved by Product and Data.
- Figma screens for 3 states (Lead Form, OTP, Confirmation) added to repo.
- Instrumentation spec delivered (event names + properties).
- A/B test ready with randomization & tracking; SQL queries for reporting validated on historical or simulated data.

---
