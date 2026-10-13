<img src="art/cover.svg" alt="Don't auto-pin moved windows" width="100%">

# Don't auto-pin moved windows

A Transport Fever 3 mod. Stop windows from being pinned when you (accidentally) move them around.
Only windows you pin manually stay pinned.

- Affects only windows that have a pin button. Windows without one (e.g. the music player) keep
  the game's move-to-pin behaviour, since it's their only way to pin.
- Cosmetic GUI mod: safe to add to or remove from existing saves.

## Development

The shippable mod lives in `src/`; scripts are written in [Teal](https://github.com/teal-language/tl).
Type check:

```bash
tl check src/content/gui/fenris_dont_auto_pin/dont_auto_pin.script.tl
```

The cover's source is `art/cover.svg`. Render it to the in-game cover, `src/_metadata/0.png`, with
`scripts/render_cover.sh` (needs `rsvg-convert` from librsvg).
