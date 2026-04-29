#!/bin/bash
# CodeRabbit CLI review runner
set +e
cd /private/tmp/cardene777

CR_CMD=/opt/homebrew/bin/coderabbit

# CLAUDE.md は ~/.claude にあるが本 repo は cardene777 で関係薄い。AP-011 回避のためサイズ確認のみ。
CLAUDE_MD_OPT=""
if [ -f "$HOME/.claude/CLAUDE.md" ]; then
  lines=$(wc -l < "$HOME/.claude/CLAUDE.md")
  if [ "$lines" -le 200 ]; then
    CLAUDE_MD_OPT="-c $HOME/.claude/CLAUDE.md"
  fi
fi

"$CR_CMD" review \
  -c .context/local-review/local-review-context.md \
  -c .context/local-review/patterns-filtered.md \
  $CLAUDE_MD_OPT \
  -c .coderabbit.yaml \
  --base main \
  --plain \
  > .context/local-review/cr-result.txt \
  2> .context/local-review/cr-stderr.txt
echo $? > .context/local-review/cr-exit-code
echo "[CR] exit=$(cat .context/local-review/cr-exit-code) outsize=$(wc -c < .context/local-review/cr-result.txt) bytes"
