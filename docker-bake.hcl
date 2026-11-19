variable "NIX_VERSION" {
  default = "2.28.3"
}

variable "BASE_IMAGE" {
  default = "mcr.microsoft.com/devcontainers/base:bookworm"
}

group "default" {
  targets = ["image"]
}

target "image" {
  context    = "."
  dockerfile = "Dockerfile"
  args = {
    NIX_VERSION = NIX_VERSION
    BASE_IMAGE  = BASE_IMAGE
  }
  tags = ["nix-devcontainer:local"]
}
