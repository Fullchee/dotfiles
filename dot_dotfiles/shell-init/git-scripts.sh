# common typos for git
alias it="git"
alias gti="git"

# Ensure we can define gc as a function even if an alias exists from elsewhere
# TODO: double check that I can remove these
# unalias gc 2>/dev/null
# unalias gt 2>/dev/null

# Some hooks (pre-commit, husky, etc.) may spawn background processes that
# write files after git exits. If that happens, the commit can fail and the
# working tree will have unstaged changes shortly after the hook exits.
#
# This helper polls for a few seconds and stages any discovered changes.
_stage_pending_hook_changes() {
    local -i max_attempts=50  # ~5s at 0.1s per attempt
    local -i attempt=0

    while (( attempt < max_attempts )); do
        # `git diff --quiet` exits 1 when there are unstaged changes.
        if ! git diff --quiet; then
            git add -u
            return 0
        fi

        sleep 0.1
        ((attempt++))
    done

    # Final attempt to stage anything that might have appeared just after.
    git add -u
}

gc() {
    git add -u

    # Attempt the commit
    if git commit -m "$*"; then
        return 0
    else
        echo "⚠️  Commit failed (pre-commit hook). Retrying once..."

        # Some hook runners (e.g. `pre-commit`, `husky`) may spawn background
        # processes that keep writing files after git exits. Poll for any unstaged
        # changes and stage them before retrying.
        _stage_pending_hook_changes

        # Second attempt
        if git commit -m "$*"; then
            echo "✅ Success on second try."
            return 0
        else
            echo "❌ Commit failed a second time. Please check your code."
            return 1
        fi
    fi
}

alias gs="git st"
alias fetchmerge="git fetch && git merge origin/main --no-edit"

# Fetch, then walk the Graphite stack from the bottom up, merging each branch with its remote
# and folding changes into its parent as we go.
fm() {
    git fetch

    # 1) Descend to the bottom of the stack.
    while gt down --no-interactive >/dev/null 2>&1; do
        :
    done

    while true; do
        local current_branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        echo "🔄 Updating branch '$current_branch'"
        git merge "origin/$current_branch" --no-edit || return 1

        if [[ "$current_branch" != "main" ]]; then
            git push
        fi

        local child_branch="$current_branch"

        # 2) Move up to the parent branch (if any)
        if ! gt up --no-interactive >/dev/null 2>&1; then
            # We're at the top of the stack.
            break
        fi

        local parent_branch
        parent_branch=$(git rev-parse --abbrev-ref HEAD)

        echo "🔀 Merging '$child_branch' into parent '$parent_branch'"
        git merge "$child_branch" --no-edit || return 1

        # Continue the loop; the next iteration will operate on the parent branch.
    done

    echo "✅ fm complete."
}

git-clone-personal() {
    local REPO_URL="$1"
    # 1. Define the command once
    local SSH_CMD="ssh -i ~/.ssh/personal_id_ed25519 -o IdentitiesOnly=yes"

    # 2. Use the variable for the initial clone
    GIT_SSH_COMMAND="$SSH_CMD" git clone "$REPO_URL"

    if [ $? -eq 0 ]; then
        local REPO_DIR
        REPO_DIR=$(basename "$REPO_URL" .git)

        cd "$REPO_DIR" || return

        # 3. Use the variable again to persist the config
        git config core.sshCommand 'ssh -i ~/.ssh/personal_id_ed25519 -o IdentitiesOnly=yes'
        git config user.email "11246258+Fullchee@users.noreply.github.com"
        git config user.signingkey ~/.ssh/personal_id_ed25519.pub
        git config gpg.format ssh
        git config commit.gpgsign true

        echo "✅ Cloned '$REPO_DIR' using personal identity."
    else
        echo "❌ Clone failed."
    fi
}

alias pull='git stash && git pull && git stash pop'
push() {
    git add -u

    # Attempt the commit
    if git commit -m "$*"; then
        git push
    else
        echo "⚠️  Commit failed (pre-commit hook). Retrying once..."

        # Some hook runners (e.g. `pre-commit`, `husky`) may spawn background
        # processes that keep writing files after git exits. Poll for any unstaged
        # changes and stage them before retrying.
        _stage_pending_hook_changes

        # Second attempt
        if git commit -m "$*"; then
            echo "✅ Success on second try."
            git push
        else
            echo "❌ Commit failed a second time. Please check your code."
            return 1
        fi
    fi
}

