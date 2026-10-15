# SCIVO — PROJECT PASSPORT (v1.2)

## Decisions (approved by PO)
- Test format: Web link (PWA) via GitHub Pages: https://radikmardanov.github.io/scivo/
- Audience: families in Russia, children 7–10 (grades 1–4)
- Accounts: family model. Only parent has email/password (Supabase Auth).
  Children = rows in `children` (nickname, avatar, grade, 4-digit PIN hashed on server).
  Parent zone: parental gate (multiplication task) + parent PIN (server-verified).
- AI: no LLM in v1. Rule-based "Scivo Brain" (stage 4). LLM-ready JSON contract for v2.
- Voice: flutter_tts + speech_to_text (stage 4), keypad fallback.
- Graphics: SVG by Illustrator role (lib/art). Avatars = recolored Scivo raven (6 colors).
- Font: Nunito (Quicksand has no Cyrillic).
- Notifications: in-app + email via Yandex SMTP (stage 5).
- Data minimization: parent email; child nickname, avatar, grade. Consent in parents.consent_at.
- Worlds v1: Forest of Counting, Bridge of Numbers, Cave of Multiplication, Clock Tower, Fractions of Chaos.
- Answers and rewards: server-side only (SQL RPC). Client never writes balances.

## Delivery pipeline
- PO pastes bundles into bundle/partN.txt (repo root). One part per chat message (size limit).
- Workflow unpacks, commits, builds Flutter Web, deploys to Pages.
- Bundles may NOT write into .github, .git or bundle folders.
- Never name our tests widget_test.dart (CI deletes that file).

## App structure (stage 2)
- State: flutter_riverpod 2.x.
- AuthGate: no session -> AuthScreen; no consent -> ConsentScreen; no parent PIN -> ParentPinSetupScreen;
  no children -> AddChildScreen(isFirst); no active child -> ProfilePickerScreen; else ChildShell.
- ChildShell: onboarding (once, +20 mana) -> daily checkin (+5 mana, streak) -> tabs Games / Wishlist / Profile.
- Client selects explicit columns on parents/children (column-level grants).

## Stages
0 Accounts & checks — DONE
1 DB & security — DONE
2 App skeleton (parts 2–5) — IN PROGRESS
3 Quest engine + 5 worlds + mechanics
4 Scivo Brain + voice
5 Parent dashboard, wishlist, limits, email
6 QA & polish, PWA icons
