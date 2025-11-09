#!/bin/bash
#
# sync.sh: A helper script to synchronize local configuration changes to the Git repository.
#
# This script automates the process of adding, committing, and pushing any changes
# made to the tracked configuration files. It's designed for quick, one-click
# execution, for example, via a Stream Deck button or a keyboard shortcut.
#
# Adheres to the standards outlined in docs/standards.md.

# ---
# Configuration
# ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Helper for colored output
log() {
    # BOLD, GREEN
    echo -e "\n\033[1;32m$1\033[0m"
}

# ---
# Main Execution
# ---

main() {
    log "Starting Configuration Synchronization..."

    # Navigate to the repository root to ensure we're in the right place.
    local REPO_ROOT="$HOME/Code/stream"
    if [ ! -d "$REPO_ROOT" ]; then
        echo -e "\033[1;31mError: Repository not found at $REPO_ROOT\033[0m"
        echo "Please ensure the project is cloned into your '$HOME/Code' directory."
        exit 1
    fi
    cd "$REPO_ROOT"
    log "Changed directory to repository root: $(pwd)"

    # Check for an upstream branch
    if ! git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        echo -e "\033[1;31mError: No upstream branch is set for the current branch.\033[0m"
        echo "Please push the branch to the remote repository first, e.g., 'git push --set-upstream origin main'"
        exit 1
    fi

    # Check for local changes
    if git diff-index --quiet HEAD --; then
        log "No changes detected. Configuration is already in sync."
        exit 0
    fi

    log "Changes detected. Proceeding with synchronization."

    # Add all changes
    log "Adding all changes to the staging area..."
    git add .

    # Commit the changes
    local commit_message
    commit_message="chore(config): sync configuration changes at $(date +'%Y-%m-%d %H:%M:%S')"
    log "Committing changes with message: '$commit_message'"
    git commit -m "$commit_message"

    # Push the changes
    log "Pushing changes to the remote repository..."
    git push

    log "Synchronization complete."
}

# ---
# Entrypoint
# ---
main
