# Project Standards & Development Philosophy

This document outlines the architectural principles and development standards for projects in this repository. Our core philosophy is **Declarative Automation**: we define the *desired state* of a system in version control and use clean, robust scripts to make reality match that state.

---

## 1. Automation is King, Idempotency is the Law

-   **Principle:** Every script must be safely re-runnable without causing errors or unintended side effects. The system should converge to the desired state, regardless of its starting state.

-   **Implementation:**
    -   Use `helm upgrade --install` instead of `helm install` for Helm charts.
    -   Use `kubectl apply -f <file>` instead of `kubectl create` for Kubernetes manifests.
    -   Check for the existence of resources (files, directories, Kubernetes secrets) before creating them (e.g., `if ! command -v foo &> /dev/null`).
    -   Where appropriate, use configuration checksums (`sha256sum`) to determine if a resource needs to be updated and a service needs to be restarted.

---

## 2. Structure is Intentional and Predictable

-   **Principle:** A repository's layout should be self-explanatory, with a clear separation of concerns that reveals the project's architecture at a glance.

-   **Implementation:**
    -   **Top-Level Action Scripts:** Core, user-facing executable scripts reside at the root of the repository.
    -   **Dedicated `docs/` Directory:** All markdown-based documentation is centralized in a `docs/` folder.
    -   **Configuration Directories:** Component-specific configuration files are grouped into their own directories (e.g., `monitoring/` for `values.yaml`, `k8s/` for manifests).

---

## 3. Documentation is a First-Class Citizen

-   **Principle:** Documentation must be comprehensive, clear, and serve specific purposes. It is not an afterthought but an integral part of the deliverable.

-   **Implementation:**
    -   **`README.md` as the Gateway:** The main `README.md` serves as a high-level introduction and a "Quick Start" guide, linking out to more detailed documents.
    -   **The "Plan" Document:** A master specification (`plan.md`) defines the high-level architecture, security principles, and operational phases. This acts as the project's constitution.
    -   **"How-To" Guides:** Specific, task-oriented documents (`expansion.md`, `nfs.md`, `githubci.md`) provide step-by-step instructions for complex operations.
    -   **Effective Markdown:** Consistently use tables for structured data, code blocks for commands, and blockquotes for important callouts to improve readability.

---

## 4. Scripts are Built for Humans

-   **Principle:** A script should be easy to understand, use, and debug for anyone (including your future self).

-   **Implementation:**
    -   **Robust Script Headers:** Always start with `#!/bin/bash` and `set -euo pipefail` to ensure predictable behavior and fail-fast execution.
    -   **Clear Logging:** Provide verbose, color-coded feedback to the user about what the script is doing (`log`, `error` functions).
    -   **Modular Functions:** Break down complex scripts into smaller, single-purpose functions with descriptive names (e.g., `prepare_host_system`, `deploy_plg_stack`).
    -   **Input Validation:** Scripts that require arguments must validate them and provide a clear `usage()` message if they are incorrect.

---

## 5. Configuration is Data, Not Code

-   **Principle:** Avoid hardcoding configuration values directly into scripts. Extract them into dedicated, human-readable files to separate logic from data.

-   **Implementation:**
    -   Use Helm `values.yaml` files to manage complex application settings.
    -   Use simple text files (`pkglist.txt`) as a data source for scripts to read from.
    -   Use Kubernetes `ConfigMap` objects to manage application environment variables, keeping them separate from the `Deployment` manifest.
