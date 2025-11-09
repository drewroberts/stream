# Architecture: Symlink-Based Configuration Management

This document provides a detailed explanation of the symbolic link (`symlink`) architecture used in this project to manage streaming application configurations.

---

## The Problem: Volatile Configurations

The configuration files for applications like OBS Studio, Stream Deck, and the GoXLR Utility are typically stored in the user's home directory (e.g., `~/.config/`). These files are:
-   **Volatile:** They change frequently as you adjust scenes, create profiles, and tweak settings.
-   **Isolated:** They are tied to a single machine, making it difficult to replicate a setup or recover from a system failure.
-   **Opaque:** It's hard to track *what* changed, *when*, and *why*.

Traditional backup methods (like copying the folder) are manual, error-prone, and lack the benefits of version control.

---

## The Solution: Declarative Symlinking

This project solves the problem by treating your local configuration files not as the source of truth, but as a **local cache** of the true configuration, which lives in this Git repository.

The core mechanism is the **symbolic link**.

### How It Works

1.  **Source of Truth:** The directories within this repository (`obs/config/`, `deck/config/`, `goxlr/config/`) are the definitive source of truth for your configuration.

2.  **The `setup.sh` Script:** When you run the `setup.sh` script, it performs a critical, one-time swap on your local machine:
    -   It finds the original application config directory (e.g., `~/.config/obs-studio`).
    -   It renames this directory to create a backup (e.g., `~/.config/obs-studio.bak`).
    -   It creates a new symbolic link at the original location (`~/.config/obs-studio`) that points directly to the corresponding directory inside this Git repository.

    The command looks like this:
    ```bash
    # ln -s /path/to/your/git/repo/stream/obs/config ~/.config/obs-studio
    ```

3.  **Transparent Operation:** From the application's perspective, nothing has changed. OBS Studio still reads and writes its files to `~/.config/obs-studio`. However, because that path is now a symlink, the operating system automatically redirects all file operations to the directory inside the Git repository.

### The Workflow in Practice

-   **Making a Change:** You open OBS and add a new scene. OBS saves this change to `~/.config/obs-studio/basic/scenes/Untitled.json`. Because of the symlink, this file is actually created at `.../stream/obs/config/basic/scenes/Untitled.json`.

-   **Committing the Change:** You run `./sync.sh`. The script runs `git status` inside the `stream` repository, sees the new file `obs/config/basic/scenes/Untitled.json`, and automatically adds, commits, and pushes it.

-   **Restoring a Setup:** You get a new computer. You clone the `stream` repository and run `./setup.sh`. The script creates the symlinks, pointing your new, empty `~/.config` directories to the configuration stored in Git. When you launch OBS, all your scenes, profiles, and settings are instantly available.

---

## Benefits of This Architecture

-   **Atomicity & Auditability:** Every configuration change becomes a Git commit. You can see exactly what changed, revert to a previous state, or even branch your configuration to test new ideas without affecting your main setup.
-   **Portability & Disaster Recovery:** Your entire streaming identity is contained within this repository. Restoring your setup on a new machine is as simple as `git clone` and `./setup.sh`.
-   **Standardized Development:** By convention, all custom OBS browser sources use Tailwind CSS, ensuring a consistent and maintainable approach to on-screen graphics.

---

## The Workflow in Practice
// ...existing code...
