#!/usr/bin/env bash
# Install skills from github.com/moeghashim/skills into your Claude Code skills directory.
#
# From a clone:
#   ./install.sh --list                  # show available skills
#   ./install.sh gpt-claude              # install one skill
#   ./install.sh --all                   # install every skill
#   ./install.sh gpt-claude --dir PATH   # install to a custom directory
#
# Without cloning:
#   curl -fsSL https://raw.githubusercontent.com/moeghashim/skills/main/install.sh | bash -s -- gpt-claude

set -euo pipefail

REPO="moeghashim/skills"
BRANCH="main"
TARGET="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"

usage() {
  cat <<EOF
Install skills from github.com/$REPO into your Claude Code skills directory.

Usage:
  install.sh --list                  Show available skills
  install.sh <skill> [<skill>...]    Install specific skill(s)
  install.sh --all                   Install every skill
  install.sh <skill> --dir PATH      Install to a custom directory
                                     (default: ~/.claude/skills, or \$CLAUDE_SKILLS_DIR)

Without cloning the repo:
  curl -fsSL https://raw.githubusercontent.com/$REPO/$BRANCH/install.sh | bash -s -- <skill>
EOF
}

requested=()
install_all=false
list_only=false

while [ $# -gt 0 ]; do
  case "$1" in
    --all) install_all=true ;;
    --list) list_only=true ;;
    --dir)
      [ $# -ge 2 ] || { echo "error: --dir needs a path" >&2; exit 1; }
      TARGET="$2"; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "error: unknown option $1" >&2; usage >&2; exit 1 ;;
    *) requested+=("$1") ;;
  esac
  shift
done

# Use the repo we're running from if it contains skills; otherwise fetch from GitHub.
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-.}")" 2>/dev/null && pwd || echo "")"
if [ -n "$script_dir" ] && compgen -G "$script_dir/*/SKILL.md" > /dev/null 2>&1; then
  SRC="$script_dir"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "Fetching $REPO@$BRANCH from GitHub..."
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$tmp"
  SRC="$tmp/skills-$BRANCH"
fi

available=()
for f in "$SRC"/*/SKILL.md; do
  [ -e "$f" ] || continue
  available+=("$(basename "$(dirname "$f")")")
done

if [ ${#available[@]} -eq 0 ]; then
  echo "error: no skills found in $SRC" >&2
  exit 1
fi

if [ "$list_only" = true ]; then
  echo "Available skills:"
  for s in "${available[@]}"; do
    desc="$(sed -n 's/^description: *>*-*//p' "$SRC/$s/SKILL.md" | head -1)"
    [ -n "$desc" ] && echo "  $s -$desc" || echo "  $s"
  done
  exit 0
fi

if [ "$install_all" = true ]; then
  requested=("${available[@]}")
fi

if [ ${#requested[@]} -eq 0 ]; then
  usage
  echo
  echo "Available skills: ${available[*]}"
  exit 1
fi

mkdir -p "$TARGET"
for s in "${requested[@]}"; do
  if [ ! -f "$SRC/$s/SKILL.md" ]; then
    echo "error: unknown skill '$s' (available: ${available[*]})" >&2
    exit 1
  fi
  if [ -d "$TARGET/$s" ]; then
    rm -rf "$TARGET/$s"
    action="Updated"
  else
    action="Installed"
  fi
  cp -R "$SRC/$s" "$TARGET/$s"
  echo "$action $s -> $TARGET/$s"
done

echo
echo "Done. Restart Claude Code (or run /reload-plugins) and invoke a skill with /<skill-name>."
