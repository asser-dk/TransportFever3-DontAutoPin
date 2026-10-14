# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

TF3 GUI mod (modId `fenris_dont_auto_pin_1`): a `react-replacement-config` wraps `builtin.Window` so moving
an unpinned window no longer pins it.

## Behaviour constraints

- Only alter windows with `props.pinnable == true`. Windows without a pin button (e.g. the music player)
  rely on move-to-pin as their only way to pin.
- Every missing internal (`_react.originalRecipeFn`, the original `builtin.Window`, unexpected prop
  types) must fall back to the game's unchanged behaviour with a `log.warning`, never an error.

## Checks

- Type check from the repo root:
  `~/.luarocks/bin/tl check src/content/gui/fenris_dont_auto_pin/dont_auto_pin.script.tl`. The `tf3`
  plugin's hook also runs it, and schema validation of the mod's JSON files, after every edit.
- `tlconfig.lua` and `all_def.tl` are copies of the workspace (`..`) masters; keep them in sync.
- No automated tests. Verification is in-game by the user; afterwards grep the game log for
  `fenris_dont_auto_pin` (expect `builtin.Window replaced`, no warnings).
- After adding, removing or renaming files under `src/content/`, run `/tf3:stage-mod` to regenerate
  `src/_content.json`.
- `APPLIED_WORKAROUNDS.md` lists the undocumented game internals the mod relies on. Add an entry (with its
  fallback and in-game re-test) when introducing one; after a game update, have the user re-test every entry.

## Releases

- Commit straight to `main`; no feature branches.
- Each published update: bump `revision` in `src/mod.json` and add a changelog entry to the
  `description` in `src/_metadata/modinfo.json`.
