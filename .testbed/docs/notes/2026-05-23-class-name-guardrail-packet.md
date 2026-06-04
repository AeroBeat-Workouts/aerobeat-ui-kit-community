# AeroBeat polyrepo `class_name` guardrail packet

_Date:_ 2026-05-23  
_Owning bead:_ `aerobeat-ui-kit-community-51mx`  
_Status:_ Research packet / execution-ready / no scanner implementation yet

## Purpose

Define the executable guardrail packet for a polyrepo-wide GDScript global `class_name` scanner across `/home/derrick/.openclaw/workspace/projects/aerobeat/`, with the **actual collision-risk model anchored to repo-root imported addon/runtime surfaces**.

This packet intentionally does **not** implement the scanner and does **not** rename any code yet. It exists to survive a fresh context and give the next implementation pass a concrete target.

---

## Scope boundary: what counts as real risk

### Primary concern: repo-root imported surfaces

For AeroBeat dependency imports, the primary collision surface is the **repo root content imported by GodotEnv / root assembly restore flows**, not the hidden workbench projects.

That means the scanner should prioritize GDScript files that live in imported/runtime-visible root surfaces such as:

- `src/**`
- `addons/**`
- `assets/**` when it contains `.gd`
- `scenes/**` when it contains `.gd`
- root-level runtime scripts such as `plugin.gd`
- other non-hidden repo-root `.gd` files that ship inside the imported addon/runtime package

### Lower-severity context: hidden workbench surfaces

Hidden workbench/testbed content is **not** the primary shipping risk:

- `/.testbed/**`
- `/.addons/**`
- other hidden dot-directories

Those surfaces still matter for diagnostics, but they should be reported as **non-shipping / lower-severity context** unless the same overlap also appears in repo-root imported/runtime surfaces.

### Practical rule

If a duplicate only exists in hidden workbench paths, it is **not** a blocker for the shipping/imported guardrail.

If a duplicate exists in root imported/runtime surfaces, it is part of the real guardrail.

---

## Scanner surface model

The scanner should emit findings against explicit surface kinds.

### Surface kinds

#### `root_runtime`
Imported/shipping/runtime-visible GDScript in a repo root package or runnable root project.

Examples:

- `aerobeat-input-camera-tracking/src/*.gd`
- `aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/*.gd`
- `aerobeat-input-core/src/*.gd`
- `aerobeat-tool-content-authoring/addons/aerobeat-content-core/**/*.gd`

#### `root_nonruntime`
Repo-root GDScript that is imported with the package/project checkout but is not part of the intended runtime surface.

Examples:

- `tests/**`
- `test/**`
- `scratch/**`
- `examples/**`

These still deserve visibility because `class_name` is global, but they are lower severity than `root_runtime`.

#### `hidden_testbed`
Hidden workbench/testbed-only paths.

Examples:

- `.testbed/**`
- `.addons/**`

These are context-only unless the same class family also leaks into `root_runtime`.

---

## What repos / project surfaces the scanner must inspect

### Tier 1 — must scan for blocking risk

Every git repo under:

- `/home/derrick/.openclaw/workspace/projects/aerobeat/*`

Within each repo, scan all non-hidden `*.gd` files, then classify them by surface kind.

At minimum, the scanner must inspect:

- repo root `src/**`
- repo root `addons/**`
- repo root runtime `.gd` files outside hidden folders
- committed root package copies embedded inside consumer repos

### Tier 2 — report, but do not block by default

- hidden `.testbed/**`
- hidden `.addons/**`

These should be included only when the scanner runs in a full/context mode, or emitted as informational findings separate from shipping failures.

### Why this matters

AeroBeat has real producer/consumer embedded-copy patterns where a source repo owns a class, while a consumer repo also contains an imported addon copy of that same class under `addons/<addon-name>/...`.

That shape is the immediate migration hazard.

---

## Inventory and reporting contract

The scanner should build a normalized inventory row per `class_name` declaration.

### Required fields per row

- `class_name`
- `absolute_path`
- `repo_root`
- `repo_name`
- `relative_path`
- `surface_kind` (`root_runtime`, `root_nonruntime`, `hidden_testbed`)
- `container_kind`
  - `source_repo_root`
  - `embedded_addon_copy`
  - `repo_local_test_or_example`
  - `hidden_workbench`
