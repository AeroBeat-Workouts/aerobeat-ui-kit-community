# aerobeat-ui-kit-community

Shared AeroBeat community UI kit addon for themed visual components built on top of the UI-core contract.

## GodotEnv development flow

This repo uses the AeroBeat Phase 1 GodotEnv package/foundation convention.

- Canonical dev/test manifest: `.testbed/addons.jsonc`
- Installed dev/test addons: `.testbed/addons/`
- GodotEnv cache: `.testbed/.addons/`
- Hidden workbench project: `.testbed/project.godot`

### Restore dev/test dependencies

From the repo root:

```bash
cd .testbed
godotenv addons install
```

That restores this repo's current Phase 1-era dev/test manifest into `.testbed/addons/`. The live lane model treats `aerobeat-ui-core` as the canonical shared dependency surface; the old `aerobeat-core` pin is transition-era bootstrap drift.

### Open the testbed

From the repo root:

```bash
godot --editor --path .testbed
```

### Validation notes

- `.testbed/addons.jsonc` is the only committed dev/test dependency contract.
- The current manifest still pins the transition-era `aerobeat-core` package key plus `aerobeat-ui-core` for the historical Phase 1 validation chain.
- Canonical shared dependency language for this repo is `aerobeat-ui-core`; add adjacent lane cores only when this UI kit actually consumes them.
- `.testbed/tests` is the repo-local GUT suite location, and `.testbed/scenes` is reserved for manual/workbench scene content when this repo needs it.
- The current package shape is consumed from the repo root (`subfolder: "/"`) for downstream installs. That repo-root package boundary is now explicit release contract state for this initial Phase 1 tag.
