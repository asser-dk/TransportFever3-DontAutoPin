# Manual tests

Last-resort manual checks for what the automated tests (`tests/unit/`, `tests/ingame/`) can't observe,
such as on-screen appearance or how a tool feels. Each one costs a manual run before every upload and
after every game update, so keep the list as short as possible; an empty list is fine. Hard cap: 10.

Run all of them before each upload and after each game update; after a change, run the ones that cover
it.

| ID | Test | Covers | Last passed |
|---|---|---|---|
| V1 | Dragging a window doesn't pin it | Move-to-pin suppression; both `APPLIED_WORKAROUNDS.md` entries | 2026-10-25, revision 2 |

## V1. Dragging a window doesn't pin it

Purpose: Verify that dragging an unpinned window no longer pins it, while the pin button still works.

Covers: move-to-pin suppression for windows with a pin button; both `APPLIED_WORKAROUNDS.md` entries.

Why manual: a window drag happens in the engine's GUI; no API simulates it. In-game suites can't
check the game's side either: the console's Lua state has no access to React's recipes or window props.

Setup: any save with at least three vehicles or lines of the same kind, mouse input (not gamepad),
loaded with the mod enabled. Vehicle and line windows are the ones with a pin button. Open one of
them and pin it with its pin button, for comparison.

1. **Drag a vehicle or line window.** Click another vehicle or line; drag its window by the title bar
   for a few seconds without pinning it, then drag the pinned window from the setup the same way.
   Expected: The pin icon stays off. Dragging is as smooth as dragging the pinned window, and the
   window doesn't replay its opening animation.
   Log: `fenris_dont_auto_pin: builtin\.Window replaced`
2. **Click another vehicle or line.** With the window from step 1 still unpinned (pin icon off), click
   a third vehicle or line.
   Expected: The step 1 window is replaced by the new one (it was not pinned); the pinned window from
   the setup stays open.
3. **Pin and drag.** Pin the new window with its pin button, drag it, then click any other vehicle or
   line.
   Expected: The pinned window stays open and pinned.

<!--
## V2. <What the player does and what they should see>

Purpose: <one sentence: what the test verifies>

Covers: <feature or APPLIED_WORKAROUNDS.md entry>

Why manual: <why neither a unit test nor an in-game test can check this>

Setup: <save, map, era or game state needed; or "as V<n>">

1. **<Short title>.** <action>
   Expected: <what the user should see>
2. **<Short title>.** <action>
   Log: `<regex matched against the mod's game log lines; checked automatically>`
-->
