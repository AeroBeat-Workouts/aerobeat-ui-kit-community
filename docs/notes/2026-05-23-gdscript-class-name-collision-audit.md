# AeroBeat spatial UI family GDScript `class_name` collision audit

**Date:** 2026-05-23  \
**Owning bead:** `aerobeat-ui-kit-community-063l`  \
**Owning repo:** `aerobeat-ui-kit-community`  \
**Audit author:** OpenClaw subagent (`research` role)

## Executive summary

- **Verdict:** the current AeroBeat spatial UI family is **safe to consume together** from a Godot global `class_name` perspective on its intended load-bearing surfaces.
- Across the six producer repos (`spatial-ui-core`, `spatial-ui-mouse`, `spatial-ui-touch`, `spatial-ui-xr`, `input-core`, `ui-core`), the audit found **36 declared `class_name` values and 36 unique names**.
- Across the visible `aerobeat-ui-kit-community/.testbed` Godot project surface, the audit found **47 declared `class_name` values and 47 unique names**.
- **Exact collisions inside the audited family today:** **0**.
- The only overlaps involving audited family names in the wider AeroBeat polyrepo are producer-consumer copy scenarios, not sibling-name conflicts inside the spatial UI family itself.

## Scope

- `aerobeat-spatial-ui-core`
- `aerobeat-spatial-ui-mouse`
- `aerobeat-spatial-ui-touch`
- `aerobeat-spatial-ui-xr`
- `aerobeat-input-core`
- `aerobeat-ui-core`
- `aerobeat-ui-kit-community`

### Audit surface rules

- Counted **non-hidden, non-generated, non-GUT-test** GDScript files that declare `class_name`.
- Counted the visible `aerobeat-ui-kit-community/.testbed` project surface because that is a real Godot project a developer can open and run.
- Excluded dot-prefixed mirror trees such as `.testbed/.addons/**` from the collision verdict because they are storage/mirror copies, not the intended consumer-facing load-bearing surface for upstream composition.
- Also excluded GUT fixture/test classes from the safety verdict; they are noisy and do not represent addon/runtime API surface.

## Collision verdict

| Surface | Declared names | Unique names | Exact collisions | Verdict |
| --- | ---: | ---: | ---: | --- |
| Producer repos combined | 36 | 36 | 0 | Safe |
| `aerobeat-ui-kit-community/.testbed` visible project surface | 47 | 47 | 0 | Safe |

### Current answer

**The current spatial UI family is safe, not unsafe.** No exact duplicate `class_name` declarations were found across the intended shared-runtime surfaces of the audited repos.

## Real overlap found outside the core family

These are not sibling collisions inside the audited spatial UI family, but they are the places where audited class names already reappear elsewhere in AeroBeat due to producer/consumer copying. They are worth calling out because they can become real Godot global-name collisions if a downstream project loads both the producer repo and an embedded copy at the same time.

| Class name | Severity | Where it appears | Why it matters | Recommendation |
| --- | --- | --- | --- | --- |
| `AeroInputProvider` | Medium | `aerobeat-assembly-community/addons/aerobeat-input-core/src/interfaces/input_provider.gd`<br>`aerobeat-input-core/src/interfaces/input_provider.gd`<br>`aerobeat-template-assembly/addons/aerobeat-input-core/src/interfaces/input_provider.gd` | Shared upstream API class copied into consumer/template repos. | Avoid loading both the source addon and an embedded copy in one project; treat embedded copies as mutually exclusive with their upstream source repo. |
| `BoxingInput` | Medium | `aerobeat-assembly-community/addons/aerobeat-input-core/src/interfaces/boxing_input.gd`<br>`aerobeat-input-core/src/interfaces/boxing_input.gd`<br>`aerobeat-template-assembly/addons/aerobeat-input-core/src/interfaces/boxing_input.gd` | Shared upstream API class copied into consumer/template repos. | Avoid loading both the source addon and an embedded copy in one project; treat embedded copies as mutually exclusive with their upstream source repo. |
| `FlowInput` | Medium | `aerobeat-assembly-community/addons/aerobeat-input-core/src/interfaces/flow_input.gd`<br>`aerobeat-input-core/src/interfaces/flow_input.gd`<br>`aerobeat-template-assembly/addons/aerobeat-input-core/src/interfaces/flow_input.gd` | Shared upstream API class copied into consumer/template repos. | Avoid loading both the source addon and an embedded copy in one project; treat embedded copies as mutually exclusive with their upstream source repo. |
| `InputManager` | High | `aerobeat-assembly-community/addons/aerobeat-input-core/src/input_manager.gd`<br>`aerobeat-input-core/src/input_manager.gd`<br>`aerobeat-template-assembly/addons/aerobeat-input-core/src/input_manager.gd` | Very generic global name; easiest one to collide with future addons. | Prefer a more family-scoped name in the next remediation slice. |

