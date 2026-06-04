# Phase 5 Touch Provider — Repo Bootstrap Packet

Date: 2026-05-23

This note defines the **repo-bootstrap packet** for the future dedicated touch spatial provider lane.

It is intentionally a durable planning/execution packet, **not** implementation.

## Bootstrap summary

**Recommended repo name:** `aerobeat-spatial-ui-touch`

**Bootstrap truth:** start this repo as a narrow concrete spatial-provider package that mirrors the current post-Phase-3 mouse-lane shape, but for touch only.

That means:

- `aerobeat-input-core` remains the canonical owner of the UI interaction contract and `HybridSubViewportInputAdapter`
- `aerobeat-spatial-ui-core` remains the shared helper-layer owner for projected-data shaping, rect-target resolution, surface descriptors, and shared hover/capture helpers
- `aerobeat-spatial-ui-touch` should own only the reusable **touch lifecycle/runtime lane** for projected spatial UI
- `aerobeat-ui-kit-community` should remain the proof-host owner of world-ray acquisition, authored proof-scene composition, and downstream installed-addon verification

The first truthful bootstrap should therefore create a repo that is structurally ready to receive the extracted touch runtime slice **without** reopening ownership questions about contract semantics, helper ownership, or consumer proof-host seams.

## Recommended repo shape

The intended initial repo shape should match the already-audited family pattern used by `aerobeat-template-spatial-ui` and `aerobeat-spatial-ui-mouse`.

```text
<repo-root>/
  README.md
  LICENSE.md
  plugin.cfg
  .gitignore
  .github/workflows/
    cla.yml
    gut_ci.yml
  docs/
    phase-1-boundary-freeze.md
    phase-2-first-touch-provider-extraction.md   # may begin as a stub if extraction has not landed yet
  src/
    providers/
      touch/
        aero_spatial_ui_touch_provider.gd
        aero_spatial_ui_touch_provider_config.gd
        aero_spatial_ui_touch_runtime_boundary.gd
        aero_spatial_ui_touch_manifest.gd
  .testbed/
    project.godot
    addons.jsonc
    tests/
      test_example.gd
      test_touch_provider_press_release_semantics.gd
      test_touch_provider_drag_semantics.gd
      test_touch_provider_cancel_and_continuity.gd
      test_touch_provider_runtime_state.gd
      test_touch_provider_dependency_boundary.gd
    scripts/
      validate_installed_addon_paths.gd          # add once installed-addon proof becomes active
```

## Minimum package/runtime boundary files

These files should exist at bootstrap, even if some remain intentionally inert until the first extraction implementation lands.

### Required package identity files

1. `README.md`
   - truthfully describe the repo as the touch-driven spatial UI provider lane
   - state dependency truth against `aerobeat-input-core` and `aerobeat-spatial-ui-core`
   - describe GodotEnv workbench flow via `.testbed/`

2. `plugin.cfg`
   - package identity only
   - recommended values:
     - `name="AeroBeat Spatial UI Touch"`
     - description naming this as the touch-driven spatial UI provider addon for AeroBeat

3. `LICENSE.md`
   - match the current MPL 2.0 family convention

### Required runtime boundary files

1. `src/providers/touch/aero_spatial_ui_touch_provider.gd`
   - concrete provider-lane runtime entrypoint
   - initial responsibility: own reusable touch pointer lifecycle/runtime semantics only

2. `src/providers/touch/aero_spatial_ui_touch_provider_config.gd`
   - public provider config boundary
   - minimum boundary fields expected for slice 1:
     - `host_surface`
     - `target_resolution`
     - touch pointer-id policy/prefix
     - drag-threshold passthrough where needed for adapter composition
     - optional runtime/probe toggles only if they do not expand ownership

3. `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd`
   - explicit non-goals and dependency truth
   - should mirror the mouse lane’s `describe_non_goals()`, `describe_dependencies()`, and extracted-slice summary pattern

4. `src/providers/touch/aero_spatial_ui_touch_manifest.gd`
   - inert manifest/ownership summary for downstream truth checks
   - should declare:
     - provider lane = `touch`
     - contract owner package = `aerobeat-input-core`
     - shared helper owner package = `aerobeat-spatial-ui-core`
     - owns concrete provider behavior = `true`
     - owns contract definition = `false`
     - owns native 2D bridge = `false`
     - owns shared helper layer = `false`
     - owns proof-host world-hit acquisition = `false`

## Minimum docs/tests/manifest scaffolding

## Docs scaffolding

