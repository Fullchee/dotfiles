####################### gcloud setup #######################

# The next line updates PATH for the Google Cloud SDK.
export GCLOUD_SDK_ROOT="$HOME/google-cloud-sdk"
if [ -f "$GCLOUD_SDK_ROOT/path.zsh.inc" ]; then . "$GCLOUD_SDK_ROOT/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$GCLOUD_SDK_ROOT/completion.zsh.inc" ]; then . "$GCLOUD_SDK_ROOT/completion.zsh.inc"; fi

export STAGING_PROJECT=dev-review-env
export PROD_PROJECT=crawler-147820
export PROJECT_ID=$STAGING_PROJECT # used when copy pasting from the docs

alias standup="o 'https://citylitics.slack.com/archives/C05S32S0L3F'"
alias standup-thread="o 'https://citylitics.slack.com/archives/C05S32S0L3F/p1770991207827789?thread_ts=1769702556.260099&cid=C05S32S0L3F'"

####################### CI/CD #######################

deploy-sha-to-prod() {
    gcloud builds triggers run citylitics-app-ci-cd-production --project=crawler-147820 --sha="$1"
    watch-cloud-build main
}

deploy-sha-to-staging() {
    local COMMIT_SHA=$(git -C ~/watrhub-django rev-parse HEAD)

    gcloud builds triggers run citylitics-app-ci-cd --sha="$COMMIT_SHA"
    watch-cloud-build "$COMMIT_SHA"
}

frontend-pr-cloud-build() {
    gh pr checks --json name,link | jq -r '.[] | select(.name | contains("frontend")) | .link' | xargs open
}

gcloud-build-run-frontend-trigger() {
    gcloud builds triggers run citylitics-app-ci-frontend --branch="$(git branch --show-current)"
    gh pr checks --watch && say "GitHub CI/CD finished"
}

gcloud-build-run-main-trigger() {
    gcloud builds triggers run citylitics-app-ci-cd --branch="$(git branch --show-current)"
    gh pr checks --watch && say "GitHub CI/CD finished"
}

view-cloud-build-run() {
    # 1. Get the current branch name
    local branch=$(git branch --show-current 2>/dev/null)

    if [ -z "$branch" ]; then
        echo "Error: Not in a git repository or no branch found."
        return 1
    fi

    # 2. Fetch builds, select with fzf, and open URL
    # We use --format 'value(logUrl)' at the end of the pipe to ensure we only open the link
    local selected_run=$(gcloud builds list \
        --filter="substitutions.BRANCH_NAME=$branch" \
        --limit=5 \
        --format="table[box](status, startTime, id, logUrl)" |
        fzf --header="Recent builds for: $branch" --header-lines=1 --reverse)

    if [ -n "$selected_run" ]; then
        # Extract the URL (the last item in the row)
        local url=$(echo "$selected_run" | awk '{print $NF}')

        # Open based on OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            open "$url"
        else
            xdg-open "$url"
        fi
    else
        echo "No run selected."
    fi
}
watch-cloud-build() {
    local INPUT=${1:-$(git branch --show-current 2>/dev/null)}
    INPUT=${INPUT:-main}

    local FILTER=""
    if [[ $INPUT =~ ^[0-9a-f]{40}$ ]]; then
        FILTER="source.repoSource.commitSha='$INPUT'"
    else
        FILTER="substitutions.BRANCH_NAME='$INPUT'"
    fi

    echo "Waiting for latest build on $INPUT..."

    # 1. Define the logic as a raw shell command string
    # We use 'pkill -P' to kill the process group or use the specific PID
    local AFTER_CMD="status=\$(gcloud builds list --filter=\"$FILTER\" --limit=1 --format=\"value(status)\");
    case \"\$status\" in
        SUCCESS|FAILURE|TIMEOUT|FAILED|CANCELLED) pkill -INT hwatch ;;
    esac"

    # 2. Run hwatch
    # We use -n 10 for the interval and --aftercommand to trigger the logic
    hwatch -n 10 --color --no-title \
        --aftercommand "$AFTER_CMD" \
        "gcloud builds list --filter=\"$FILTER\" --limit=1 --format=\"table(id,status,startTime,duration)\""

    # 3. Handle results once hwatch exits
    echo -e "\nBuild reached terminal state. Finalizing..."
    local FINAL_DATA=$(gcloud builds list --filter="$FILTER" --limit=1 --format="value(status)")

    case "$FINAL_DATA" in
        SUCCESS)
            echo -e "✅ Build Succeeded! \a"
            return 0
            ;;
        FAILURE|TIMEOUT|FAILED)
            echo -e "❌ Build failed: $FINAL_DATA \a"
            why-cloud-build-failed "$INPUT"
            return 1
            ;;
        CANCELLED)
            echo -e "🛑 Build was cancelled."
            return 1
            ;;
    esac
}
why-cloud-build-failed() {
    local BRANCH=${1:-$(git branch --show-current 2>/dev/null)}
    BRANCH=${BRANCH:-main}
    local ID=$(gcloud builds list --filter="substitutions.BRANCH_NAME='$BRANCH' AND status=FAILURE" --limit=1 --format="value(id)")
    [[ -n "$ID" ]] && gcloud builds log "$ID" | grep -A 50 "Step #$(gcloud builds describe $ID --format='value(steps.filter(status="FAILURE").index())')"
}

