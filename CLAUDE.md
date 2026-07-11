# moeghashim/skills

Agent skills repo, structured like mattpocock/skills.

## Layout

- Skills live at `skills/<category>/<skill-name>/SKILL.md` (categories so far: `engineering`).
- `.claude-plugin/plugin.json` lists every installable skill path.
- `install.sh` is a no-Node fallback installer; the primary install is `npx skills@latest add moeghashim/skills`.

## Adding a skill

1. Create `skills/<category>/<skill-name>/SKILL.md` with `name` and `description` frontmatter.
2. Add its path to `.claude-plugin/plugin.json`.
3. Add it to the Reference section in `README.md`.

Categories named `deprecated` or `in-progress` are skipped by `install.sh`.

## Commits

Author and commit as `Moe Ghashim <mohanadgh@gmail.com>`. Do not add Co-Authored-By trailers.
