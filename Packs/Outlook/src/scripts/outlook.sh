#!/usr/bin/env bash
# outlook.sh - WSL wrapper for Outlook COM bridge
# Usage: outlook.sh <command> [params...]
# Example: outlook.sh search -Subject "Meeting" -Limit 5

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PS_SCRIPT="$(wslpath -w "$SCRIPT_DIR/outlook.ps1")"

# Build arguments, auto-converting WSL paths for file-related parameters
args=()
convert_next=false

for arg in "$@"; do
    if $convert_next; then
        # Convert WSL path to Windows path
        if [[ "$arg" == /* ]]; then
            arg="$(wslpath -w "$arg")"
        fi
        convert_next=false
    fi

    # Parameters that accept file/directory paths
    if [[ "$arg" == "-SavePath" ]]; then
        convert_next=true
    fi

    args+=("$arg")
done

# Execute PowerShell with COM bridge, clean up output
powershell.exe -ExecutionPolicy Bypass -NoProfile -NoLogo -File "$PS_SCRIPT" "${args[@]}" 2>&1 | \
    sed 's/\r$//' | \
    iconv -f utf-8 -t utf-8 -c