############### BRANCHES #####################

delete_current_branch() {
    branch_name="$(git rev-parse --abbrev-ref HEAD)"

    # Graphite (gt) can move between branches in a stack with `gt up` / `gt down`.
    # Capture the branches we'd switch to, without leaving the current branch.
    local gt_up_branch=""
    local gt_down_branch=""

    if command -v gt >/dev/null 2>&1; then
        local original_branch="$branch_name"

        # If there is a downstack branch (parent), capture it.
        if gt down --no-interactive >/dev/null 2>&1; then
            gt_down_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
            git checkout "$original_branch" >/dev/null 2>&1 || true
        fi

        # If there is an upstack branch (child), capture it.
        if gt up --no-interactive >/dev/null 2>&1; then
            gt_up_branch="$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
            git checkout "$original_branch" >/dev/null 2>&1 || true
        fi
    fi

    # if this repo is actually a worktree, git will report the path of the
    # superproject; we can use that to clean up the worktree directory and
    # return the user to the original repo root after deleting the branch.
    local superpath
    superpath=$(git rev-parse --show-superproject-working-tree 2>/dev/null)

    if [[ -n "$superpath" ]]; then
        # remember where we started so we can remove it and cd back
        local cwd="$PWD"

        cd "$superpath" || echo "⚠️  could not cd to superproject at $superpath"

        # Prefer switching to the gt upstack branch (if it exists), otherwise fall back to main.
        if [[ -n "$gt_up_branch" ]]; then
            git checkout "$gt_up_branch"
        else
            git checkout main
        fi

        git branch -D "$branch_name"

        # remove the worktree folder and leap back to the superproject
        git worktree remove "$cwd" && echo "✅ worktree removed: $cwd"

        # prune any stale worktree references
        git worktree prune
    else
        # Prefer switching to the gt upstack branch (if it exists), otherwise fall back to main.
        if [[ -n "$gt_up_branch" ]]; then
            git checkout "$gt_up_branch"
        else
            git checkout main
        fi

        git branch -D "$branch_name"
    fi

    # If we captured a downstack branch, update the new current branch to track it.
    # This makes sure Graphite's parent/child relationships remain wired after deletion.
    if command -v gt >/dev/null 2>&1 && [[ -n "$gt_down_branch" ]]; then
        gt track --parent "$gt_down_branch" 2>/dev/null || true
    fi
}
alias delete-current-branch=delete_current_branch

