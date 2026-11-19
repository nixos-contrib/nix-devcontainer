#!/usr/bin/env bats
# Smoke tests: run inside the image as the default user.

@test "runs as the non-root vscode user" {
  [ "$(id -un)" = "vscode" ]
}

@test "nix is installed" {
  run nix --version
  [ "$status" -eq 0 ]
  [[ "$output" == "nix (Nix)"* ]]
}

@test "flakes and nix-command are enabled" {
  run nix eval --expr '1 + 1'
  [ "$status" -eq 0 ]
  [ "$output" = "2" ]
  run nix flake metadata --help
  [ "$status" -eq 0 ]
}

@test "direnv is installed" {
  run direnv version
  [ "$status" -eq 0 ]
}

@test "nix-direnv is wired into direnvrc" {
  [ -f /home/vscode/.nix-profile/share/nix-direnv/direnvrc ]
  grep -q nix-direnv /home/vscode/.config/direnv/direnvrc
}

@test "login shells have nix on PATH" {
  run bash -lc 'command -v nix'
  [ "$status" -eq 0 ]
}

@test "interactive shells have the direnv hook" {
  run bash -ic 'type -t _direnv_hook'
  [ "$status" -eq 0 ]
  [[ "$output" == *function ]]
}

@test "the nix store is writable by the user" {
  [ -O /nix/store ] || [ -w /nix/store ]
}