1. `docs/phase-1-boundary-freeze.md`
   - required at bootstrap
   - must explicitly freeze these boundaries:
     - touch repo owns touch provider lifecycle/runtime behavior
     - touch repo does not own canonical contract semantics
     - touch repo does not own native 2D bridge logic
     - touch repo does not own shared projection/resolver/helper duplication
     - touch repo does not own proof-host raycast/world-hit acquisition

2. `docs/phase-2-first-touch-provider-extraction.md`
   - should exist by the time the first extraction implementation starts
   - may begin as a stub at bootstrap if desired
   - should record the exact host-local seams being moved out of `aerobeat-ui-kit-community`

## Manifest scaffolding

1. `.testbed/addons.jsonc`
   - canonical dev/test dependency manifest
   - required baseline dependencies:
     - `aerobeat-input-core`
     - `aerobeat-spatial-ui-core`
     - `aerobeat-vendor-godot-unit-test`
   - no direct dependency on `aerobeat-ui-kit-community`
   - no local `file:` polyrepo shortcuts; use the existing git/SSH convention

## Test scaffolding

The repo should start with both a smoke placeholder and the real first-slice semantic test targets named up front.

1. `.testbed/tests/test_example.gd`
   - minimal smoke placeholder, consistent with the current repo family

2. `.testbed/tests/test_touch_provider_press_release_semantics.gd`
   - press begin / press end owner truth

3. `.testbed/tests/test_touch_provider_drag_semantics.gd`
   - threshold handling, `drag_begin`, `drag_move`, `drag_end`

4. `.testbed/tests/test_touch_provider_cancel_and_continuity.gd`
   - release-outside continuation vs cancel semantics

5. `.testbed/tests/test_touch_provider_runtime_state.gd`
   - owner-path continuity, pointer-state clearing, provider diagnostics surface

6. `.testbed/tests/test_touch_provider_dependency_boundary.gd`
   - guardrail test that proves the repo still points at:
     - `aerobeat-input-core` as contract owner
     - `aerobeat-spatial-ui-core` as shared helper owner
   - and does not claim native 2D bridge or proof-host world-hit ownership

## Dependency and ownership truth table

| Concern | Owning repo | Future touch repo responsibility |
| --- | --- | --- |
| Canonical interaction event shape, taxonomy, bus semantics | `aerobeat-input-core` | Consume only; do not redefine |
| `HybridSubViewportInputAdapter` | `aerobeat-input-core` | Compose through it; do not fork semantics |
| Native 2D bridge / `screen_2d` normalization | `aerobeat-input-core` | Out of scope |
| Verification-status truth for `screen_touch` + `hybrid_3d_gui` | `aerobeat-input-core` | Preserve `unverified`; do not silently promote |
| Surface descriptors / projected-data helpers | `aerobeat-spatial-ui-core` | Consume only |
| Rect target resolution | `aerobeat-spatial-ui-core` | Consume only |
| Shared hover/capture helper policy | `aerobeat-spatial-ui-core` | Reuse where applicable; do not re-fork |
| Touch pointer runtime state | `aerobeat-spatial-ui-touch` | Own |
| Touch owner continuity across press/drag/release | `aerobeat-spatial-ui-touch` | Own |
| Off-surface release continuation using prior projected data | `aerobeat-spatial-ui-touch` | Own |
| Explicit canceled-touch publication policy | `aerobeat-spatial-ui-touch` | Own |
| Provider-local runtime/describe diagnostics for touch | `aerobeat-spatial-ui-touch` | Own |
| Camera ray creation and physics hit acquisition | `aerobeat-ui-kit-community` | Do not own |
| `PanelInputSurface` scene assumptions | `aerobeat-ui-kit-community` | Do not own |
| Proof-scene composition/debug UI | `aerobeat-ui-kit-community` | Do not own |
| Downstream installed-addon proof | `aerobeat-ui-kit-community` | Consumer verifies packaged provider use |

## Exact bootstrap expectations for the first implementation lane

The next implementation lane should treat the following as **already decided** at bootstrap.

### 1. Repo identity is concrete-provider, not template, not helper, not contract

The repo must start life as a real `aerobeat-spatial-ui-*` provider package, specifically the touch lane.
It is not a second template repo, not an extension of `aerobeat-spatial-ui-core`, and not a place to move the UI interaction contract.

### 2. The first slice moves touch lifecycle/runtime semantics only

The first implementation slice should extract from `aerobeat-ui-kit-community` only the reusable touch semantics concentrated around:

- active touch pointer state
- owner target continuity
- release-outside continuation from prior projected state
- canceled-touch publication policy
- drag lifecycle publication ordering
- provider-readable runtime diagnostics

It should **not** move:

- camera/world ray acquisition
- physics raycast setup
- proof-scene `PanelInputSurface` assumptions
- authored proof-scene composition
- contract semantics currently owned by `aerobeat-input-core`

