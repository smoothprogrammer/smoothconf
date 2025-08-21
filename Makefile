hostname := $(shell hostname -s)

build:
	@sudo darwin-rebuild switch --flake .#$(hostname)

# https://github.com/DeterminateSystems/nix-installer
#
# Install upstream Nix using Determinate Nix Installer.
# Its offer number of advantages compare to vanilla Nix Installer:
#   - Enable flakes by default
#   - Better support for uninstalling Nix
#   - Survive macOS upgrades
nix/install:
	@curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
nix/uninstall:
	@/nix/nix-installer uninstall
nix/upgrade:
	@sudo -i nix upgrade-nix

# https://github.com/nix-darwin/nix-darwin
#
# A declarative system approach for macOS.
nix-darwin/install:
	@sudo nix run nix-darwin -- switch --flake .#$(hostname)
nix-darwin/uninstall:
	@sudo darwin-uninstaller
