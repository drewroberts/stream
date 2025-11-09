# Stream Configuration Management

This repository provides a centralized, version-controlled management system for a complete streaming setup on Arch Linux. It uses a combination of idempotent shell scripts and symbolic links to manage the configuration of OBS Studio, Elgato Stream Deck, and the GoXLR audio interface.

This is my setup for livestream & all creator software. I use OBS on Arch Linux with GoXLR for audio on Shure SM7B mic & multiple computers sharing video/audio through Black Magic Atem Mini Pro & Atem Mini. I also have the large and the 15 button Elgato Stream Decks hooked to the 2 main desktops (one has OBS & the other uses Streamyard & the Elgato Prompter).

The core philosophy is **Declarative Automation**: the desired state of the streaming configuration is defined in this Git repository, and automation scripts are used to ensure the local machine's configuration matches this state.

---

## Core Components

This system manages the configuration for the following core components, which are expected to be installed from the Arch User Repository (AUR):

| Component | AUR Package | Purpose |
| :--- | :--- | :--- |
| **OBS Studio** | `obs-studio` | Primary software for video streaming and recording. |
| **Elgato Stream Deck** | `streamdeck-ui-bin` | Control software for the Elgato Stream Deck. |
| **GoXLR Utility** | `goxlr-utility-bin` | Control software and daemon for the TC-Helicon GoXLR. |
| **Elgato Prompter** | (N/A) | Controlled via the Stream Deck plugin; no separate app. |

---

## Architecture Overview

This repository does not store the software itself, but rather the **configuration files** for each application. The primary mechanism is the use of **symbolic links** (`symlinks`).

1.  The live configuration directories (e.g., `~/.config/obs-studio`) are replaced with symlinks.
2.  These symlinks point to the corresponding directories within this Git repository (e.g., `stream/obs/config/`).
3.  Applications continue to read/write to their standard locations, but the data is actually being stored in the Git-controlled folder.

This architecture provides several key benefits:
-   **Version Control:** Every change to your OBS scenes, Stream Deck profiles, or GoXLR settings can be tracked, committed, and audited.
-   **Disaster Recovery:** If a machine fails, you can run a single script on a new Arch Linux machine to restore your entire streaming setup in minutes.
-   **Synchronization:** Keep multiple machines in sync with the same configuration.

For a more detailed explanation, see the **[Architecture Guide](docs/architecture.md)**.

---

## Quick Start

This repository is managed by two primary scripts.

### 1. Initial Setup (`setup.sh`)

To configure a new Arch Linux machine, run the `setup.sh` script. This script assumes the repository is cloned into `$HOME/Code/stream`.

```bash
# Navigate to your Code directory and clone the repository
mkdir -p $HOME/Code
cd $HOME/Code
git clone https://github.com/drewroberts/stream.git

# Run the setup script (can be run from anywhere)
$HOME/Code/stream/setup.sh
```

The script will automatically:
1.  Install the required AUR packages (`obs-studio`, `streamdeck-ui-bin`, `goxlr-utility-bin`).
2.  Back up any existing local configurations.
3.  Create the necessary symbolic links.

### 2. Daily Synchronization (`sync.sh`)

After making changes to your setup (e.g., modifying an OBS scene or a Stream Deck button), run the `sync.sh` script to commit and push all changes to the Git repository.

This can be bound to a hotkey or a Stream Deck button for one-click backups. The script can be run from any directory.

```bash
# Run the sync script
$HOME/Code/stream/sync.sh
```

The script will automatically add, commit, and push any detected changes in your configuration directories.

---

## Repository Structure

```
.
├── .gitignore
├── README.md
├── docs/
│   ├── architecture.md
│   └── standards.md
├── setup.sh
├── sync.sh
├── obs/
│   ├── browser-sources/
│   └── config/
├── deck/
│   └── config/
└── goxlr/
    └── config/
```
