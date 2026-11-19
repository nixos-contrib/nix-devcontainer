#!/usr/bin/env bash
# Smoke test: runs inside the image as the default user.
set -euo pipefail

echo "user: $(id -un)"
[ "$(id -un)" = "vscode" ]

nix --version
direnv version
test -f /home/vscode/.nix-profile/share/nix-direnv/direnvrc

# Flakes are enabled and nix can evaluate without a daemon.
nix eval --expr '1 + 1' | grep -qx 2
nix flake metadata --help >/dev/null

# Login shells get Nix on PATH.
bash -lc 'command -v nix' >/dev/null
bash -ic 'command -v direnv' >/dev/null

echo "ok"
