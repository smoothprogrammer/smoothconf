{
  config,
  lib,
  pkgs,
  username,
  platform,
  inputs,
  ...
}:

with lib;

{
  imports = [
    ({
      options.mod.activationScripts = mkOption {
        type = types.attrsOf (
          types.submodule {
            options.text = mkOption {
              type = types.lines;
              description = "Shell script content to run during activation.";
            };
          }
        );
        default = { };
      };
    
      config.system.activationScripts.postActivation.text = ''
        # Apply changes without logout/login cycle.
        /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    
        echo "running user activation scripts as ${username}..."
        sudo -u ${username} --login bash <<'EOF'
          set -euo pipefail
          ${concatStringsSep "\n\n" (
            mapAttrsToList (
              name: script: "# --- ${name} ---\n${script.text}\n# --- end ${name} ---"
            ) config.mod.activationScripts
          )}
        EOF
      '';
    })
    ./modules/emacs.nix
  ];

  environment.systemPackages = with pkgs; [
	inputs.ctools.packages."${platform}".shadowify
    git
    gnumake
    pkgs.potrace
    pkgs.imagemagick
    pkgs.backgroundremover
  ];

  homebrew.enable = true;
  homebrew.casks = [
	"whatsapp"
	"discord"
	"godot"
	"robloxstudio"
	"roblox"
	"slack"
	"chatgpt"
	"dbeaver-community"
	"mongodb-compass"
	"postman"
	"figma"
	"blender"
	"audacity"
	"inkscape"
	"affinity"
	"container"
	"docker-desktop"
  ];

  system.stateVersion = 6;
  system.primaryUser = username;
  users.users.${username}.home = "/Users/${username}";
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    warn-dirty = false
    keep-outputs = true
    keep-derivations = true
  '';
  nixpkgs.hostPlatform = platform;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowBroken = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  system.defaults.NSGlobalDomain = {
    "com.apple.swipescrolldirection" = true;
  };
  services.karabiner-elements = {
    enable = true;
    package = pkgs.karabiner-elements.overrideAttrs (old: {
      version = "14.13.0";
      src = pkgs.fetchurl {
        inherit (old.src) url;
        hash = "sha256-gmJwoht/Tfm5qMecmq1N6PSAIfWOqsvuHU8VDJY8bLw=";
      };
      dontFixup = true;
    });
  };
  mod.emacs.enable = true;
}