## Highest-risk names and near-duplicate clusters

No exact sibling collisions exist today, but the following names/clusters deserve the most guardrail attention.

| Name or cluster | Type | Severity | Rationale | Guardrail |
| --- | --- | --- | --- | --- |
| `InputManager` | Real external overlap + generic name | High | Already overlaps outside the spatial UI family through embedded `input-core` copies, and the bare name is globally generic in Godot ecosystems. | Reserve `InputManager` for legacy compatibility only; prefer a future family-scoped rename plan such as `AeroInputManager` if/when breaking changes are allowed. |
| `AeroInputProvider`, `BoxingInput`, `FlowInput` | Real external overlap | Medium | These already reappear in `assembly-community` / `template-assembly` via copied addon payloads. | Never load source `input-core` and copied `addons/aerobeat-input-core` payloads together in one Godot project. |
| `AeroSpatialUiMouseProvider, AeroSpatialUiTouchProvider, AeroSpatialUiXrProvider` | Near-duplicate sibling cluster | Low | Intentional modality-scoped siblings; safe today because each keeps the full `AeroSpatialUi<Modality>...` prefix. | Keep modality token (`Mouse` / `Touch` / `Xr`) mandatory in new provider/config/boundary classes; do not introduce shortened aliases like `AeroSpatialUiProvider`. |
| `AeroSpatialUiMouseProviderConfig, AeroSpatialUiTouchProviderConfig, AeroSpatialUiXrProviderConfig` | Near-duplicate sibling cluster | Low | Intentional modality-scoped siblings; safe today because each keeps the full `AeroSpatialUi<Modality>...` prefix. | Keep modality token (`Mouse` / `Touch` / `Xr`) mandatory in new provider/config/boundary classes; do not introduce shortened aliases like `AeroSpatialUiProvider`. |
| `AeroSpatialUiMouseRuntimeBoundary, AeroSpatialUiTouchRuntimeBoundary, AeroSpatialUiXrRuntimeBoundary` | Near-duplicate sibling cluster | Low | Intentional modality-scoped siblings; safe today because each keeps the full `AeroSpatialUi<Modality>...` prefix. | Keep modality token (`Mouse` / `Touch` / `Xr`) mandatory in new provider/config/boundary classes; do not introduce shortened aliases like `AeroSpatialUiProvider`. |
| `AeroSpatialUiCoreManifest, AeroSpatialUiTouchManifest, AeroSpatialUiXrManifest` | Near-duplicate sibling cluster | Low | Intentional modality-scoped siblings; safe today because each keeps the full `AeroSpatialUi<Modality>...` prefix. | Keep modality token (`Mouse` / `Touch` / `Xr`) mandatory in new provider/config/boundary classes; do not introduce shortened aliases like `AeroSpatialUiProvider`. |

## Recommended remediation / guardrails

