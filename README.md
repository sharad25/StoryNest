# StoryNest

StoryNest is a pair of companion applications and tooling for creating and reading illustrated, narrated story packs designed for children and learners.

- Story Nest Reader App (`story_nest_reader_app`): a Flutter-based reader application that displays story packs (pages, images, and audio) on mobile and desktop. It provides an accessible, kid-friendly reading experience with page navigation, image display, and audio narration.
 - Story Nest Reader App (`story_nest_reader_app`): a Flutter-based reader application that displays story packs (pages, images, and audio) on mobile and desktop. It provides an accessible, kid-friendly reading experience with page navigation, image display, and audio narration.

Supported platforms and current status:
- Target platforms: iPhone (iOS), iPad (iPadOS), Android phones, and Kindle Fire tablets (Android-based).
- Current build status: as of now the project is configured and tested to build for Android phones. Support for iPhones, iPads and Kindle Fire tablets is a stated goal; platform-specific packaging, signing, and testing remain to be completed for those targets.

- Story Creator (AI pipeline): a separate desktop authoring app (prototype planned under `story_creator/`) that transforms public-domain folktales into Story Packs via a human-in-the-loop AI workflow. It analyzes content for safety, offers rewrites for flagged sections, segments the story into reader-friendly pages, generates image prompts and images, produces audio narration, and packages the result into a story manifest and pack archive consumable by the Reader App.

Repository layout highlights:
- `story_nest_reader_app/` — the reader application (previously `reader_app`).
- `story_creator/` — design and architecture for the AI pipeline app (requirements and architecture docs live here).
- `manifests/` and `schemas/` — example manifests and JSON schemas for story and pack manifests.

Next steps:
- Implement the Story Creator scaffold and adapters for LLM, image, and audio providers.
- Iterate on manifest schema and packaging to ensure Reader compatibility.
