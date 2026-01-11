# Story Creator — Requirements

## Purpose
A desktop macOS application (Story Creator) that transforms public-domain folktales into Story Packs consumable by the StoryNest Reader app. The app runs on a MacBook Pro (2025) and provides a human-in-the-loop AI pipeline.

## High-Level Workflow
1. Ingest: paste or import story text + metadata (title, source, language, license).
2. Safety analysis: detect sexual/violent/disturbing content and highlight spans.
3. Rewriting assistant: offer 2–4 alternative rewrites for flagged spans; user can accept one or reject.
4. Segmentation: split approved text into pages (2–6 sentences per page, theme-coherent).
5. Image prompts: generate short blurbs per page for image generation.
6. Image generation & review: generate images per page; allow per-page regeneration and selection.
7. Audio generation & review: generate narration per page; allow per-page regeneration and voice selection.
8. Packaging: produce `story_manifest.json`, place images/audio/pages into a folder structure, and create a pack archive with `pack_manifest.json`.

## Functional Requirements
- Text ingestion (paste/import) with metadata fields.
- Content Safety Analyzer that returns categorized flags with exact spans.
- Rewrite engine producing multiple candidate rewrites per flagged span.
- Segmentation engine producing editable page objects (2–6 sentences each).
- Image prompt generator producing concise blurbs (7–12 words).
- Image and audio adapters supporting local or remote model providers.
- Per-step review UI allowing accept/reject/regenerate actions.
- Manifest generation and packaging into an archive (.zip or .stnpack).
- Audit log of user approvals and modifications.

## Non-Functional Requirements
- Privacy: no automatic uploads without explicit user consent.
- Performance: typical folktale (<= 3k words) analysis and segmentation complete in seconds; image/audio generation time depends on provider.
- Extensibility: plugin adapter interfaces for different LLM/image/audio providers.
- Reproducibility: versioned prompts and model config for each generation.
- Accessibility: keyboard navigation and voice-over labels.

## Constraints & Notes
- User must confirm copyright/usage permissions before publishing or uploading.
- Support English initially; design for multi-language expansion.
- Store API keys securely (macOS Keychain recommended).

## Outputs
- `story_manifest.json` per story (pages, asset references, metadata, revision history)
- Pack archive containing one or more stories and a `pack_manifest.json` file

