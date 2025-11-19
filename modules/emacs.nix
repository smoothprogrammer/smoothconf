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
    epkgs.exec-path-from-shell
    epkgs.envrc
    epkgs.ryo-modal
    epkgs.avy
    epkgs.helpful
    epkgs.which-key
    epkgs.keycast
    epkgs.markdown-mode
    epkgs.otpp
    epkgs.nerd-icons
    epkgs.doom-themes
    epkgs.doom-modeline
    epkgs.spacious-padding
    epkgs.marginalia
      epkgs.nerd-icons-completion
    epkgs.pulsar
    epkgs.golden-ratio
    epkgs.focus
    epkgs.vertico-posframe
    epkgs.consult
    epkgs.corfu
    epkgs.vertico
    epkgs.orderless
    epkgs.cape
    epkgs.tempel
    epkgs.eglot-tempel
    epkgs.eglot-booster
    epkgs.eldoc-box
    epkgs.treesit-grammars.with-all-grammars
    # go-ts-mode is already emacs built-in major mode
    epkgs.gleam-ts-mode
    epkgs.nix-ts-mode
    epkgs.geiser
      epkgs.geiser-guile
    # lua-ts-mode is already emacs built-in major mode
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
    (pkgs.emacsPackages.trivialBuild {
      pname = "hurl-mode";
      version = "0.0.0";
      src = pkgs.fetchFromGitHub {
        owner = "JasZhe";
        repo = "hurl-mode";
        rev = "0753271bb4693924d3dcfa9d66a316086d7b7b72";
        sha256 = "sha256-56/XDXYG4pq3+liB9TDIISTlmN4xMGsic9jhrIacO5E=";
      };
    })
    epkgs.magit
    epkgs.diff-hl
    epkgs.blamer
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
      pkgs.emacs-lsp-booster
      pkgs.go
        pkgs.gopls
        pkgs.delve
      pkgs.gleam
      pkgs.nil
      pkgs.nixfmt-rfc-style
      pkgs.guile
      pkgs.luajit
      pkgs.lua-language-server
      pkgs.hurl
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
