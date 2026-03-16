---
applyTo: "**/*"
---

## General

- Do not use grep. Use `rg` (ripgrep) for searching text in files
    - Instead of grep -R 'my_function', use rg 'my_function'.
- Do not use find. Use `fd` for finding files and directories
- use `gh` (GitHub CLI) instead of `git` when appropriate
    - use `GH_PAGER=cat` to disable paging when using `gh` commands that output to the terminal

## Citylitics

- use `yarn` instead of `npm`
