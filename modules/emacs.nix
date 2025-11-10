{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  minimalEmacs = pkgs.emacs.overrideAttrs (oldAttrs: {
    preBuild = (oldAttrs.preBuild or "") + ''
      rm -rf lisp/play
      rm -rf lisp/obsolete
      rm -f lisp/isearchb.el
    '';
  });

  emacs = minimalEmacs.pkgs.withPackages (epkgs: [
    epkgs.ryo-modal
    epkgs.avy
    epkgs.exec-path-from-shell
    epkgs.envrc
    epkgs.helpful
    epkgs.which-key
    epkgs.keycast
    epkgs.eldoc-box
    epkgs.markdown-mode
    epkgs.nerd-icons
    epkgs.doom-themes
    epkgs.doom-modeline
    epkgs.spacious-padding
    epkgs.orderless
    epkgs.vertico
    epkgs.marginalia
    epkgs.nerd-icons-completion
    epkgs.corfu
    epkgs.treesit-grammars.with-all-grammars
    (pkgs.emacsPackages.trivialBuild {
      pname = "eglot-booster";
      version = "20250428";
      src = pkgs.fetchFromGitHub {
        owner = "jdtsmith";
        repo = "eglot-booster";
        rev = "1260d2f7dd18619b42359aa3e1ba6871aa52fd26";
        sha256 = "sha256-teAKWDDL7IrCBiZUVIVlB3W22G9H6IrWiRV/P62dFy0=";
      };
    })
    epkgs.nix-ts-mode
    epkgs.gleam-ts-mode
    epkgs.org-auto-tangle
    epkgs.org-modern
    (pkgs.emacsPackages.trivialBuild {
      pname = "org-modern-indent";
      version = "0.5.1";
      src = pkgs.fetchFromGitHub {
        owner = "jdtsmith";
        repo = "org-modern-indent";
        rev = "v0.5.1";
        sha256 = "sha256-st3338Jk9kZ5BLEPRJZhjqdncMpLoWNwp60ZwKEObyU=";
      };
    })
    epkgs.ox-hugo
    epkgs.org-present
    epkgs.org-roam
    epkgs.org-roam-ui
    epkgs.verb
    epkgs.magit
    epkgs.ledger-mode
  ]);

  cfg = config.mod.emacs;
in

{
  options.mod.emacs = {
    enable = mkEnableOption "emacs";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      emacs
      pkgs.ledger
    ];

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    fonts.packages = [ pkgs.nerd-fonts.iosevka ];

    mod.activationScripts.tangleEmacsConfig.text = ''
      ${emacs}/bin/emacs ${./.}/emacs.org \
        -Q --batch --eval '(org-babel-tangle nil nil "^elisp$")' --kill
    '';
  };
}
