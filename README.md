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

That installs the tagged `aerobeat-core` and `aerobeat-ui-core` foundations plus GUT into `.testbed/addons/`.

### Open the testbed

From the repo root:

```bash
godot --editor --path .testbed
```

### Validation notes

- `.testbed/addons.jsonc` is the only committed dev/test dependency contract.
- The manifest pins `aerobeat-core` to `v0.1.0` and `aerobeat-ui-core` to `v0.1.1` for the Phase 1 retry validation chain.
- `.testbed/test` is a tracked relative link into the repo root so the hidden workbench can run the repo-local GUT suite without a legacy setup script.
- The current package shape is consumed from the repo root (`subfolder: "/"`) for downstream installs. That repo-root package boundary is now explicit release contract state for this initial Phase 1 tag.
