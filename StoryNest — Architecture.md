````markdown
# StoryNest — Architecture

## Requirements (summary)
- Cross-platform Flutter reader app: Android, iOS, iPad, Kindle Fire (Android fork).  
- Bundled static app_packs_list.json (list only updates on app update).  
- Story Pack: single compressed zip containing `pack_manifest.json`, `stories/<storyId>/story_manifest.json`, images, audio, thumbnails, license/attribution.  
- Downloads: Android → Play Asset Delivery or Play-hosted assets; iOS → ODR or CDN; Kindle → Cloudflare (or host).  
- App must: download pack, verify sha256, unzip, install to local storage, support uninstall, work fully offline.  
- Story manifest controls reading sequence (pages + questions; MCQ/fill-blank/subjective).  
- v1 features: page navigation, image, page-level audio, questions UI, install/uninstall. v2: word-level highlighting using timings.  
- AI pack generation happens offline on Mac via Story Creator (local models + QA).  
- Safety: automated filtering + manual QA at pack creation.

## Architecture (diagram)
```mermaid
flowchart TB
  subgraph App[Flutter Reader App]
    UI[UI Layer]
    AppLogic[Application Logic]
    Services[Services Layer]
    Storage[Local Storage]
    Platform[Platform Integrations]
  end

  subgraph Creator[Story Creator (Mac)]
    CreatorUI
    CreatorPipeline[AI Pipeline: rewrite → paginate → image gen → TTS → package]
    LocalModels[Local Models (LLM, SD, TTS)]
    QA[Moderation & Manual QA]
    Export[Pack Export (zip)]
  end

  subgraph Host[Host / Stores]
    Play[Google Play / PAD]
    AppStore[Apple App Store / ODR or CDN]
    Cloudflare[Cloudflare (Kindle)]
  end

  UI -->|reads| AppLogic
  AppLogic --> Services
  Services --> Storage
  Services --> Platform
  Platform --> Play
  Platform --> AppStore
  Platform --> Cloudflare

  CreatorUI --> CreatorPipeline
  CreatorPipeline --> LocalModels
  CreatorPipeline --> QA
  QA --> Export
  Export -->|upload| Play
  Export -->|upload| AppStore
  Export -->|upload| Cloudflare

  Services -->|download pack| Play
  Services -->|download pack| AppStore
  Services -->|download pack| Cloudflare
  Storage -->|serve offline| UI
```

## Components & Interfaces
- UI Layer: screens (Home, Packs List, Pack Details, Reader, Questions, Settings). Calls Application Logic async methods.
- Application Logic: orchestrates flows, exposes downloadPack(), openStory(), uninstallPack(), state streams.
- Services Layer:
  - DownloadManager: abstracts HTTP / Play Asset Delivery; returns tmp file, progress events.
  - Installer/PackManager: checksum verify, unzip, validate schema, store under `app_data/packs/{packId}`.
  - ManifestParser: parse pack + story manifests into typed models.
  - PlaybackService: play page audio, provide position for optional highlighting.
  - QuizEngine: render/validate questions, persist responses locally.
  - StorageService: manage disk usage and uninstall.
- Local Storage: `app_data/packs/{packId}/`, `installed_index.json` (metadata), optimized assets (webp/opus).
- Platform Integrations: PAD for Android, ODR/CDN for iOS, Cloudflare for Kindle. DownloadManager hides platform specifics.
- Story Creator (Mac): ingest raw tale → rewrite/sanitize → paginate → image prompt → local SD gen → TTS (per page) → optional word timings → generate manifests → QA → export zip.
- Host / Stores: upload built packs (Play/AppStore/Cloudflare); Play PAD allows bundling packs with app releases.

## Data & Manifest contract (high level)
- `pack_manifest.json`: id, title, description, version, story_count, size_bytes, checksum (sha256:...), platform_urls, thumbnail, language, author, publish_date, license.
- `story_manifest.json`: id, title, pages[{index,text,image,audio,duration_ms,optional word_timings}], sequence[], questions[], metadata{reading_level,duration_ms}.

## Non-functional notes
- Offline-first after pack install.  
- Use webp/opus for size.  
- Verify pack checksum before install.  
- Manual QA required for safety.

## Next steps
- Add JSON Schemas in `/schemas`.  
- Scaffold the Flutter app (lib/, pubspec.yaml).  
- Build minimal Story Creator script to generate one test pack.
````
