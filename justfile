submodules := "battlechain-lib battlechain-starter battlechain-safe-harbor battlechain-prediction docs-battlechain solskill bc-dependency-contracts"

# Show current branch for each submodule
branch:
    @for dir in {{submodules}}; do \
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then \
            branch=$(cd "$dir" && git branch --show-current 2>/dev/null); \
            printf "%-30s %s\n" "$dir" "$branch"; \
        fi; \
    done
    @printf "%-30s %s\n" "root" "$(git branch --show-current)"

# Show git status across all submodules
status:
    @for dir in {{submodules}}; do \
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then \
            changes=$(cd "$dir" && git status --porcelain 2>/dev/null); \
            if [ -n "$changes" ]; then \
                echo "=== $dir ==="; \
                echo "$changes"; \
                echo; \
            fi; \
        fi; \
    done
    @echo "=== root ==="
    @git status --short

# Show full diff across all submodules and root
diff:
    @for dir in {{submodules}}; do \
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then \
            changes=$(cd "$dir" && git diff --color=always 2>/dev/null); \
            if [ -n "$changes" ]; then \
                echo "=== $dir ==="; \
                echo "$changes"; \
                echo; \
            fi; \
        fi; \
    done
    @changes=$(git diff --color=always --ignore-submodules 2>/dev/null); \
    if [ -n "$changes" ]; then \
        echo "=== root ==="; \
        echo "$changes"; \
    fi

# Pull all submodules and root to latest main
pull:
    #!/usr/bin/env bash
    set -euo pipefail
    failed=()
    for dir in {{submodules}}; do
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
            echo "=== $dir ==="
            if ! (cd "$dir" && git checkout main && git pull); then
                echo "SKIPPED: $dir has uncommitted changes — commit or stash first"
                failed+=("$dir")
            fi
            echo
        fi
    done
    echo "=== root ==="
    git checkout main && git pull
    if [ ${#failed[@]} -gt 0 ]; then
        echo
        echo "Failed to pull: ${failed[*]}"
        echo "Run 'just status' to see uncommitted changes"
    fi

# Update root to track current submodule commits
sync:
    #!/usr/bin/env bash
    set -euo pipefail
    updated=()
    for dir in {{submodules}}; do
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
            if git diff --quiet "$dir" 2>/dev/null; then
                continue
            fi
            git add "$dir"
            updated+=("$dir")
        fi
    done
    if [ ${#updated[@]} -eq 0 ]; then
        echo "All submodule pointers are up to date."
    else
        git commit -m "chore: sync submodule pointers"
        echo "Synced: ${updated[*]}"
    fi

# Commit all dirty submodules with the same message, then update root
commit-all msg:
    #!/usr/bin/env bash
    set -euo pipefail
    committed=()
    for dir in {{submodules}}; do
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
            changes=$(cd "$dir" && git status --porcelain 2>/dev/null)
            if [ -n "$changes" ]; then
                echo "=== Committing $dir ==="
                (cd "$dir" && git add -A && git commit -m "{{msg}}")
                committed+=("$dir")
                echo
            fi
        fi
    done
    if [ ${#committed[@]} -eq 0 ]; then
        echo "No submodules have changes to commit."
    else
        echo "=== Updating root to track new submodule commits ==="
        git add "${committed[@]}"
        git commit -m "{{msg}}"
        echo
        echo "Committed: ${committed[*]}"
    fi

# Push all submodules that are ahead of their remote
push-all:
    #!/usr/bin/env bash
    set -euo pipefail
    for dir in {{submodules}}; do
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
            ahead=$(cd "$dir" && git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
            if [ "$ahead" -gt 0 ]; then
                echo "=== Pushing $dir ($ahead commits ahead) ==="
                (cd "$dir" && git push)
                echo
            fi
        fi
    done
    ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null || echo "0")
    if [ "$ahead" -gt 0 ]; then
        echo "=== Pushing root ($ahead commits ahead) ==="
        git push
    fi
