---
name: excalidraw-safe-edit
description: Safely refine an existing live Excalidraw canvas when moving or resizing nodes, zones, arrows, or labels. Use for mcp-excalidraw-server edits where element bindings and browser-side normalization can cause surprising movement or text corruption. Do not use for a brand-new diagram, Mermaid-only output, or raster image editing.
---

# Excalidraw Safe Edit

Preserve the user's existing live canvas and make the smallest reliable visual change. Do not substitute another visualization format.

## Before changing anything

1. Reuse the active canvas server and its configured `EXPRESS_SERVER_URL`; do not start a second canvas on the default port.
2. Run `describe`, then `get <id>` for every target and its connected arrows or text.
3. Treat these fields as a binding graph, not independent decoration:
   - shape `boundElements`
   - text `containerId`
   - arrow `startBinding`, `endBinding`, `boundElements`, and `points`
4. Save a named snapshot before the first mutation.
5. Take and view a baseline whole-scene screenshot.

## Choose the least coupled fix

- Prefer moving or resizing the endpoint shapes. Bound arrows should reroute with their endpoints; edit arrow points only if the next screenshot proves they did not.
- When a label hides a short arrow, first create 80-120 px of space by moving the surrounding shapes. Keep the label bound unless detachment is genuinely required.
- Prefer updating existing elements over deleting and recreating them.
- Preserve stable element IDs and unrelated properties.

## Fragile operations

- Do not detach bound text and reposition it in the same patch. In the current frontend, changing `containerId` to `null` can trigger normalization after the patch and move the text far from the requested coordinates.
- If text must become standalone, use two checkpoints: detach only, let frontend sync settle, inspect with `get` and screenshot, then reposition in a second update.
- Do not repair an existing scene by creating minimally specified raw text elements. If new standalone text is necessary, supply explicit `x`, `y`, `width`, `height`, `text`, `fontSize`, `fontFamily`, alignment, and line-height fields; create one element first and screenshot it before batching more.
- Never keep layering corrective patches onto a screenshot showing widespread text truncation, off-canvas labels, or unexpected element movement. Restore the snapshot and choose a less coupled edit.

## Mutation loop

1. Apply one conceptual change, preferably geometry-only.
2. Let the browser receive and normalize the update.
3. Take a whole-scene screenshot and inspect it visually.
4. Verify target positions and bindings with `describe` or `get` when the render differs from the requested coordinates.
5. Continue only when text, arrows, spacing, and unrelated regions are intact.

Zooming or panning in the shared browser does not change the whole-scene export. User edits to elements do share state and can race with programmatic changes.

## Completion

- Require a clean final whole-scene screenshot.
- Save a final named snapshot.
- Export an `.excalidraw` file only when the user asks for persistence; otherwise state that the live canvas can be lost when its server stops.