split-branch() {
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo "❌ Not a git repository." >&2
        return 1
    }

    if ! command -v gt >/dev/null 2>&1; then
        echo "❌ Graphite (gt) not found on PATH." >&2
        return 1
    fi

    if ! command -v fzf >/dev/null 2>&1; then
        echo "❌ fzf is required for selecting files." >&2
        return 1
    fi

    if [[ -n "$(git status --porcelain)" ]]; then
        echo "❌ Please commit or stash your working tree changes before running split_branch_files." >&2
        return 1
    fi

    local original_branch
    original_branch=$(git rev-parse --abbrev-ref HEAD)

    # Determine parent branch using Graphite's down command.
    local parent_branch=""
    if gt down --no-interactive >/dev/null 2>&1; then
        parent_branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        git checkout "$original_branch" >/dev/null 2>&1 || true
    fi

    if [[ -z "$parent_branch" ]]; then
        echo "❌ Unable to determine parent branch (not stacked?)." >&2
        return 1
    fi

    # Get modified files between current branch and parent branch.
    modified_files=("${(@f)$(git diff --name-only --diff-filter=ACMRTUXB "$parent_branch"..."$original_branch" | sort -u)}")

    if [[ ${#modified_files[@]} -eq 0 ]]; then
        echo "✅ No modified files between '$parent_branch' and '$original_branch'."
        return 0
    fi

    # Present the changed files via fzf. Preview the git diff for the file (parent..current).
    local selected
    selected=$(printf '%s\n' "${modified_files[@]}" | fzf --multi --ansi --prompt "Select files to split (TAB to multi-select): " \
        --header "Press TAB to select multiple files, ENTER to continue" \
        --preview "git diff --color=always '$parent_branch'...'$original_branch' -- {}" \
        --preview-window=right:60%)

    if [[ -z "$selected" ]]; then
        echo "⚠️  No files selected." >&2
        return 1
    fi

    # zsh doesn't have bash's mapfile; use zsh array capture instead.
    selected_files=("${(@f)$(printf '%s\n' "$selected")}")

    # Build a new branch name based on the DEV-#### prefix, or fallback.
    local ticket
    ticket=$(echo "$original_branch" | grep -oE 'DEV-[0-9]+' || true)
    local new_branch
    if [[ -n "$ticket" ]]; then
        new_branch="${ticket}-split"
    else
        new_branch="${original_branch}-split"
    fi

    # If this name already exists, keep appending "-split" until it's unique.
    while git show-ref --verify --quiet "refs/heads/$new_branch"; do
        new_branch="${new_branch}-split"
    done

    read -e -p "New branch name [${new_branch}]: " user_branch
    new_branch=${user_branch:-$new_branch}

    # 1) Create the new branch from the parent branch
    git checkout -b "$new_branch" "$parent_branch"

    # 2) Populate it with only the selected files from the original branch
    git checkout "$original_branch" -- "${selected_files[@]}"
    git add -- "${selected_files[@]}"
    if ! git diff --cached --quiet; then
        git commit -m "split: extract selected files into $new_branch" --no-verify
    else
        echo "⚠️  No changes to commit on $new_branch (selected files were already up to date)."
    fi

    # Ensure Graphite parent relationship for the new branch
    gt track --parent "$parent_branch" 2>/dev/null || true

    # 3) Return to the original branch and remove the selected files (they live in the new branch now)
    git checkout "$original_branch"
    git checkout "$parent_branch" -- "${selected_files[@]}"
    git add -- "${selected_files[@]}"
    if ! git diff --cached --quiet; then
        git commit -m "split: move selected files into $new_branch" --no-verify
    else
        echo "⚠️  No changes to commit on $original_branch; selected files already match $parent_branch."
    fi

    # 4) Merge the new branch into the original branch (do not rebase).
    #    This keeps the original branch history intact while bringing in the split commits.
    git checkout "$original_branch" || return 1
    git merge --no-ff "$new_branch" -m "merge: incorporate changes from $new_branch into $original_branch" || return 1

    # 5) Update Graphite parent/child relationships and restack.
    gt track --parent "$new_branch" 2>/dev/null || true
    gt restack 2>/dev/null || true

    echo "✅ Split complete."
    echo "New branch: $new_branch (parent: $parent_branch)"
    echo "Original branch now based on: $new_branch"
}

delete_remote_branch() {
    if read -q "choice?Delete remote branch? (Y/y)"; then
        branch_name="$(git rev-parse --abbrev-ref HEAD)"
        git push origin --delete "$branch_name"
    else
        echo "Not deleting remote branch"
        exit 1
    fi
}

delete_remote_and_local_branch() {
    if read -q "choice?Delete remote branch? (Y/y)"; then
        branch_name="$(git rev-parse --abbrev-ref HEAD)"
        git push origin --delete "$branch_name"
        delete_current_branch
    else
        echo "Not deleting remote branch"
        exit 1
    fi
}

# https://www.youtube.com/watch?v=lZehYwOfJAs
recent-branch() {
    # verify we're inside a git repository
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo "❌ Not a git repository." >&2
        return 1
    }

    local branch
    # ask git for branches without color so fzf doesn't pull in ANSI codes
    branch=$(git branch --sort=-committerdate --no-color |
        fzf --header "Checkout Recent Branch" \
            --preview "git diff {1} --color=always")
    [[ -z "$branch" ]] && return 0

    # strip ANSI color codes (escape sequences) so fzf output is clean
    branch=$(printf '%s' "$branch" | sed -E 's/\x1b\[[0-9;]*m//g')
    # remove leading markers (*, +, or whitespace) and trailing whitespace/carriage return
    branch=$(printf '%s' "$branch" | sed -E 's/^[*+[:space:]]+//;s/[[:space:]]+\r?$//')

    local worktree_path
    worktree_path=$(git worktree list --porcelain | awk -v b="$branch" '
        $1 == "worktree" { path=$2 }
        $1 == "branch" {
            br=$2
            sub("^refs/heads/", "", br)
            if (br == b) print path
        }
    ')

    if [[ -n "$worktree_path" ]]; then
        cd "$worktree_path"
    else
        git checkout "$branch"
    fi
}
alias rb=recent-branch


#################### Pull requests ####################

createpr() {
    local branch_name=""
    local commit_msg=""
    local OPTIND

    # Function to display help
    usage() {
        echo "Usage: createpr [-m \"message\"] [-h] [branch-name]  # branch-name defaults to current branch"
        echo ""
        echo "Options:"
        echo "  -m \"message\"  Create a real commit with the specified message."
        echo "                (Skips 'git empty-commit')"
        echo "  -h            Show this help message."
        echo ""
        echo "Example: createpr -m \"Initial setup\" feature/DEV-123-login-form"
    }

    # 1. Parse flags
    while getopts "m:h" opt; do
        case "$opt" in
        m) commit_msg=$OPTARG ;;
        h)
            usage
            return 0
            ;;
        *)
            usage
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # The first remaining argument is the branch name (optional)
    branch_name=$1

    # If no branch was passed, fall back to the current checked‑out branch.
    if [[ -z "$branch_name" ]]; then
        branch_name=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
        echo "⚙️  No branch argument provided, using current branch: $branch_name"
    fi

    # if we still don't have a branch (e.g. not in a repo), bail out
    if [[ -z "$branch_name" ]]; then
        echo "Error: Branch name is required and couldn't be determined." >&2
        usage
        return 1
    fi

    # 2. Git Operations
    git stash
    git switch -c "$branch_name"

    if [[ -n "$commit_msg" ]]; then
        # Create a real commit. --allow-empty is used so it doesn't fail
        # if you haven't staged any files yet.
        git commit -m "$commit_msg" --allow-empty
    else
        # Fallback to your custom .gitconfig alias
        git empty-commit
    fi

    git push origin "$branch_name"
    git set-upstream

    # 3. Validation & Extraction
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "master" || "$CURRENT_BRANCH" == "develop" ]]; then
        echo "Error: Cannot create a PR from branch '$CURRENT_BRANCH'." >&2
        return 1
    fi

    TICKET_ID=$(echo "$CURRENT_BRANCH" | awk -F'-' '{print $1 "-" $2}')
    RAW_DESCRIPTION=$(echo "$CURRENT_BRANCH" | sed "s/^$TICKET_ID-//")
    SPACED_DESCRIPTION=$(echo "$RAW_DESCRIPTION" | tr '-' ' ')
    DESCRIPTION_TITLE=$(echo "$SPACED_DESCRIPTION" | awk '{$1=toupper(substr($1,1,1)) tolower(substr($1,2)); print}')

    # 4. Construct PR Metadata
    PR_TITLE="[${TICKET_ID}] ${DESCRIPTION_TITLE}"
    PR_BODY="# ${PR_TITLE}

