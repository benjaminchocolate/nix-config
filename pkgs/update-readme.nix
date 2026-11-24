apps = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
  system:
  let
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {
    readme = {
      type = "app";
      program = pkgs.lib.getExe (
        pkgs.writeShellApplication {
          name = "update-readme";
          runtimeInputs = [ pkgs.emacs-nox pkgs.tree pkgs.perl ];
          text = ''
            emacs --batch -Q \
              --eval '(require (quote ob-shell))' \
              --eval '(setq org-confirm-babel-evaluate nil)' \
              --eval '(with-current-buffer (find-file-noselect "README.org")
                        (org-babel-execute-buffer)
                        (save-buffer))'
          '';
        }
      );
    };
  }
);