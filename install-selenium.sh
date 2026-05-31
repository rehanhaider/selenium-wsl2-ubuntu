#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="${VENV_DIR:-$PROJECT_DIR/.venv}"

if [[ -z "${PYTHON:-}" ]]; then
    if [[ -x /usr/bin/python3 ]]; then
        PYTHON="/usr/bin/python3"
    else
        PYTHON="python3"
    fi
fi

log() {
    printf '\n%s\n' "$*"
}

run_sudo() {
    if ((EUID == 0)); then
        "$@"
    else
        sudo "$@"
    fi
}

resolve_package() {
    local candidate

    for candidate in "$@"; do
        if apt-cache show "$candidate" >/dev/null 2>&1; then
            printf '%s\n' "$candidate"
            return 0
        fi
    done

    printf 'No apt package found for any of: %s\n' "$*" >&2
    return 1
}

check_python_version() {
    "$1" -c 'import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' \
        >/dev/null 2>&1
}

is_usable_venv() {
    [[ -x "$VENV_DIR/bin/python" ]] &&
        "$VENV_DIR/bin/python" -c \
            'import encodings, sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)' \
            >/dev/null 2>&1
}

install_system_packages() {
    if ! command -v apt-get >/dev/null 2>&1; then
        printf 'apt-get was not found. This installer expects Ubuntu on WSL2.\n' >&2
        return 1
    fi

    local asound_package
    asound_package="$(resolve_package libasound2t64 libasound2)"

    local packages=(
        ca-certificates
        fonts-liberation
        "$asound_package"
        libatk-bridge2.0-0
        libatk1.0-0
        libcairo2
        libcups2
        libdbus-1-3
        libdrm2
        libexpat1
        libgbm1
        libglib2.0-0
        libgtk-3-0
        libnspr4
        libnss3
        libpango-1.0-0
        libu2f-udev
        libvulkan1
        libx11-6
        libx11-xcb1
        libxcb1
        libxcomposite1
        libxcursor1
        libxdamage1
        libxext6
        libxfixes3
        libxi6
        libxkbcommon0
        libxrandr2
        libxrender1
        libxshmfence1
        libxss1
        libxtst6
        python3
        python3-pip
        python3-venv
        xdg-utils
    )

    log "Updating apt package metadata..."
    run_sudo apt-get update

    log "Installing Chrome/Selenium runtime dependencies..."
    run_sudo apt-get install -y "${packages[@]}"
}

create_virtualenv() {
    if ! command -v "$PYTHON" >/dev/null 2>&1; then
        printf '%s was not found. Set PYTHON=/path/to/python3 and retry.\n' "$PYTHON" >&2
        return 1
    fi

    if ! check_python_version "$PYTHON"; then
        printf '%s must be Python 3.10 or newer.\n' "$PYTHON" >&2
        return 1
    fi

    if [[ "${RESET_VENV:-0}" == "1" ]]; then
        log "Recreating virtual environment at $VENV_DIR with $PYTHON..."
        "$PYTHON" -m venv --clear "$VENV_DIR"
    elif is_usable_venv; then
        log "Using existing virtual environment at $VENV_DIR..."
    else
        if [[ -d "$VENV_DIR" ]]; then
            log "Existing virtual environment is not usable; recreating $VENV_DIR..."
            "$PYTHON" -m venv --clear "$VENV_DIR"
        else
            log "Creating virtual environment at $VENV_DIR with $PYTHON..."
            "$PYTHON" -m venv "$VENV_DIR"
        fi
    fi

    log "Installing Python dependencies..."
    "$VENV_DIR/bin/python" -m pip install --upgrade pip
    "$VENV_DIR/bin/python" -m pip install --upgrade -r "$PROJECT_DIR/requirements.txt"
}

main() {
    if [[ "${SKIP_APT:-0}" == "1" ]]; then
        log "Skipping apt package installation because SKIP_APT=1."
    else
        install_system_packages
    fi

    create_virtualenv

    cat <<EOF

Done.

Activate the environment:
  source "$VENV_DIR/bin/activate"

Run the smoke test:
  python "$PROJECT_DIR/run_selenium.py"
EOF
}

main "$@"