### 3. The runtime must compose through existing owners

The touch provider should compose through:

- `HybridSubViewportInputAdapter` from `aerobeat-input-core`
- packaged projection/resolver/helper seams from `aerobeat-spatial-ui-core`

The touch repo must not solve extraction by copying those owners locally.

### 4. The initial test packet is semantic, not superficial

The first implementation lane should consider the repo bootstrap incomplete unless the named tests are ready to prove:

- `press_end.target_path` remains the original press owner
- hover truth and press/drag owner truth remain separate
- `drag_end` publishes before `press_end`
- ordinary release-outside remains `press_end`, not `cancel`, when continuity exists
- explicit canceled touch publishes `cancel`
- `pointer_id` policy is stable for `touch_<index>`
- `source_variant == "screen_touch"`
- `surface_type == "hybrid_3d_gui"`
- `verification_status == "unverified"`

### 5. Consumer proof remains mandatory downstream

Even after the new touch repo exists, `aerobeat-ui-kit-community` still needs a downstream installed-addon proof pass comparable to the packaged resolver/mouse lane proof.

The touch repo bootstrap is therefore **not** permission to delete consumer verification responsibility.

## Recommended bootstrap contents for `.testbed/addons.jsonc`

The initial manifest should be the touch-lane equivalent of the existing template/mouse repo baselines.

Required packages:

- `aerobeat-input-core`
- `aerobeat-spatial-ui-core`
- `aerobeat-vendor-godot-unit-test`

Recommended truth:

- use SSH Git URLs
- consume package roots from `subfolder: "/"`
- pin `aerobeat-spatial-ui-core` from `main` unless a tagged baseline exists at creation time
- pin `aerobeat-input-core` to the approved contract-supporting baseline used by the family at creation time

## Bootstrap pass/fail rules

A future repo creation pass should be considered **PASS** only if all of these are true:

- the repo name and docs clearly frame it as the touch provider lane
- runtime files exist under `src/providers/touch/`
- dependency truth points to `aerobeat-input-core` and `aerobeat-spatial-ui-core`
- docs freeze the ownership boundary explicitly
- tests are scaffolded around semantic parity, not generic smoke only
- nothing in bootstrap claims contract ownership, native 2D bridge ownership, or proof-host world-hit ownership

A future repo creation pass should be considered **FAIL** if any of these happen:

- the repo claims or implies ownership of the canonical interaction contract
- the repo duplicates projection/resolver/helper ownership already assigned to `aerobeat-spatial-ui-core`
- the repo assumes camera raycast/world-hit acquisition belongs in the provider package
- the repo omits the runtime-boundary/manifest guardrails and leaves ownership implicit
- the repo starts with only generic placeholder tests and no semantic packet for touch parity

## Practical first commit expectation for the future repo

The first truthful bootstrap commit for `aerobeat-spatial-ui-touch` should do only this:

1. establish repo/package identity
2. establish dependency manifest
3. establish runtime/config/manifest boundary files
4. establish boundary docs
5. establish named test scaffolding for touch semantics

It should **not yet** claim the touch provider extraction is implemented.

## Files inspected for this packet

- `docs/notes/2026-05-23-phase-5-touch-provider-readiness.md`
- `docs/notes/2026-05-23-phase-5-touch-provider-first-extraction-packet.md`
- `docs/notes/2026-05-23-phase-5-touch-provider-parity-test-packet.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/README.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/docs/phase-1-boundary-freeze.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/plugin.cfg`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/.testbed/addons.jsonc`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-template-spatial-ui/src/template/aero_spatial_ui_adapter_template_manifest.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/README.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/plugin.cfg`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/.testbed/addons.jsonc`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_runtime_boundary.gd`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-spatial-ui-core/README.md`
- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-core/docs/ui-interaction-contract-v1.md`

## Files touched for this packet

- `docs/notes/2026-05-23-phase-5-touch-provider-bootstrap-packet.md`

## Bottom line

The future touch lane does **not** need more ownership debate before repo creation.

The durable bootstrap decision is:

- open `aerobeat-spatial-ui-touch`
- mirror the mouse/template repo family shape
- bootstrap `src/providers/touch/` boundary files plus docs/tests/manifests
- pin dependency truth to `aerobeat-input-core` and `aerobeat-spatial-ui-core`
- keep world-hit acquisition in `aerobeat-ui-kit-community`
- treat semantic parity and installed-addon consumer proof as mandatory follow-through for slice 1

That is the minimum repo-bootstrap packet that lets the next implementation lane start cleanly without reopening repo-shape or ownership questions.