1. **No urgent rename is required for the audited spatial UI family.** The family can be consumed together today without global `class_name` collisions.
2. **Add a CI audit script** that fails if two non-hidden runtime/addon scripts in the intended consumer surface declare the same `class_name`. This would keep future regressions out of the polyrepo.
3. **Treat embedded addon copies as mutually exclusive with their upstream source addon repos.** If a project vendors `aerobeat-input-core`, do not also load the standalone `aerobeat-input-core` repo in the same Godot project.
4. **Prefer family-scoped names for future globally-registered classes.** Bare names like `InputManager` are the easiest future collision point.
5. **When adding new modality-specific spatial providers, configs, manifests, or runtime boundaries, keep the full modality token in the `class_name`.**

## Inventory by repo

### `aerobeat-spatial-ui-core` (7)

| Class name | Path |
| --- | --- |
| `AeroSpatialHoverCapturePolicy` | `src/helpers/policies/aero_spatial_hover_capture_policy.gd` |
| `AeroSpatialProjectionHelper` | `src/helpers/providers/aero_spatial_projection_helper.gd` |
| `AeroSpatialRectTargetResolver` | `src/helpers/providers/aero_spatial_rect_target_resolver.gd` |
| `AeroSpatialSurfaceDescriptor` | `src/helpers/surfaces/aero_spatial_surface_descriptor.gd` |
| `AeroSpatialTargetResolutionResult` | `src/helpers/surfaces/aero_spatial_target_resolution_result.gd` |
| `AeroSpatialTargetResolverBase` | `src/helpers/providers/aero_spatial_target_resolver_base.gd` |
| `AeroSpatialUiCoreManifest` | `src/helpers/aero_spatial_ui_core_manifest.gd` |

### `aerobeat-spatial-ui-mouse` (3)

| Class name | Path |
| --- | --- |
| `AeroSpatialUiMouseProvider` | `src/providers/mouse/aero_spatial_ui_mouse_provider.gd` |
| `AeroSpatialUiMouseProviderConfig` | `src/providers/mouse/aero_spatial_ui_mouse_provider_config.gd` |
| `AeroSpatialUiMouseRuntimeBoundary` | `src/providers/mouse/aero_spatial_ui_mouse_runtime_boundary.gd` |

### `aerobeat-spatial-ui-touch` (4)

| Class name | Path |
| --- | --- |
| `AeroSpatialUiTouchManifest` | `src/providers/touch/aero_spatial_ui_touch_manifest.gd` |
| `AeroSpatialUiTouchProvider` | `src/providers/touch/aero_spatial_ui_touch_provider.gd` |
| `AeroSpatialUiTouchProviderConfig` | `src/providers/touch/aero_spatial_ui_touch_provider_config.gd` |
| `AeroSpatialUiTouchRuntimeBoundary` | `src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd` |

### `aerobeat-spatial-ui-xr` (4)

| Class name | Path |
| --- | --- |
| `AeroSpatialUiXrManifest` | `src/providers/xr/aero_spatial_ui_xr_manifest.gd` |
| `AeroSpatialUiXrProvider` | `src/providers/xr/aero_spatial_ui_xr_provider.gd` |
| `AeroSpatialUiXrProviderConfig` | `src/providers/xr/aero_spatial_ui_xr_provider_config.gd` |
| `AeroSpatialUiXrRuntimeBoundary` | `src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd` |

### `aerobeat-input-core` (14)

| Class name | Path |
| --- | --- |
| `AeroInputProvider` | `src/interfaces/input_provider.gd` |
| `AeroProviderSessionRegistry` | `src/runtime/provider_session_registry.gd` |
| `AeroUiInteractable` | `src/ui/consumers/ui_interactable.gd` |
| `AeroUiInteractionBus` | `src/ui/ui_interaction_bus.gd` |
| `AeroUiInteractionEvent` | `src/ui/ui_interaction_event.gd` |
| `AeroUiInteractionListener` | `src/ui/consumers/ui_interaction_listener.gd` |
| `AeroUiInteractionTypes` | `src/ui/ui_interaction_types.gd` |
| `AeroUiVerificationStatus` | `src/ui/ui_verification_status.gd` |
| `BoxingInput` | `src/interfaces/boxing_input.gd` |
| `FlowInput` | `src/interfaces/flow_input.gd` |
| `HybridSubViewportInputAdapter` | `src/ui/adapters/hybrid_subviewport_input_adapter.gd` |
| `InputManager` | `src/input_manager.gd` |
| `ScreenUiInputAdapter` | `src/ui/adapters/screen_ui_input_adapter.gd` |
| `XrUiInputAdapter` | `src/ui/adapters/xr_ui_input_adapter.gd` |

