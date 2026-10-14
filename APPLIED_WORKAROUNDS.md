# Applied workarounds

Undocumented game internals this mod relies on. They can break with any game update: re-test each one
in-game after every game update, before the next release. Add an entry whenever the mod starts relying on
another one.

- `_react.originalRecipeFn` (internal table in `::/gui/main/react.lua`), used to call the original
  `builtin.Window`. Fallback: unchanged auto-pinning, with a `log.warning`. Re-test: moving an unpinned
  entity window leaves it unpinned; the log shows `builtin.Window replaced`.
- `builtin.Window`'s `onMovedChange` prop (missing from the typedef) and the per-window auto-pin in
  `gui/entity_window/view_manager.tl`. Re-test: as above, and a pinned window stays pinned when moved.
