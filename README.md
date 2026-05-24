# aerobeat-ui-kit-community

Shared AeroBeat community UI kit addon for reusable visual components and presentation patterns built on top of the `aerobeat-ui-core` contract.

This repo is the default community-facing visual layer for AeroBeat v1 UI work. Current priority is desktop/PC shell support. Mobile, web, and XR shells are future/deprioritized surfaces and should not be described here as equal present-tense targets.

Gameplay input ownership lives outside this repo. `aerobeat-ui-kit-community` is for shared UI/menu visuals and interaction presentation, while gameplay-facing input contracts remain the responsibility of the dedicated input/gameplay layers.

## Spatial provider trust boundary

For the spatial UI family, this repo is the **downstream proof host**, not the first semantic truth source for provider behavior.

- Provider repos (`aerobeat-spatial-ui-mouse`, `aerobeat-spatial-ui-touch`, `aerobeat-spatial-ui-xr`) must prove their own hover / press / drag / release / cancel semantics and provider-owned runtime truth in provider-owned harnesses and repo-local tests.
- `aerobeat-ui-kit-community` proves that those packaged providers compose correctly into a downstream host with contract-aware UI primitives.
- Proof-scene composition, world-hit / rig / camera wiring, and installed-addon consumer proof can remain here when they are genuinely host-local.
- Provider semantics, provider runtime state machines, canonical contract ownership, and shared spatial helper ownership should not drift back into this repo.

See `docs/notes/2026-05-24-ui-kit-community-provider-trust-boundary.md` for the durable repo-local trust-boundary note.

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

That restores the repo's UI-kit-focused dev/test manifest into `.testbed/addons/`. The hidden testbed may pin adjacent AeroBeat packages such as `aerobeat-input-core` and the `aerobeat-spatial-ui-*` family when this downstream proof host is validating packaged consumer composition against the current architecture boundary.

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
