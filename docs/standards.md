# Project Standards & Development Philosophy

This document outlines the architectural principles and development standards for the `stream` repository. The core philosophy is **Declarative Automation for Personal Configuration**: we define the *desired state* of the local streaming environment in this version-controlled repository and use clean, robust scripts to make the local machine match that state.

This is not just about backing up files; it's about treating personal application settings as a manageable, recoverable, and auditable codebase.

---

## 1. The Symlink is the Contract

-   **Principle:** The primary architectural pattern is the symbolic link. The Git repository is the **source of truth**, and the local configuration directories (e.g., `~/.config/obs-studio`) are merely pointers to it.

-   **Implementation:**
    -   The `setup.sh` script is responsible for establishing this contract by creating the necessary symlinks.
    -   Scripts must never write directly to `~/.config/` paths. They should operate on the repository's directories, and the symlinks ensure the applications see the changes.
    -   The `sync.sh` script completes the loop, taking changes made by applications (via the symlink) and committing them back to the source of truth.

---

## 2. Scripts Must Be Idempotent and Safe

-   **Principle:** All automation scripts must be safely re-runnable without causing errors or data loss. The `setup.sh` script should be able to run on a fresh install or a fully configured machine and result in the same correct state.

-   **Implementation:**
    -   **Check, Then Act:** Before creating a symlink, check if a file, directory, or another symlink already exists at the destination.
    -   **Backup, Don't Destroy:** If an existing configuration is found, it must be backed up with a timestamp (`mv path path.bak.timestamp`) rather than being deleted.
    -   **Verify Installation:** Check if a package is already installed (`pacman -Q <pkg>`) before attempting to install it.
    -   **Assume Nothing:** Scripts should not assume they are being run from a specific directory. Hardcode paths (like `$HOME/Code/stream`) to ensure consistent behavior.

---

## 3. Structure is Intentional and Self-Documenting

-   **Principle:** The repository's layout is designed to be intuitive, with a clear separation of concerns that reveals the project's purpose at a glance.

-   **Implementation:**
    -   **Root-Level Scripts:** The primary user-facing scripts (`setup.sh`, `sync.sh`) reside at the root.
    -   **Centralized Documentation (`docs/`):** All markdown-based documentation, including this standards guide and the architectural overview, is located in the `docs/` directory.
    -   **Component-Specific Directories:** Each managed application has a top-level directory (`obs/`, `deck/`, `goxlr/`).
    -   **Browser Sources use Tailwind CSS:** Any custom HTML/CSS/JS developed for OBS browser sources (located in `obs/browser-sources/`) should utilize Tailwind CSS via the CDN for rapid, consistent, and maintainable styling.
    -   **Configuration Targets (`config/`):** Inside each component directory, a `config/` folder serves as the explicit target for the symlink. This avoids ambiguity.

---

## 4. Documentation Precedes Implementation

-   **Principle:** We document the plan, architecture, and usage instructions *before* writing the code. This forces clarity of thought and ensures the final product aligns with the initial goals.

-   **Implementation:**
    -   **`README.md` as the Gateway:** The main `README.md` provides the high-level "what" and "why," along with a quick-start guide for immediate use.
    -   **`architecture.md` as the Blueprint:** This document details the "how," explaining the symlink strategy, the role of each script, and the overall workflow. It is the technical constitution of the project.
    -   **Clarity Through Formatting:** Use Markdown tables, code blocks, and diagrams to make complex information easy to digest.

---

## 5. Scripts are Built for Humans

-   **Principle:** A script should be easy for a human to read, understand, and debug.

-   **Implementation:**
    -   **Strict Mode:** Scripts start with `set -e` to ensure they exit immediately on error, preventing unexpected behavior.
    -   **Clear Logging:** Use a simple `log()` function to print color-coded, informative messages, showing the user what the script is doing at each step.
    -   **Modular Functions:** Break down logic into small, single-purpose functions with descriptive names (e.g., `install_packages`, `create_symlinks`).
    -   **Abundant Comments:** Explain the "why" behind non-obvious commands or configuration choices.

