# Stale QA probe cleanup note

Date: 2026-05-15
Repo: `/home/derrick/.openclaw/workspace/projects/aerobeat/aerobeat-ui-kit-community`
Scope: temporary QA probes only

## Why this cleanup is needed

`glass_shader_panel_source.gd` now extends `AeroContractConsumerViewBase`, and the reusable consumer nodes live under per-target `AeroUiContractTargetBinding` children instead of as direct-child `AeroUiInteractable` / `AeroUiInteractionListener` nodes on the panel root. Several temporary QA probes still assume the old direct-child layout, so they now fail for stale-architecture reasons rather than real product regressions.

## Probes that are stale because of the old direct-child consumer assumption

### Update and keep

These still cover useful behavior, but their structural checks need to be moved to the binding-owned layout.

1. `.temp/qa-evidence/hybrid_contract_probe.gd`
   - Stale assumptions:
     - looks for `PreviewButton`
     - looks for direct children `AeroUiInteractable` / `AeroUiInteractionListener` on `panel_ui` and `mask_ui`
     - expects direct bus-path reporting from those direct children
   - Minimal fix:
     - switch label/button paths to `PrimaryCardButton`
     - replace direct-child consumer checks with binding-based checks (for example, enumerate `AeroUiContractTargetBinding` children and validate their interactable/listener ownership)
     - either regenerate or delete stale `hybrid_contract_probe.json`

2. `.temp/qa-evidence/screen_2d_contract_probe.gd`
   - Stale assumptions:
     - looks for `PreviewButton`
     - reads `_ui_interactable` and `_ui_listener` fields that no longer represent the real extracted layout
   - Minimal fix:
     - switch to `PrimaryCardButton`
     - validate binding-owned consumers instead of `_ui_interactable` / `_ui_listener`
     - keep the host-side screen input assertions
     - either regenerate or delete stale `screen_2d_contract_probe.json`

3. `.temp/qa-evidence/multi_target_hybrid_qa_probe.gd`
   - Mostly current already.
   - The stale part is only the consumer-shape check:
     - it expects direct child nodes named `PrimaryCardButtonInteractable`, `PrimaryCardButtonListener`, `SecondaryToggleChipInteractable`, `SecondaryToggleChipListener`, `DragStripInteractable`, and `DragStripListener`
     - it checks direct bus connections against those expected direct children
   - Minimal fix:
     - keep the good multi-target hit/hover/owner continuity assertions
     - replace direct child node checks with binding-node checks (`AeroUiContractTargetBinding` count, target keys, and per-binding interactable/listener presence)
     - either regenerate or delete stale `multi_target_hybrid_qa_probe.json`

### Remove as obsolete debug probes

These are one-off investigation scripts for the pre-extraction layout and are not worth porting.

- `.temp/qa-evidence/check_bus_path.gd`
- `.temp/qa-evidence/check_contract_retry.gd`
- `.temp/qa-evidence/inspect_contract_flow.gd`
- `.temp/qa-evidence/inspect_contract_flow_2.gd`
- `.temp/qa-evidence/inspect_contract_flow_rebind.gd`

Reasons:
- they hard-code direct-child consumer lookups and/or old private panel internals such as `_setup_contract_consumers`, `_toggle_count`, `_hover_active`, `_press_active`, `_last_pointer_summary`, `_last_input_source`, and `HYBRID_BUS_PATH`
- they are debug archaeology, not stable QA coverage
- the current extracted base class changed the ownership model enough that updating them would just preserve redundant probes

## Probes to keep as-is

These already match the current architecture closely enough, or they validate host behavior instead of the old direct-child consumer placement.

- `.temp/qa/validate_contract_consumer_adoption.gd`
  - already aligned to the binding-owned layout by counting `AeroUiContractTargetBinding` children and checking `get_interaction_target_specs()`
- `.temp/qa-evidence/screen_2d_scene_probe.gd`
- `.temp/qa-evidence/screen_2d_tap_probe.gd`
  - these exercise host/input readouts and do not rely on direct-child interactable/listener placement
- existing screenshot/manual QA notes in `.temp/qa-evidence/` can stay; they are evidence artifacts, not structural probes

## Minimal coder-ready cleanup plan

1. Keep `.temp/qa/validate_contract_consumer_adoption.gd` as the architectural smoke test.
2. Update only these reusable probes:
   - `.temp/qa-evidence/hybrid_contract_probe.gd`
   - `.temp/qa-evidence/screen_2d_contract_probe.gd`
   - `.temp/qa-evidence/multi_target_hybrid_qa_probe.gd`
3. Remove these obsolete debug probes:
   - `check_bus_path.gd`
   - `check_contract_retry.gd`
   - `inspect_contract_flow.gd`
   - `inspect_contract_flow_2.gd`
   - `inspect_contract_flow_rebind.gd`
4. Remove or regenerate the stale JSON outputs tied to the updated probes so the evidence folder stops carrying known-false failures forward.

## Nearby temp probe note

There are other older `.temp/*.gd` visual-capture scripts that still mention `PreviewButton`, but they are parity/capture probes rather than the contract-consumer extraction follow-up. They can be handled later if needed; they are not the minimal required hygiene slice from this audit follow-up.