- `addon_key` when path is under `addons/<key>/...`
- `line_number`
- `nearest_plugin_cfg` if present
- `git_remote` if cheaply available

### Collision report shape

For each duplicated `class_name`, the scanner should report:

- the class name
- total declaration count
- grouped declarations by repo
- exact file paths
- ownership/container summary
- severity
- whether the overlap is allowed, known, or blocking
- remediation hint when severity is `warn` or `block`

### Ownership interpretation

A file at:

- `aerobeat-input-camera-tracking/src/providers/mediapipe_provider.gd`

is an **owner/source repo declaration**.

A file at:

- `aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd`

is an **embedded consumer copy** of an imported addon runtime surface.

The scanner must preserve that distinction in output.

---

## Severity model

Use shipping-focused severities.

### `blocker`
A collision in `root_runtime` surfaces that can reasonably coexist in the same runnable import/runtime boundary and would make global `class_name` resolution unsafe.

Typical cases:

- two different root-runtime packages declare the same `class_name`
- a runnable repo root contains two colliding imported addon trees at once
- a migration introduces both the old embedded copy and the new source/import path in the same root runtime

This should fail CI.

### `warn_embedded_overlap`
A duplicate exists between:

- an owning source repo root, and
- a consumer repo's embedded/imported root addon copy

but the overlap is currently explainable as a **known producer/consumer copy** rather than a same-project double-import.

This is the immediate AeroBeat input-family shape.

It should not be treated as harmless; it is a **migration hazard** and should be visible in CI/local reports. It becomes `blocker` the moment a runnable root begins importing both sides into the same runtime boundary.

### `warn_root_nonruntime`
The duplicate exists in repo-root imported surfaces, but only in root non-runtime locations such as `tests/`, `scratch/`, or `examples/`.

This should be visible but non-blocking by default.

### `info_hidden_testbed`
The duplicate exists only in hidden `.testbed` / hidden workbench surfaces.

This should not fail shipping CI by default.

---

## Allowed / known overlaps vs blocking collisions

### Allowed / known overlap

An overlap can be classified as **known** when all of the following are true:

1. One side is clearly the source/owner repo root.
2. The other side is a consumer's embedded imported copy under repo-root `addons/<addon-key>/...`.
3. The current runnable/imported root does **not** simultaneously import both competing identities into the same Godot runtime boundary.
4. The scanner output names the overlap explicitly so future migrations cannot accidentally normalize it away.

Known overlap does **not** mean good. It means **present, understood, and not yet an active same-runtime double-import**.

### Blocking collision

Treat the overlap as blocking when any of these become true:

- the same runnable/imported root contains both colliding package identities
- a repo manifest or restore flow would materialize both sides into one runtime
- two different source repos ship the same `class_name` in root-runtime surfaces without a deliberate compatibility story
- a root-runtime overlap is no longer just owner-vs-embedded-copy, but genuine peer-vs-peer collision

### Hidden-only overlap

If the overlap exists only under `.testbed/**` or other hidden workbench surfaces, classify it as `info_hidden_testbed`, not blocking.

---

## Current evidence: immediate root-runtime overlap in the input family

The immediate producer/consumer overlap risk is **real in repo-root imported/runtime surfaces**.

### Source repo side

Owner/source repo:

- `aerobeat-input-camera-tracking`

Root-runtime declarations live under:

- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/**`

### Embedded consumer side

Consumer repo with imported root addon copy:

- `aerobeat-assembly-community`

Embedded root-runtime declarations live under:

- `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/**`

### Exact overlapping class family found in root-runtime surfaces

The scanner packet should treat the following as the immediate known embedded-overlap set:

- `AutoStartManager`
- `DesktopSidecarLauncher`
- `DesktopSidecarRuntime`
- `LandmarkSmoother`
- `MediaPipeCameraView`
- `MediaPipeConfig`
- `MediaPipeInputWithCamera`
- `MediaPipeProcess`
- `MediaPipeProvider`
- `MediaPipeServer`
- `PoseDetectorSubstrate`
- `PoseLandmarkIds`
- `PoseMetrics`
- `StrategyMediaPipe`

### Exact path evidence

| Class | Owner/source path | Embedded consumer path |
| --- | --- | --- |
| `AutoStartManager` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/autostart_manager.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/autostart_manager.gd` |
| `DesktopSidecarLauncher` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/process/desktop_sidecar_launcher.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/process/desktop_sidecar_launcher.gd` |
| `DesktopSidecarRuntime` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/runtime/desktop_sidecar_runtime.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/runtime/desktop_sidecar_runtime.gd` |
| `LandmarkSmoother` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/detectors/landmark_smoother.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/detectors/landmark_smoother.gd` |
| `MediaPipeCameraView` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/camera_view.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/camera_view.gd` |
| `MediaPipeConfig` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/config/mediapipe_config.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/config/mediapipe_config.gd` |
| `MediaPipeInputWithCamera` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/mediapipe_input_with_camera.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/mediapipe_input_with_camera.gd` |
| `MediaPipeProcess` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/process/mediapipe_process.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/process/mediapipe_process.gd` |
| `MediaPipeProvider` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/providers/mediapipe_provider.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/providers/mediapipe_provider.gd` |
| `MediaPipeServer` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/server/mediapipe_server.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/server/mediapipe_server.gd` |
| `PoseDetectorSubstrate` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/detectors/pose_detector_substrate.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/detectors/pose_detector_substrate.gd` |
| `PoseLandmarkIds` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/detectors/pose_landmark_ids.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/detectors/pose_landmark_ids.gd` |
| `PoseMetrics` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/detectors/pose_metrics.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/detectors/pose_metrics.gd` |
| `StrategyMediaPipe` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-input-camera-tracking/src/strategies/strategy_mediapipe.gd` | `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/strategies/strategy_mediapipe.gd` |

### What this means

Today this is best modeled as:

- `warn_embedded_overlap` at workspace level
- escalates to `blocker` if any runnable/imported root begins materializing both package identities in one runtime boundary

The overlap is **not** a hidden `.testbed` issue. It is present in shipping/imported root surfaces.

---

## Other root-runtime overlap shapes the scanner should catch

These are not the immediate highest-risk family, but they prove the scanner must understand embedded copies in consumer roots:

- `aerobeat-input-core/src/**` vs `aerobeat-assembly-community/addons/aerobeat-input-core/src/**`
- `aerobeat-input-core/src/**` vs `aerobeat-template-assembly/addons/aerobeat-input-core/src/**`
- `aerobeat-content-core/**` vs `aerobeat-tool-content-authoring/addons/aerobeat-content-core/**`

Those should usually classify as known embedded overlaps unless a same-runtime double-import condition exists.

---

## CI and local workflow entrypoints

The scanner should run in more than one place, but not every mode needs the same severity policy.

### 1) Local workspace-wide preflight — required

Primary developer/orchestrator command:

- run from `/home/derrick/.openclaw/workspace/projects/aerobeat/`
- scans all AeroBeat repos in workspace
- defaults to shipping/root-import mode
- optional `--include-hidden-testbeds` mode for diagnostic passes

This is the only mode that can see polyrepo source-vs-consumer overlap across sibling repos.

### 2) `aerobeat-assembly-community` CI — required

Hook it into the existing root restore flow **after**:

- `./scripts/restore-addons.sh`

and **before** Godot import/test.

Why here:

- this repo is a real runnable root project
- it materializes imported addon trees under root `addons/`
- it is the clearest place to fail when a root-runtime collision becomes active

### 3) Other runnable/importing root repos with committed `addons/` content — recommended

Examples:

- `aerobeat-tool-content-authoring`
- template repos that keep embedded addon trees in root imported surfaces

These should run the scanner in repo-local mode or workspace-aware mode if the CI environment has sibling repos available.

### 4) Hidden `.testbed` package CI — optional / informational only

Package repos such as `aerobeat-input-camera-tracking`, `aerobeat-spatial-ui-core`, and `aerobeat-ui-kit-community` can run an informational hidden-surface scan after their normal workbench refresh, but that should **not** be the main blocker channel for this guardrail.

---

## Recommended scanner behavior

### Default mode

`shipping` mode should:

- scan only non-hidden repo-root imported surfaces
- classify findings by `root_runtime` and `root_nonruntime`
- suppress hidden workbench findings unless explicitly requested
- exit non-zero on `blocker`
- exit zero on `warn_*` / `info_*`, while printing a durable report

### Optional context mode

`full` mode should:

- include hidden `.testbed/**` and related hidden workbench surfaces
- label those findings as contextual-only unless they also appear in shipping/root-import space

### Output formats

The implementation slice should support:

- human-readable Markdown or plain-text summary
- machine-readable JSON for CI annotations / future baselines

---

## Immediate guidance for the input-family overlap case

1. Treat the `aerobeat-input-camera-tracking` vs `aerobeat-assembly-community/addons/aerobeat-input-mediapipe` class family as a **known root-runtime embedded overlap**, not a hidden testbed problem.
2. Do **not** add `aerobeat-input-camera-tracking` as another root imported addon/runtime dependency in a runnable consumer that still materializes `aerobeat-input-mediapipe`.
3. Any migration that introduces the new package identity into a runnable root must first remove or replace the old root imported compatibility copy.
4. Until that cleanup happens, the scanner should emit a durable warning for this family every time shipping/root-import mode runs.

### Important nuance

Two root-runtime classes in separate repos do not automatically mean an immediate live runtime fault.

The dangerous part is the **migration window**:

- one repo is the new owner/source truth
- another runnable/imported root still carries the old embedded copy under a different addon identity/path
- a future dependency change could easily materialize both together unless the guardrail is explicit

That is exactly why this needs a scanner and a severity model.

---

## First remediation slice if we choose to act next

If the next step is execution, the first remediation slice should be:

### Slice A — build the scanner and fail only on real same-root runtime collisions

Implement a workspace-capable scanner that:

- inventories all `class_name` declarations in AeroBeat repos
- defaults to shipping/root-import mode
- classifies owner source vs embedded consumer copy
- emits `warn_embedded_overlap` for the current input-family case
- fails only on actual `blocker` conditions

### Slice B — document and freeze the input-family import rule

In parallel or immediately after scanner implementation, add a short durable rule to the relevant repos/docs:

- `aerobeat-assembly-community` must not root-import both `aerobeat-input-mediapipe` and `aerobeat-input-camera-tracking`
- future migration to the truthful camera-tracking package identity must remove or replace the old root imported compatibility addon before coexistence

### Slice C — only then decide cleanup mechanics

After the scanner exists, decide whether the real cleanup path is:

- dependency replacement in `aerobeat-assembly-community`
- stronger loading/registration rules
- eventual class renaming / namespace strategy

Do **not** start with renames. Start with detection + import-boundary truth.

---

## Concrete next implementation slice

If Derrick chooses to build the guardrail next, the concrete implementation slice should be:

1. Create a scanner script in an agreed durable tooling location.
   - Suggested home for the first pass: `aerobeat-ui-kit-community/scripts/scan_aerobeat_class_names.py`
2. Add shipping-mode inventory + severity classification for:
   - `root_runtime`
   - `root_nonruntime`
   - optional hidden context
3. Add a workspace-wide CLI entrypoint that scans `/home/derrick/.openclaw/workspace/projects/aerobeat/`.
4. Integrate the scanner into `aerobeat-assembly-community/.github/workflows/gut_ci.yml` immediately after `./scripts/restore-addons.sh`.
5. Seed the first known-overlap baseline/rule with the 14-class camera/input family listed above so the report is explicit on day one.

That gives AeroBeat a truthful first guardrail without prematurely forcing namespace or dependency surgery.

---

## Bottom line

The scanner should optimize for **root imported/runtime truth**, not hidden testbed noise.

The immediate input-family issue is a **real root-runtime embedded-copy overlap** between:

- `aerobeat-input-camera-tracking/src/**`
- `aerobeat-assembly-community/addons/aerobeat-input-mediapipe/src/**`

Treat it as a visible warning today and a blocker the moment a runnable root tries to import both sides into one runtime boundary.
