# /add-game-module <game_id>

Goal: Add a new game module without duplicating shared UI.

Rules:
- New module under `lib/games/<game_id>/`
- Must implement `GameModule`
- Register it in `GameRegistry`

Deliverables:
- metadata + entry widget
- minimal playable stub
- unit tests for rule logic (if any)
- analyze/test passing

Commit message: "Add <game_id> module"
