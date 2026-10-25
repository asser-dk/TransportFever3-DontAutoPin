# Applied workarounds

Undocumented game internals this mod relies on. They can break with any game update: re-test each one
in-game after every game update, before the next release. Add an entry whenever the mod starts relying on
another one.

- `_react.originalRecipeFn` (internal table in `::/gui/main/react.lua`), used to call the original
  `builtin.Window`. Fallback: unchanged auto-pinning, with a `log.warning`. Re-test: validation test V1
  (`docs/validation-tests.md`). Watch: `base/content/gui.zip/gui/main/react.lua`.
- `builtin.Window`'s `onMovedChange` prop (missing from the typedef) and the per-window auto-pin in
  `gui/entity_window/view_manager.tl`. The mod also assumes the game calls `onMovedChange` about once
  per frame while a window is dragged, well under `DRAG_GAP` (0.25 s) apart: if the calls grew further
  apart, every call would count as a new drag and dragging would get choppy again; if they stopped
  repeating, nothing would change. Re-test: as above. Watch:
  `base/content/gui.zip/gui/entity_window/view_manager.tl`.