### `aerobeat-ui-core` (4)

| Class name | Path |
| --- | --- |
| `AeroButtonBase` | `scripts/base/aero_button_base.gd` |
| `AeroContractConsumerViewBase` | `scripts/base/aero_contract_consumer_view_base.gd` |
| `AeroUiContractTargetBinding` | `scripts/contract/aero_ui_contract_target_binding.gd` |
| `AeroViewBase` | `scripts/base/aero_view_base.gd` |

### `aerobeat-ui-kit-community` root surface

The repo's top-level `addons/` tree currently declares **0** `class_name` values. The load-bearing names in this repo live in the visible `.testbed` demo/runtime project surface below.

### `aerobeat-ui-kit-community/.testbed` visible project surface (47)

| Class name | Path |
| --- | --- |
| `AeroButtonBase` | `.testbed/addons/aerobeat-ui-core/scripts/base/aero_button_base.gd` |
| `AeroContractConsumerViewBase` | `.testbed/addons/aerobeat-ui-core/scripts/base/aero_contract_consumer_view_base.gd` |
| `AeroInputProvider` | `.testbed/addons/aerobeat-input-core/src/interfaces/input_provider.gd` |
| `AeroSpatialHoverCapturePolicy` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/policies/aero_spatial_hover_capture_policy.gd` |
| `AeroSpatialProjectionHelper` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_projection_helper.gd` |
| `AeroSpatialRectTargetResolver` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_rect_target_resolver.gd` |
| `AeroSpatialSurfaceDescriptor` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_surface_descriptor.gd` |
| `AeroSpatialTargetResolutionResult` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/surfaces/aero_spatial_target_resolution_result.gd` |
| `AeroSpatialTargetResolverBase` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/providers/aero_spatial_target_resolver_base.gd` |
| `AeroSpatialUiCoreManifest` | `.testbed/addons/aerobeat-spatial-ui-core/src/helpers/aero_spatial_ui_core_manifest.gd` |
| `AeroSpatialUiMouseProvider` | `.testbed/addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider.gd` |
| `AeroSpatialUiMouseProviderConfig` | `.testbed/addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_provider_config.gd` |
| `AeroSpatialUiMouseRuntimeBoundary` | `.testbed/addons/aerobeat-spatial-ui-mouse/src/providers/mouse/aero_spatial_ui_mouse_runtime_boundary.gd` |
| `AeroSpatialUiTouchManifest` | `.testbed/addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_manifest.gd` |
| `AeroSpatialUiTouchProvider` | `.testbed/addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider.gd` |
| `AeroSpatialUiTouchProviderConfig` | `.testbed/addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_provider_config.gd` |
| `AeroSpatialUiTouchRuntimeBoundary` | `.testbed/addons/aerobeat-spatial-ui-touch/src/providers/touch/aero_spatial_ui_touch_runtime_boundary.gd` |
| `AeroSpatialUiXrManifest` | `.testbed/addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_manifest.gd` |
| `AeroSpatialUiXrProvider` | `.testbed/addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider.gd` |
| `AeroSpatialUiXrProviderConfig` | `.testbed/addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_provider_config.gd` |
| `AeroSpatialUiXrRuntimeBoundary` | `.testbed/addons/aerobeat-spatial-ui-xr/src/providers/xr/aero_spatial_ui_xr_runtime_boundary.gd` |
| `AeroUiContractTargetBinding` | `.testbed/addons/aerobeat-ui-core/scripts/contract/aero_ui_contract_target_binding.gd` |
| `AeroUiElementGroupController` | `.testbed/ui/views/shared/aero_ui_element_group_controller.gd` |
| `AeroUiGlassBadgeConfig` | `.testbed/ui/configs/types/aero_ui_glass_badge_config.gd` |
| `AeroUiGlassBadgeConfigLoader` | `.testbed/ui/configs/loaders/aero_ui_glass_badge_config_loader.gd` |
| `AeroUiGlassBadgeView` | `.testbed/ui/views/aero_ui_glass_badge_view.gd` |
| `AeroUiGlassPanelConfig` | `.testbed/ui/configs/types/aero_ui_glass_panel_config.gd` |
| `AeroUiGlassPanelConfigLoader` | `.testbed/ui/configs/loaders/aero_ui_glass_panel_config_loader.gd` |
| `AeroUiGlassPanelView` | `.testbed/ui/views/aero_ui_glass_panel_view.gd` |
| `AeroUiGlassPrimaryButtonConfig` | `.testbed/ui/configs/types/aero_ui_glass_primary_button_config.gd` |
| `AeroUiGlassPrimaryButtonConfigLoader` | `.testbed/ui/configs/loaders/aero_ui_glass_primary_button_config_loader.gd` |
| `AeroUiGlassPrimaryButtonView` | `.testbed/ui/views/aero_ui_glass_primary_button_view.gd` |
| `AeroUiInteractable` | `.testbed/addons/aerobeat-input-core/src/ui/consumers/ui_interactable.gd` |
| `AeroUiInteractionBus` | `.testbed/addons/aerobeat-input-core/src/ui/ui_interaction_bus.gd` |
| `AeroUiInteractionEvent` | `.testbed/addons/aerobeat-input-core/src/ui/ui_interaction_event.gd` |
| `AeroUiInteractionListener` | `.testbed/addons/aerobeat-input-core/src/ui/consumers/ui_interaction_listener.gd` |
| `AeroUiInteractionTypes` | `.testbed/addons/aerobeat-input-core/src/ui/ui_interaction_types.gd` |
| `AeroUiTweenUtils` | `.testbed/ui/views/shared/aero_ui_tween_utils.gd` |
| `AeroUiVerificationStatus` | `.testbed/addons/aerobeat-input-core/src/ui/ui_verification_status.gd` |
| `AeroUiYamlConfigDocumentLoader` | `.testbed/ui/configs/loaders/aero_ui_yaml_config_document_loader.gd` |
| `AeroViewBase` | `.testbed/addons/aerobeat-ui-core/scripts/base/aero_view_base.gd` |
| `BoxingInput` | `.testbed/addons/aerobeat-input-core/src/interfaces/boxing_input.gd` |
| `FlowInput` | `.testbed/addons/aerobeat-input-core/src/interfaces/flow_input.gd` |
| `HybridSubViewportInputAdapter` | `.testbed/addons/aerobeat-input-core/src/ui/adapters/hybrid_subviewport_input_adapter.gd` |
| `InputManager` | `.testbed/addons/aerobeat-input-core/src/input_manager.gd` |
| `ScreenUiInputAdapter` | `.testbed/addons/aerobeat-input-core/src/ui/adapters/screen_ui_input_adapter.gd` |
| `XrUiInputAdapter` | `.testbed/addons/aerobeat-input-core/src/ui/adapters/xr_ui_input_adapter.gd` |

## Wider-polyrepo context

- Broader AeroBeat source-surface scan: **203 declared names, 149 unique names, 43 duplicate names**.
- Most wider-polyrepo duplicates are producer/consumer or template-copy relationships, not independent sibling repos accidentally reusing the same global class name.
- For the audited family specifically, the only broader overlaps were `AeroInputProvider`, `BoxingInput`, `FlowInput`, and `InputManager`, each caused by embedded `aerobeat-input-core` copies in other repos.

## Bottom line

If a developer composes the current **spatial UI core + mouse + touch + XR + input-core + ui-core** surfaces together, the Godot global `class_name` registry is currently **clean**. The family is safe to consume together **as long as downstream projects do not also load duplicate vendored copies of the same addons in parallel**.

