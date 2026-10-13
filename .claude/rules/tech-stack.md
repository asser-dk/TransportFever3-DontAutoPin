# Tech stack

Update this file when the stack changes.

| Component | Version / detail |
|---|---|
| Transport Fever 3 | Steam app 3493540; type defs from the install's `api/tealdef/` and `base/tealdef/` |
| Teal | `tl` 0.24.8 (`~/.luarocks/bin/tl`); scripts are `.tl`, Lua 5.2 semantics at runtime |
| Teal config | `tlconfig.lua` + `all_def.tl` in the repo root, copied from the workspace (`..`) |
| GUI | TF3 React-style Lua GUI (`::/gui/main/react.lua`, `builtin.lua`); hooked via `react-replacement-config` |
| teal-language-server | 0.2.1, connected by the `tf3` plugin; reads the repo's `tlconfig.lua` |
| JSON validation | `npx ajv-cli@5` against `~/Documents/documentation/references/transport-fever-3/schemas/` |
| Claude Code | `tf3` plugin (local `transport-fever-3-modding` marketplace, `..`): skills and the edit-check hook |
| VCS | Git |
