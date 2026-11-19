# nix-devcontainer

[![CI](https://github.com/nixos-contrib/nix-devcontainer/actions/workflows/ci.yml/badge.svg)](https://github.com/nixos-contrib/nix-devcontainer/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nixos-contrib/nix-devcontainer)](https://github.com/nixos-contrib/nix-devcontainer/releases/latest)
[![Nix Flakes](https://img.shields.io/badge/Nix-Flakes-5277C3?logo=nixos&logoColor=white)](https://wiki.nixos.org/wiki/Flakes)
[![Dev Container](https://img.shields.io/badge/Dev%20Container-ready-2496ED?logo=docker&logoColor=white)](https://containers.dev)
[![Platforms](https://img.shields.io/badge/platforms-linux%2Famd64%20%7C%20linux%2Farm64-lightgrey)](#tags)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A prebuilt dev container image with Nix already installed. Skip the several
minutes the `ghcr.io/devcontainers/features/nix` Feature spends installing Nix
on every container build: the image is pulled, not built.

It is the standard Debian
[`devcontainers/base`](https://github.com/devcontainers/images/tree/main/src/base-debian)
image, so every other Feature and VS Code extension keeps working, plus:

- Nix (single-user, no daemon) with `nix-command` and `flakes` enabled
- `direnv` and [`nix-direnv`](https://github.com/nix-community/nix-direnv),
  hooked into bash and zsh
- Nix on `PATH` for login shells, interactive shells and non-interactive
  processes (tasks, `postCreateCommand`)
- `linux/amd64` and `linux/arm64` (Apple Silicon)

## Usage

`.devcontainer/devcontainer.json`:

```json
{
  "name": "my-project",
  "image": "ghcr.io/nixos-contrib/nix-devcontainer:latest",
  "mounts": [
    "source=${localWorkspaceFolderBasename}-nix,target=/nix,type=volume"
  ],
  "postCreateCommand": "sudo chown -R vscode:vscode /nix"
}
```

The `/nix` named volume keeps the store across rebuilds. Docker seeds a new
volume from the image, so Nix is there on first start.

Then put the environment in your project's `flake.nix` and `.envrc`:

```sh
echo "use flake" > .envrc && direnv allow
```

## Tags

Images are published when a release is cut, not on every commit.
[release-please](https://github.com/googleapis/release-please) opens a release
pull request from the conventional commits on `main`; merging it tags the
release and pushes the image.

| Tag      | Meaning                                 |
| -------- | --------------------------------------- |
| `latest` | The newest release                      |
| `X`      | The newest `X.y.z` release              |
| `X.Y`    | The newest `X.Y.z` release              |
| `X.Y.Z`  | One release, for reproducible pinning   |

Pin to `X.Y.Z` or a digest if you need reproducible container builds.

## Build locally

```sh
docker buildx bake -f deployment/docker/docker-bake.hcl --load
docker run --rm -v "$PWD/tests:/tests:ro" nix-devcontainer:local nix shell nixpkgs#bats -c bats /tests
```

`NIX_VERSION` and `BASE_IMAGE` are bake variables, e.g. `NIX_VERSION=2.28.3 docker buildx bake -f deployment/docker/docker-bake.hcl`.

## Notes

- The Nix sandbox is off (`sandbox = false`), since containers usually lack
  the privileges it needs.
- Project tools belong in the project's `flake.nix`, not in this image, so
  the image doesn't go stale.

## License

[MIT](LICENSE)