## Changes

- ${DESCRIPTION_TITLE}

## Review instructions

1.

## ``/verify-changes``


"

    # 5. Create PR via GitHub CLI
    gh pr create \
        --title "$PR_TITLE" \
        --body "$PR_BODY" \
        --assignee "@me" \
        --draft

    git stash pop
    gh pr view --web
}

# gh cuts off the URL
alias gh-pr-checks='gh pr checks | cat'

prfiles() {
    PR_URL=$(gh pr view --json url --jq '.url')
    open "${PR_URL}/files"
}

pulls() {
    GH_FORCE_TTY=100% gh pr list --assignee "fullchee" | tail -n +2 | fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr view --web
}

switchpr() {
    GH_FORCE_TTY=100% gh pr list --assignee "fullchee" | tail -n +2 | fzf --ansi --preview 'GH_FORCE_TTY=100% gh pr view {1}' --preview-window down --header-lines 3 | awk '{print $1}' | xargs gh pr checkout
}

alias viewpr="gh pr view --web"

############### WORKTREES ###################

cwt() {
    # 1. Configuration
    local MAIN_BRANCH="main"
    local CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if we are even in a git repo
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: Not a git repository."
        return 1
    fi

    # Find the absolute path to the root of the current repo
    local REPO_ROOT=$(git rev-parse --show-toplevel)
    local REPO_NAME=$(basename "$REPO_ROOT")

    local BRANCH=${1:-$CURRENT_BRANCH}
    local NAME=${2:-$BRANCH}

    # 2. Logic Change: Move up from the REPO_ROOT to create the sibling directory
    # This turns ~/watrhub-django/app/frontend/app -> ~/DEV-4472-eslint-upgrade
    local TARGET_DIR="$(dirname "$REPO_ROOT")/$NAME"

    # 3. Safety Check: Is the branch already checked out here?
    if [[ "$BRANCH" == "$CURRENT_BRANCH" ]]; then
        echo "⚠️ Branch '$BRANCH' is active here. Switching this folder to '$MAIN_BRANCH' first..."
        if ! git checkout "$MAIN_BRANCH"; then
            echo "❌ Error: Could not switch to $MAIN_BRANCH. Do you have uncommitted changes?"
            return 1
        fi
    fi

    # 4. Validation: Does the target directory exist?
    if [[ -d "$TARGET_DIR" ]]; then
        echo "❌ Error: Directory '$TARGET_DIR' already exists."
        return 1
    fi

    # 5. Create the Worktree
    echo "Creating worktree for '$BRANCH' at '$TARGET_DIR'..."

    if git rev-parse --verify "$BRANCH" >/dev/null 2>&1; then
        git worktree add "$TARGET_DIR" "$BRANCH"
    else
        echo "Branch '$BRANCH' not found. Creating new branch..."
        git worktree add -b "$BRANCH" "$TARGET_DIR"
    fi

    # 6. Jump to the new worktree
    if [[ $? -eq 0 ]]; then
        cd "$TARGET_DIR"
        # Optional: if you want to land back in the 'app/frontend/app' equivalent
        # in the new worktree, we could add logic for that here.
        echo "✅ Done! You are now in the worktree for '$BRANCH'."
    fi
}

