# Story Creator — App Skeleton

This is a minimal Electron-based skeleton desktop app for macOS (and other platforms) that demonstrates the UI and orchestrator flow for the Story Creator pipeline.

Features included in the skeleton:
- Workflow steps UI (analyze, rewrite, segmentation, blurb, image, audio).
- Per-step editable prompt text (stored in memory for the run).
- Start / Pause / Resume controls.
- Checkpoint history list showing synthetic outputs.
- Inspect, Run, Retry, Jump-to-step (simulated behavior).

This skeleton is intentionally simple and uses simulated generation (no real models included). It's intended as a starting point for wiring real LLM, image, and TTS adapters.

Prerequisites
- Node.js and npm
- Electron (installed via `npm install`)

Run (development)

```bash
cd story_creator/app
npm install
npm start
```

Notes
- This app stores prompts and checkpoints in memory only. For a real app we will persist checkpoints to a local database (SQLite) and wire adapter modules to run local `llama.cpp`/GGML, `diffusers` (CoreML/MPS) and TTS engines.
- The UI demonstrates the control flow (approve/edit/retry/jump) required by the pipeline and will be extended to call the real orchestrator and adapter modules.
