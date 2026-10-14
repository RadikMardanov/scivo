# SCIVO — PROJECT PASSPORT (v1.1)

## Decisions (approved by PO)
- Test format: Web link (PWA) via GitHub Pages: https://radikmardanov.github.io/scivo/
- Audience: families in Russia, children 7–10 (grades 1–4)
- Accounts: family model. Only parent has email/password (Supabase Auth).
  Children = rows in `children` (nickname, avatar, grade, 4-digit PIN hashed on server).
  Parent zone: parental gate (math task) + parent PIN (server-verified).
- AI: no LLM in v1. Rule-based "Scivo Brain" (error diagnostics + 3-level hints + phrase bank in DB). LLM-ready JSON contract for v2.
- Voice: flutter_tts (all Scivo lines), speech_to_text for answers, keypad fallback.
- Graphics: SVG by Illustrator role (lib/art), animations in Flutter.
- Notifications: in-app + email via Yandex SMTP (stage 5).
- Data minimization: parent email; child nickname, avatar, grade. Parent consent stored (parents.consent_at).
- Worlds v1: Forest of Counting, Bridge of Numbers, Cave of Multiplication, Clock Tower, Fractions of Chaos.
- Mechanics: keypad, voice, drag&drop, drawing/shading, puzzle, clock rotation, choice, boss battle.
- Answers and rewards: server-side only (SQL RPC). Client never writes balances.
- Economy: Feathers (no-hint success, bosses, daily cap), Mana (activity, streak, fixed errors), wishlist with feather freeze.

## Delivery pipeline
- PO pastes text bundles into bundle/partN.txt on GitHub web.
- Workflow .github/workflows/build.yml unpacks bundles, commits files, builds Flutter Web, deploys to Pages.
- Bundles may NOT write into .github, .git or bundle folders.
- flutter create runs in CI; never name our tests widget_test.dart (CI deletes that file).
- Secrets: SUPABASE_URL, SUPABASE_ANON_KEY in GitHub Actions secrets. Nothing secret in code or chat.

## Backend rules
- Migrations: supabase/migrations/NNN_name.sql, run by PO in SQL Editor.
- Column-level grants: client must select explicit columns (no select *) on parents/children.
- Day boundary for streaks: Europe/Moscow.

## Stages
0 Accounts & checks — DONE
1 DB & security (migration 001) — IN REVIEW
2 App skeleton + first link — IN PROGRESS (part1: pipeline check)
3 Quest engine + 5 worlds
4 Scivo Brain + voice
5 Parent dashboard, wishlist, email
6 QA & polish
=== END FILE ===
