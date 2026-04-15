#!/usr/bin/env bash
# Claude Code Stop hook — spoken summary

INPUT=$(cat)
PROJ=$(basename "$PWD")
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Try to read the last assistant text from the transcript
TPATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
SUMMARY=""
if [ -n "$TPATH" ] && [ -f "$TPATH" ]; then
  SUMMARY=$(jq -r 'select(.type=="assistant") | .message.content[] | select(.type=="text") | .text' "$TPATH" 2>/dev/null \
    | grep -v '^$' \
    | tail -1 \
    | tr -d '\n' \
    | cut -c1-300)
fi

# Fallback: describe git changes
if [ -z "$SUMMARY" ]; then
  N=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
  if [ "${N:-0}" -gt 0 ] 2>/dev/null; then
    SUMMARY="Finished. $N files changed in $PROJ"
  else
    SUMMARY="Claude finished in $PROJ${BRANCH:+ on $BRANCH}"
  fi
fi

# Speak the summary
say "$SUMMARY" 2>/dev/null || true

# Create a persistent macOS notification
osascript -e "display notification \"$SUMMARY\" with title \"Claude\"" 2>/dev/null || true
