# aerobeat-ui-kit-community

Shared AeroBeat community UI kit addon for reusable visual components and presentation patterns built on top of the `aerobeat-ui-core` contract.

This repo is the default community-facing visual layer for AeroBeat v1 UI work. Current priority is desktop/PC shell support. Mobile, web, and XR shells are future/deprioritized surfaces and should not be described here as equal present-tense targets.

Gameplay input ownership lives outside this repo. `aerobeat-ui-kit-community` is for shared UI/menu visuals and interaction presentation, while gameplay-facing input contracts remain the responsibility of the dedicated input/gameplay layers.

## Hidden testbed development flow

This repo keeps a hidden Godot testbed for addon validation and workbench testing.

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

That restores the repo's UI-kit-focused dev/test manifest into `.testbed/addons/`. `aerobeat-ui-core` is the only shared AeroBeat addon dependency declared here; adjacent core packages should only be added if this repo directly consumes them.

### Open the testbed

From the repo root:

```bash
godot --editor --path .testbed
```

### Validation notes

- `.testbed/addons.jsonc` is the only committed dev/test dependency contract.
- The hidden testbed manifest is intentionally scoped to shared UI-kit validation and must not pin unrelated gameplay/core foundations by default.
- `.testbed/tests` is the repo-local GUT suite location, and `.testbed/scenes` is reserved for manual/workbench scene content when this repo needs it.
- The current package shape is consumed from the repo root (`subfolder: "/"`) for downstream installs.