worktree() {
    # 1. Check if we're in a git repo
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
        echo "Not a git repository"
        return 1
    }

    # 2. Format the list: [Folder Name] [Branch] [Full Path (Hidden)]
    # We use awk to print the last part of the path, the branch, and the full path
    local selection=$(git worktree list | awk '{
        n = split($1, path, "/");
        print path[n], $3, $1
    }' | column -t | fzf \
        --header "Select Worktree (Folder | Branch)" \
        --with-nth "1,2" \
        --preview "git log --oneline -n 10 \$(echo {2} | tr -d '[]')")

    # 3. The full path is the 3rd column of our custom list
    local target=$(echo "$selection" | awk '{print $NF}')

    if [ -n "$target" ]; then
        cd "$target"
    fi
}

rm-worktree() {
    # Supports optional argument: path to remove. Otherwise show interactive fzf picker.
    local target

    if [[ -n "$1" ]]; then
        target="$1"
    else
        # Select the worktree interactively
        local selected
        selected=$(git worktree list | fzf --header "Delete Worktree (Enter to Confirm)" --preview "git log --oneline -n 10 {3}")
        # Extract the path (first column)
        target=$(echo "$selected" | awk '{print $1}')
    fi

    if [ -n "$target" ]; then
        # Check if it's the main/current worktree to prevent accidents
        git worktree remove "$target" && echo "Worktree at $target removed."
    fi
}

wt-collapse() {
    # 1. Identify the branch name of the current worktree
    local branch_name=$(git rev-parse --abbrev-ref HEAD)
    local worktree_path=$(git rev-parse --show-toplevel)

    # 2. Figure out if we're in a submodule/worktree of a superproject.
    #    If so, `git rev-parse --show-superproject-working-tree` will return
    #    the path to the superproject; otherwise it prints nothing.
    local superpath
    superpath=$(git rev-parse --show-superproject-working-tree 2>/dev/null)

    echo "📁 Detected superproject at $superpath, switching there..."
    cd "$superpath" || echo "⚠️ could not cd to superproject at $superpath"

    # 3. Remove the worktree using the helper function (can be interactive elsewhere)
    # This removes the directory and cleans up .git/worktrees/
    echo "Removing worktree at $worktree_path..."
    rm-worktree "$worktree_path"

    # 4. Checkout the branch in the main repo
    echo "Switching to branch '$branch_name' in the main repository..."
    git checkout "$branch_name"
}
