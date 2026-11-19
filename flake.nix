{
  description = "Dev container image with Nix, flakes, direnv and nix-direnv preinstalled";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        devShells.default = pkgs.mkShell {
          name = "nix-devcontainer";
          packages = with pkgs; [
            bats
            shellcheck
            hadolint
            actionlint
          ];
        };
      }
    );
}
