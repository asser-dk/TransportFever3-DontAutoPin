# Validation tests

Last-resort manual checks for what the automated tests (`tests/unit/`, `tests/ingame/`) can't observe,
such as on-screen appearance or how a tool feels. Each one costs a manual run before every upload and
after every game update, so keep the list as short as possible; an empty list is fine. Hard cap: 10.

Run all of them before each upload and after each game update; after a change, run the ones that cover
it.

| ID | Test | Covers | Last passed |
|---|---|---|---|
| V1 | Dragging a window doesn't pin it | Move-to-pin suppression; both `APPLIED_WORKAROUNDS.md` entries | 2026-10-24, revision 1 |

## V1. Dragging a window doesn't pin it

Covers: move-to-pin suppression for windows with a pin button; both `APPLIED_WORKAROUNDS.md` entries.

Why manual: a window drag happens in the engine's GUI; no API simulates it. In-game suites can't
check the game's side either: the console's Lua state has no access to React's recipes or window props.

Setup: any save with at least two towns, mouse input (not gamepad).

1. Click a town; drag its window by the title bar.
2. Click another town.
3. Pin the new window with its pin button, drag it, then click a third entity.
4. Grep the game log for `fenris_dont_auto_pin`.

Expected:

1. The pin icon stays off.
2. The first town's window is replaced by the second's (it was not pinned).
3. The pinned window stays open and pinned.
4. `builtin.Window replaced`, no warnings.

<!--
## V1. <What the player does and what they should see>

Covers: <feature or APPLIED_WORKAROUNDS.md entry>

Why manual: <why neither a unit test nor an in-game test can check this>

Setup: <save, map, era or game state needed>

1. <step>
2. <step>

Expected: <what the user should see; one observable result per step where it matters>
-->