####################### Cloud SQL #######################

CLOUD_SQL_REGION=us-east1
CLOUD_SQL_PORT=3307 # 3306: default MySQL port

staging-cloud-sql-proxy() {
    cloud-sql-proxy "${STAGING_PROJECT}:${CLOUD_SQL_REGION}:nautilus-staging-zonal-ssd" \
        --address 0.0.0.0 \
        --port "$CLOUD_SQL_PORT"
}
prod-cloud-sql-proxy() {
    cloud-sql-proxy "${PROD_PROJECT}:${CLOUD_SQL_REGION}:crawler-db-replica" \
        --address 0.0.0.0 \
        --port "$CLOUD_SQL_PORT"
}

####################### Cloud Workstation #######################

# WORKSTATION_NAME="w-fullchee-dev24"
WORKSTATION_NAME="w-fullchee-jan9-2026"
WORKSTATION_COMMON_ARGS=(
    --project=dev-cloud-sandbox
    --region=us-central1
    --cluster=dev-team-workstation-test-cluster
    --config=config-custom-image
)

start-workstation() {
    gcloud workstations start "$WORKSTATION_NAME" \
        "${WORKSTATION_COMMON_ARGS[@]}"
}

stop-workstation() {
    gcloud workstations stop "$WORKSTATION_NAME" \
        "${WORKSTATION_COMMON_ARGS[@]}"
}

list-workstations() {
    gcloud workstations list "${WORKSTATION_COMMON_ARGS[@]}"
}

ssh-workstation() {
    gcloud workstations ssh "$WORKSTATION_NAME" \
        "${WORKSTATION_COMMON_ARGS[@]}" \
        --ssh-flag="-X"
    set-terminal-tab-title ""
}

port-forward-workstation() {
    set-terminal-tab-title '🔌➡️🔌 port-forward-workstation'
    # Note: start-tcp-tunnel requires the port (22) immediately after the name
    gcloud workstations start-tcp-tunnel "$WORKSTATION_NAME" 22 \
        "${WORKSTATION_COMMON_ARGS[@]}" \
        --local-host-port=:2222
}

FE_WORKSTATION_URL() {
    open "https://3000-$WORKSTATION_NAME.cluster-imye5lsddna6qt42y36q64ugfk.cloudworkstations.dev"
}
BE_WORKSTATION_URL() {
    open "https://4000-$WORKSTATION_NAME.cluster-imye5lsddna6qt42y36q64ugfk.cloudworkstations.dev"
}


############ Connect to server ########

ssh-staging() {
    gcloud compute ssh staging-server --project=dev-review-env --zone=us-east1-b
}

# enter the nginx
# docker exec -it deployment-nginx-1 /bin/bash
####################### Local dev #######################

PATH="/usr/local/opt/mysql@8.4/bin:$PATH"

copilot-instructions-repo-to-dotfiles() {
    local SRC="$HOME/watrhub-django/.github/instructions"
    local DEST="$HOME/.dotfiles/citylitics/copilot-instructions"
    rm -rf "$DEST"
    cp -r "$SRC" "$DEST"
    config add "$DEST"
}

copilot-instructions-dotfiles-to-repo() {
    local DEST="$HOME/watrhub-django/.github/instructions"
    local SRC="$HOME/.dotfiles/citylitics/copilot-instructions"
    rm -rf "$DEST"
    cp -r "$SRC" "$DEST"
}

alias mw='make -C ~/watrhub-django'

open-ticket() {
    # 1. Get the current branch name
    local branch=$(git -C ~/watrhub-django rev-parse --abbrev-ref HEAD 2>/dev/null)

    # Check if we are actually in a git repo
    if [ -z "$branch" ]; then
        echo "Error: Could not find git repo at ~/watrhub-django"
        return 1
    fi

    # 2. Extract the ticket ID (e.g., DEV-4421) using regex
    # This looks for any uppercase letters followed by a dash and numbers
    local ticket=$(echo "$branch" | grep -oE '[A-Z]+-[0-9]+')

    if [ -n "$ticket" ]; then
        local url="https://citylitics.atlassian.net/browse/$ticket"
        echo "Opening $url..."
        open "$url"
    else
        echo "Error: No ticket ID (e.g., DEV-0000) found in branch name: $branch"
        return 1
    fi
}

sb() {
    set-terminal-tab-title start-backend
    cd ~/watrhub-django || exit
    make start-backend
}

sf() {
    set-terminal-tab-title start-frontend
    cd ~/watrhub-django || exit
    make start-frontend
}
alias cdf="cd ~/watrhub-django/app/frontend/app"

y() {
    command yarn --cwd /Users/admin/watrhub-django/app/frontend/app "$@"
}

yarntest() {
    command yarn --cwd /Users/admin/watrhub-django/app/frontend/app test --no-watchAll --collectCoverage=false "$@"
}

#######################

