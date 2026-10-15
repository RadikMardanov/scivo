# SCIVO — PROJECT PASSPORT (v1.3)

## Decisions (approved by PO)
- Web link (PWA) via GitHub Pages: https://radikmardanov.github.io/scivo/ . Families in Russia, kids 7–10 (grades 1–4).
- Family model: parent = Supabase Auth user (email+password). Children = rows in `children` (nickname, avatar, grade, PIN hashed).
- Parent zone: parental gate (multiplication) + parent PIN (server-verified, lockout).
- No LLM in v1: rule-based "Scivo Brain" (stage 4), LLM-ready JSON. Voice: flutter_tts + speech_to_text (stage 4).
- Graphics: SVG (lib/art), 6 raven avatar colors. Font: Nunito.
- Answers/rewards server-side only (SQL RPC). Client never writes balances.
- Email notifications: Yandex SMTP (stage 5). Data minimization + consent (parents.consent_at).

## Working rules (token economy)
- Every reply starts with "Passport vX → stage/status", then only new content.
- Bundles: one part per message, bundle/partN.txt in repo root, markers "=== FILE: path ===" / "=== END FILE ===".
- New chat: paste this file — it is enough to continue.
- Never write into .github/.git/bundle via bundles. Never name tests widget_test.dart.

## Code map (stage 2)
- DB (migration 001): app_status, parents(has_pin, consent_at), children, child_progress(feathers, feathers_frozen, mana, xp, streak_days, streak_freezes, last_active_date, feathers_today), wishlist_items(title, feather_cost, emoji, is_active), reward_requests(status pending/delivered/declined), notifications.
- RPC: give_consent, set_parent_pin, verify_parent_pin, create_child, verify_child_pin, child_checkin(+5 mana, Moscow day), complete_onboarding(+20 once), is_my_child.
- Grants: client selects explicit columns on parents/children; progress/requests read-only.
- lib/core: env_config, theme/app_theme (AppColors: purple, purpleLight, gold, flame, night, nightCard, textDark, success, danger), errors (AppException, friendlyError), legal/consent_text.
- lib/models/family_models: ParentProfile, ChildProfile(copyWith onboardingDone), ChildProgress(availableFeathers), CheckinResult, PinCheckResult, WishlistItem.
- lib/services/supabase_service: auth, parent PIN, children, progress, checkin, onboarding, wishlist.
- lib/providers/app_providers: serviceProvider, authSessionProvider, parentProvider, childrenProvider, activeChildProvider, progressProvider(childId), wishlistProvider.
- lib/widgets: common (MagicBackground, MagicScaffold, MagicCard, SpeechBubble, ScivoSays, CurrencyChip, SplashView, ErrorView, magicInput, showScivoDialog, showSnack, pluralRu), scivo_raven, pin_pad. lib/art/raven_art.
- lib/data/worlds: WorldInfo + kWorlds (forest, bridge, cave, clock, fractions).
- Screens: auth/(auth_gate, auth_screen, consent_screen), parent/(parent_pin_setup, parent_gate, parent_zone), family/(add_child, profile_picker + ChildPinScreen), onboarding/onboarding_screen, home/(child_shell, world_map_tab, wishlist_tab, profile_tab).

## Stages
0 Accounts — DONE | 1 DB & security — DONE | 2 App skeleton — IN REVIEW (parts 2–6)
3 Quest engine + 5 worlds + mechanics | 4 Scivo Brain + voice | 5 Parent dashboard, wishlist exchange, limits, email | 6 QA & polish, PWA icons
