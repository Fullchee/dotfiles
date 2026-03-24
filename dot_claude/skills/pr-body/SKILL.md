---
name: pr-body
description: Generate a PR body in markdown (Changes + Review instructions) based on a git diff.
user-invokable: true
argument-hint: "[diff-range (default: parent..HEAD)]"
---

# PR Body from Git Diff

Generate a concise PR description (two sections: **Changes** and **Review instructions**) from a git diff.

## Prompt

The prompt used for generation is stored here:

- `.claude/skills/pr-body/prompt.txt`

## Usage

### Claude CLI (recommended)

```bash
# Use the current branch compared to its parent
PARENT=origin/main
BRANCH=$(git rev-parse --abbrev-ref HEAD)
git diff "$PARENT"..."$BRANCH" | claude --agent pr-body
```

### `llm` / other LLM helpers

```bash
git diff origin/main...HEAD | llm -s "$(cat .claude/skills/pr-body/prompt.txt)"
```

## Notes

- If the prompt file is missing, tooling should fall back to an embedded default prompt.
- For repository-level automation, keep the prompt in `.claude/skills/pr-body/prompt.txt` so it can be updated and reviewed in source control.
