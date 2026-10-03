---
name: game-assets
description: Prepare original game art from local files, procedural drawing, or an agent's available built-in image generation. Use when a mod needs new sprites, icons, textures, animation frames, audio or 3D assets; pass finished files to asset-pipeline for engine conversion.
---

# Game assets without a service key

Use local assets and tools first. This toolkit does not require an asset-service account, API key,
subscription, hosted MCP server, or paid generation backend.

## Choose the source

- **2D art:** use the user's files, draw procedurally with Pillow/SVG, or create pixel art locally.
  If the agent exposes built-in image generation (for example, an image-generation tool in Codex),
  use it for sprites, icons, concepts, backgrounds or textures. Follow that tool's own instructions.
  Availability depends on the agent session; a plugin install does not add image generation.
  Save the returned image locally before running the CLI. There is no `um` image-generation command.
  Do not substitute a separately billed API or ask for a provider key when the tool is unavailable.
- **3D:** reuse the example GLBs, use a model the user owns, or model in Blender and export GLB.
  Built-in image generation supplies pictures, not meshes, rigs or animations. For consistent unit
  headings, render a real local model with `um render3d`; do not label a concept PNG as a 3D model.
- **Animation:** draw individual frames, edit a reference image with an available built-in tool, use
  `um sprite frames` for simple idle motion, or render a local animated model in Blender.
- **Audio:** use the game's existing sound through its mod API, user-supplied recordings, appropriately
  licensed local audio, or synthesize simple effects locally. This toolkit has no hosted SFX, music or
  voice generation. The showcase can keep the recorded game's audio.

## Make the source fit the game

Check frame size, viewpoint, facing, pivot, palette and alpha in the game's own assets before drawing.
For generated sprites, request one isolated subject, the correct facing, and a transparent background
when the tool supports it. Use a flat background otherwise and remove it locally. Keep a reference
image for variants; inspect the result instead of assuming identity or animation consistency.

Use **asset-pipeline** to convert and inspect the files:

```bash
um sprite cutout source.png cut.png
um sprite fit cut.png item.png --size 64x26 --hard-alpha
um sprite pixelate cut.png pixels.png --size 32x32 --colors 16 --outline
um sprite preview item.png preview.png --scale 6
um render3d unit.glb frames/ --preset aoe2 --length 80
```

Test one asset in game before preparing the full set. Keep source files and conversion commands in
the mod's asset folder; record source, author/tool, license and edits in `MODLOG.md` or `CREDITS.md`.
Preserve upstream model and author credits when reusing the bundled example art.
