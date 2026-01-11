````markdown
# StoryNest — Repo

Quick steps to create a public GitHub repo and push this project (macOS, using GitHub CLI `gh`):

1. Initialize locally (from repo root)
```bash
git init
git add .
git commit -m "Initial: architecture + schemas + workspace"
```

2. Create public repo and push (requires `gh` installed and authenticated)
```bash
# replace <repo-name>
gh repo create <repo-name> --public --source=. --remote=origin --push
```
If you prefer GitHub web UI: create repo (Public), then follow the git remote add + push steps printed on the page.

3. Set up branch protection / issues / projects in GitHub as needed.

4. Open workspace in VS Code:
```bash
code StoryNest.code-workspace
```

Notes:
- Keep `app_packs_list.json` bundled in `assets/` and update only on app releases per design.
- Use `schemas/` to validate manifests before packaging story packs.
````
