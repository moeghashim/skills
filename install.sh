#!/usr/bin/env bash
# Fallback installer for github.com/moeghashim/skills (no Node needed).
# Preferred install: npx skills@latest add moeghashim/skills
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

Preferred (interactive, multi-agent):
  npx skills@latest add $REPO

This script (no Node needed):
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
if [ -n "$script_dir" ] && compgen -G "$script_dir/skills/*/*/SKILL.md" > /dev/null 2>&1; then
  SRC="$script_dir"
else
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  echo "Fetching $REPO@$BRANCH from GitHub..."
  curl -fsSL "https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz" | tar -xz -C "$tmp"
  SRC="$tmp/skills-$BRANCH"
fi

# Discover skills at skills/<category>/<name>/SKILL.md, skipping non-installable categories.
names=()
paths=()
for f in "$SRC"/skills/*/*/SKILL.md; do
  [ -e "$f" ] || continue
  d="$(dirname "$f")"
  case "$d" in
    "$SRC"/skills/deprecated/*|"$SRC"/skills/in-progress/*) continue ;;
  esac
  names+=("$(basename "$d")")
  paths+=("$d")
done

if [ ${#names[@]} -eq 0 ]; then
  echo "error: no skills found in $SRC" >&2
  exit 1
fi

if [ "$list_only" = true ]; then
  echo "Available skills:"
  i=0
  while [ $i -lt ${#names[@]} ]; do
    rel="${paths[$i]#"$SRC"/skills/}"
    echo "  ${names[$i]}  (${rel%/*})"
    i=$((i + 1))
  done
  exit 0
fi

if [ "$install_all" = true ]; then
  requested=("${names[@]}")
fi

if [ ${#requested[@]} -eq 0 ]; then
  usage
  echo
  echo "Available skills: ${names[*]}"
  exit 1
fi

mkdir -p "$TARGET"
for s in "${requested[@]}"; do
  src_path=""
  i=0
  while [ $i -lt ${#names[@]} ]; do
    if [ "${names[$i]}" = "$s" ]; then
      src_path="${paths[$i]}"
      break
    fi
    i=$((i + 1))
  done
  if [ -z "$src_path" ]; then
    echo "error: unknown skill '$s' (available: ${names[*]})" >&2
    exit 1
  fi
  if [ -d "$TARGET/$s" ]; then
    rm -rf "$TARGET/$s"
    action="Updated"
  else
    action="Installed"
  fi
  cp -R "$src_path" "$TARGET/$s"
  echo "$action $s -> $TARGET/$s"
done

echo
echo "Done. Restart Claude Code (or run /reload-plugins) and invoke a skill with /<skill-name>."
