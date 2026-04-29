#!/bin/bash
# Codex CLI direct fallback (plugin failed with ENOBUFS due to large diff)
set +e
cd /private/tmp/cardene777

PROMPT_FILE=/private/tmp/cardene777/.context/local-review/codex-prompt.txt

codex exec --full-auto --skip-git-repo-check -m gpt-5.4 -C /private/tmp/cardene777 \
  "$(cat "$PROMPT_FILE")" \
  > /private/tmp/cardene777/.context/local-review/codex-result.txt \
  2> /private/tmp/cardene777/.context/local-review/codex-stderr.txt
EC=$?
echo "$EC" > /private/tmp/cardene777/.context/local-review/codex-exit-code
echo "[Codex-fallback] exit=$EC outsize=$(wc -c < /private/tmp/cardene777/.context/local-review/codex-result.txt) bytes"
