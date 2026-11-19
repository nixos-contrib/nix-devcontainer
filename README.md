# nix-devcontainer

[![Publish](https://github.com/nixos-contrib/nix-devcontainer/actions/workflows/publish.yml/badge.svg)](https://github.com/nixos-contrib/nix-devcontainer/actions/workflows/publish.yml)
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

| Tag        | Meaning                                       |
| ---------- | --------------------------------------------- |
| `latest`   | Latest build of `main`, rebuilt weekly        |
| `YYYYMMDD` | Dated build of `main`, for pinning            |
| `X.Y.Z`    | Release tags                                  |

Pin by digest or dated tag if you need reproducible container builds.

## Build locally

```sh
docker buildx bake --load
docker run --rm -v "$PWD/test:/test:ro" nix-devcontainer:local bash /test/smoke.sh
```

`NIX_VERSION` and `BASE_IMAGE` are bake variables, e.g. `NIX_VERSION=2.28.3 docker buildx bake`.

## Notes

- The Nix sandbox is off (`sandbox = false`), since containers usually lack
  the privileges it needs.
- Project tools belong in the project's `flake.nix`, not in this image, so
  the image doesn't go stale.

## License

[MIT](LICENSE)
