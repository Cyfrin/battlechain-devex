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

# Show diff stats across all submodules
diff:
    @for dir in {{submodules}}; do \
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then \
            changes=$(cd "$dir" && git diff --stat 2>/dev/null); \
            if [ -n "$changes" ]; then \
                echo "=== $dir ==="; \
                echo "$changes"; \
                echo; \
            fi; \
        fi; \
    done

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
