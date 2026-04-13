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

if [ ! -f "$BINARY" ] || [ "$SOURCE" -nt "$BINARY" ]; then
    swiftc "$SOURCE" -o "$BINARY"
fi

"$BINARY"
