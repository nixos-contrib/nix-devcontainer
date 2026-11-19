ARG BASE_IMAGE=mcr.microsoft.com/devcontainers/base:bookworm
FROM ${BASE_IMAGE}

ARG NIX_VERSION=2.28.3

# direnv comes from apt; nix-direnv from nixpkgs below.
RUN apt-get update \
    && apt-get install -y --no-install-recommends direnv xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Single-user Nix, owned by the non-root user: no daemon, no build users, so it
# works the same under Docker, OrbStack, Codespaces and Podman.
RUN mkdir -m 0755 /nix && chown vscode:vscode /nix \
    && mkdir -p /etc/nix \
    && printf '%s\n' \
        'experimental-features = nix-command flakes' \
        'sandbox = false' \
        'filter-syscalls = false' \
        'accept-flake-config = true' \
        'warn-dirty = false' \
        > /etc/nix/nix.conf

USER vscode
ENV USER=vscode
RUN curl -fsSL "https://releases.nixos.org/nix/nix-${NIX_VERSION}/install" | sh -s -- --no-daemon \
    && . /home/vscode/.nix-profile/etc/profile.d/nix.sh \
    && nix profile install "nixpkgs/nixos-unstable#nix-direnv" \
    && nix-collect-garbage -d

USER root
COPY direnvrc /home/vscode/.config/direnv/direnvrc
COPY nix-shell-init.sh /etc/profile.d/nix-devcontainer.sh
RUN chown -R vscode:vscode /home/vscode/.config \
    && cat /etc/profile.d/nix-devcontainer.sh >> /etc/bash.bashrc \
    && cat /etc/profile.d/nix-devcontainer.sh >> /etc/zsh/zshenv \
    && printf '%s\n' 'eval "$(direnv hook bash)"' >> /etc/bash.bashrc \
    && printf '%s\n' 'eval "$(direnv hook zsh)"' >> /etc/zsh/zshrc

# Non-interactive processes (VS Code tasks, postCreateCommand, CI) get Nix too.
ENV PATH=/home/vscode/.nix-profile/bin:${PATH} \
    NIX_PATH=nixpkgs=flake:nixpkgs

USER vscode
LABEL org.opencontainers.image.source="https://github.com/nixos-contrib/nix-devcontainer" \
      org.opencontainers.image.description="Dev container with Nix, flakes, direnv and nix-direnv preinstalled" \
      org.opencontainers.image.licenses="MIT"
