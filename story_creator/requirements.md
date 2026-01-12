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
 - Image prompt generator producing concise blurbs (maximum 10 words; typically 7–8 words).
- Image and audio adapters supporting local or remote model providers.
- Per-step review UI allowing accept/reject/regenerate actions.
- Manifest generation and packaging into an archive (.zip or .stnpack).
- Audit log of user approvals and modifications.

Workflow & UI-specific requirements
- Human-in-the-loop approvals: the UI must present the results of every automatic step (analysis, rewrite candidates, segmentation, image results, audio results) and require an explicit accept/reject action before proceeding.
- Editable outputs: after any generation step the user must be able to open an inline editor to make manual modifications to the generated text (e.g., adjusted rewrites, edited page text) or replace assets (images/audio) before accepting.
- Pause / Resume: the user must be able to pause the running workflow at any point and resume later; in paused state the pipeline preserves all intermediate artifacts and user decisions.
- Checkpoints & versioning: each completed step must be snapshotted (artifact + metadata + chosen/accepted state). Snapshots allow the user to revert to earlier versions of text, images, or audio.
- Jump & Rerun semantics: after the full story run is complete the user must be able to jump back to any earlier step, modify or replace artifacts, and re-run only the subsequent downstream steps (not the steps upstream of the chosen step). The orchestrator must track dependencies between steps so reruns re-generate only what is affected.
- Non-destructive edits: edits and re-generations must be stored as new revisions; original artifacts should be retained in the project history unless explicitly discarded by the user.

- Retry and failure handling: any pipeline step that fails (model error, provider error, transient error) must expose a `Retry` action in the UI. Retries should support parameter changes (for example: increased timeout, adjusted model selection, or changed prompt) and be tracked as a new attempt in the checkpoint history.
- Per-step prompt templates: each LLM-powered step must have a stored prompt template that is used by default. The UI must present the active prompt for each run and allow the human operator to edit the prompt prior to execution. Edited prompts are saved with the run's checkpoint metadata so generations are reproducible.
- Prefilled prompts and overrides: the app ships with sensible prefilled prompt templates for safety analysis, rewrite, segmentation, and blurb generation. The human operator designs and customizes these templates; the system retains the original defaults and each run's override text.

- Pack management:
	- Add-to-pack: the user must be able to add one or more previously created stories into an existing Story Pack. The UI should show pack contents and allow adding/removing stories.
	- Pack description auto-update: provide an optional action that runs an LLM-based `Pack Analyzer` which reads the textual content (and optionally image/audio metadata) of all stories in a pack and generates a concise, user-editable pack description summarizing themes, target age-range, and keywords.
	- Pack image generation: the `Pack Analyzer` should also produce a short blurb describing a representative image for the pack and invoke the image generation adapter to create a cover image. The generated pack image must be reviewable and replaceable by the user.
	- Pack title suggestions: the Pack Analyzer must offer a set of suggested pack titles derived from the contents and themes of the pack. The UI should present suggested titles and allow the user to pick one or enter a custom title.
	- Per-page blurb length limit: generated page blurbs (used to prompt image generation) must never exceed 10 words; the system should enforce this constraint when creating blurbs and show the effective blurb to the user for editing.
	- Recompute pack metadata: whenever stories are added/removed or substantial edits are made, the user can re-run the Pack Analyzer to refresh the description and cover image; changes are stored as new pack-level checkpoints.

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

