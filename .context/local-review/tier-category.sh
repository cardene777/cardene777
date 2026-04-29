#!/bin/bash
# Tier × Category 判定スクリプト
set +e

cd /private/tmp/cardene777
BASE_BRANCH="${1:-main}"
MERGE_BASE=$(git merge-base HEAD "$BASE_BRANCH" 2>/dev/null)
[ -z "$MERGE_BASE" ] && { echo "ERROR: merge-base not found" >&2; exit 1; }

CHANGED=$(git diff --name-only "$MERGE_BASE" 2>/dev/null)
STATS=$(git diff --numstat "$MERGE_BASE" 2>/dev/null)

FILE_COUNT=$(echo "$CHANGED" | grep -c -v '^$')
ADDED=$(echo "$STATS" | awk '{ s += $1 } END { print s+0 }')
DELETED=$(echo "$STATS" | awk '{ s += $2 } END { print s+0 }')

# === 1. HIGH-RISK パス検出（強制 heavy）===
HIGH_RISK_PATTERN='(^|/)(auth|crypto|transfer)(/|s/)|\.sol$|(^|/)migrations?/|(^|/)alembic/versions/|(^|/)prisma/migrations/|(^|/)secrets/|\.env\.'
if echo "$CHANGED" | grep -qE "$HIGH_RISK_PATTERN"; then
  CATEGORY="HIGH-RISK"
  TIER="heavy"
  WORKER_SET="codex-mcp-adversarial,cr-cli,generator-verifier"
else
  HAS_CODE=0; HAS_CONFIG=0; HAS_DOC=0
  while IFS= read -r f; do
    [ -z "$f" ] && continue
    case "$f" in
      *.md|*.mdx|*.rst|*.txt|docs/*|README*|CHANGELOG*) HAS_DOC=1 ;;
      *.json|*.yml|*.yaml|*.toml|*.ini|*.conf|Dockerfile*|docker-compose*|*.env.*example|.gitignore|.gitattributes) HAS_CONFIG=1 ;;
      *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs|*.py|*.go|*.rs|*.sh|*.bash) HAS_CODE=1 ;;
      *) HAS_CODE=1 ;;
    esac
  done <<< "$CHANGED"

  if [ $HAS_CODE -eq 1 ]; then
    CATEGORY="CODE"
  elif [ $HAS_CONFIG -eq 1 ]; then
    CATEGORY="CONFIG"
  elif [ $HAS_DOC -eq 1 ]; then
    CATEGORY="DOC"
  else
    CATEGORY="CODE"
  fi

  TIER_FILE="light"
  TIER_ADDED="light"
  TIER_DELETED="light"

  if   [ "$FILE_COUNT" -ge 11 ]; then TIER_FILE="heavy"
  elif [ "$FILE_COUNT" -ge 3 ];  then TIER_FILE="standard"
  fi

  if   [ "$ADDED" -ge 501 ]; then TIER_ADDED="heavy"
  elif [ "$ADDED" -ge 51 ];  then TIER_ADDED="standard"
  fi

  if   [ "$DELETED" -ge 301 ]; then TIER_DELETED="heavy"
  elif [ "$DELETED" -ge 31 ];  then TIER_DELETED="standard"
  fi

  if [ "$TIER_FILE" = "heavy" ] || [ "$TIER_ADDED" = "heavy" ] || [ "$TIER_DELETED" = "heavy" ]; then
    TIER="heavy"
  elif [ "$TIER_FILE" = "standard" ] || [ "$TIER_ADDED" = "standard" ] || [ "$TIER_DELETED" = "standard" ]; then
    TIER="standard"
  else
    TIER="light"
  fi

  case "${CATEGORY}_${TIER}" in
    DOC_light)        WORKER_SET="codex-mcp" ;;
    DOC_standard)     WORKER_SET="codex-mcp-adversarial" ;;
    DOC_heavy)        WORKER_SET="codex-mcp-adversarial,codex-mcp-adversarial-2" ;;
    CONFIG_light)     WORKER_SET="codex-mcp" ;;
    CONFIG_standard)  WORKER_SET="codex-mcp-adversarial" ;;
    CONFIG_heavy)     WORKER_SET="codex-mcp-adversarial,cr-cli" ;;
    CODE_light)       WORKER_SET="codex-mcp-adversarial" ;;
    CODE_standard)    WORKER_SET="codex-mcp-adversarial,cr-cli" ;;
    CODE_heavy)       WORKER_SET="codex-mcp-adversarial,cr-cli,generator-verifier" ;;
    *)                WORKER_SET="codex-mcp-adversarial,cr-cli,generator-verifier" ;;
  esac
fi

{
  echo "TIER=$TIER"
  echo "CATEGORY=$CATEGORY"
  echo "WORKER_SET=$WORKER_SET"
  echo "FILE_COUNT=$FILE_COUNT"
  echo "ADDED=$ADDED"
  echo "DELETED=$DELETED"
} > /private/tmp/cardene777/.context/local-review/tier-category.env

echo "[parallel-review] tier=$TIER category=$CATEGORY worker_set=$WORKER_SET (files=$FILE_COUNT +$ADDED -$DELETED)" \
  | tee /private/tmp/cardene777/.context/local-review/tier-category.log
