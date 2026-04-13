#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Paste PR or Jira Link
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🔗

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE="$SCRIPT_DIR/paste-pr-or-jira-link.swift"
BINARY="$SCRIPT_DIR/.paste-pr-or-jira-link"

CHECKSUM_FILE="$SCRIPT_DIR/.paste-pr-or-jira-link.md5"
CURRENT=$(md5 -q "$SOURCE")
STORED=$(cat "$CHECKSUM_FILE" 2>/dev/null)

if [ "$CURRENT" != "$STORED" ] || [ ! -f "$BINARY" ]; then
    swiftc "$SOURCE" -o "$BINARY" && echo "$CURRENT" > "$CHECKSUM_FILE"
fi

"$BINARY"
