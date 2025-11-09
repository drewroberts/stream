#!/bin/bash
#
# setup.sh: Idempotent setup script for stream configurations.
#
# This script ensures that the necessary applications are installed and that their
# configuration directories are symbolically linked to the version-controlled
# directories within this repository.
#
# Adheres to the standards outlined in docs/standards.md.

# ---
# Configuration
# ---

# Exit immediately if a command exits with a non-zero status.
set -e

# Helper for colored output
log() {
    # BOLD, BLUE
    echo -e "\n\033[1;34m$1\033[0m"
}

# ---
# Main Execution
# ---

main() {
    log "Starting Stream Configuration Setup..."

    # Set repository root, assuming it's cloned in ~/Code
    local REPO_ROOT="$HOME/Code/stream"
    if [ ! -d "$REPO_ROOT" ]; then
        echo -e "\033[1;31mError: Repository not found at $REPO_ROOT\033[0m"
        echo "Please ensure the project is cloned into your '$HOME/Code' directory."
        exit 1
    fi
    cd "$REPO_ROOT"
    log "Repository root set to: $REPO_ROOT"

    # Step 1: Install required packages
    install_packages

    # Step 2: Create symbolic links
    create_symlinks "$REPO_ROOT"

    log "Setup complete. Your streaming configuration is now managed by this repository."
}

# ---
# Functions
# ---

#
# Installs required packages using an AUR helper.
#
install_packages() {
    log "Checking for required packages..."

    local packages=(
        "obs-studio"
        "streamdeck-ui-bin"
        "goxlr-utility-bin"
    )

    # Detect AUR helper (yay or paru)
    local AUR_HELPER
    if command -v yay &> /dev/null; then
        AUR_HELPER="yay"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
    else
        echo -e "\033[1;31mError: No AUR helper (yay or paru) found. Please install one to continue.\033[0m"
        exit 1
    fi

    log "Using '$AUR_HELPER' as the AUR helper."

    for pkg in "${packages[@]}"; do
        if ! pacman -Q "$pkg" &> /dev/null; then
            log "Package '$pkg' not found. Installing with $AUR_HELPER..."
            $AUR_HELPER -S --noconfirm "$pkg"
        else
            log "Package '$pkg' is already installed."
        fi
    done
}

#
# Creates idempotent symbolic links from the home directory to the repository.
#
# @param $1: The absolute path to the repository root.
#
create_symlinks() {
    local REPO_ROOT=$1
    log "Creating symbolic links..."

    # Define the links: "target_in_repo -> link_in_home"
    declare -A links=(
        ["$REPO_ROOT/obs"]="$HOME/.config/obs-studio"
        ["$REPO_ROOT/deck"]="$HOME/.config/streamdeck-ui"
        ["$REPO_ROOT/goxlr"]="$HOME/.config/goxlr-utility"
    )

    for target in "${!links[@]}"; do
        local link_name=${links[$target]}
        local link_dir
        link_dir=$(dirname "$link_name")

        # Ensure the parent directory of the link exists (e.g., ~/.config)
        mkdir -p "$link_dir"

        log "Processing link for: $(basename "$link_name")"

        # Check if the link destination already exists
        if [ -e "$link_name" ]; then
            if [ -L "$link_name" ]; then
                # It's a symlink. Check if it points to the correct target.
                if [ "$(readlink "$link_name")" = "$target" ]; then
                    echo "  -> Correct symlink already exists. Skipping."
                    continue
                else
                    echo "  -> Incorrect symlink found. Re-creating."
                    rm "$link_name"
                fi
            else
                # It's a file or directory. Back it up.
                local backup_name="$link_name.bak.$(date +%Y%m%d%H%M%S)"
                echo "  -> Existing directory/file found. Backing up to $backup_name"
                mv "$link_name" "$backup_name"
            fi
        fi

        echo "  -> Creating symlink: $link_name -> $target"
        ln -s "$target" "$link_name"
    done
}

# ---
# Entrypoint
# ---
main
