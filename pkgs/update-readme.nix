{
  writeShellApplication,
  emacs-nox,
  git,
  tree,
  perl,
}:
writeShellApplication {
  name = "update-readme";
  runtimeInputs = [
    emacs-nox
    git
    tree
    perl
  ];
  text = ''
    emacs --batch -Q \
      --eval '(require (quote ob-shell))' \
      --eval '(setq org-confirm-babel-evaluate nil)' \
      --eval '(with-current-buffer (find-file-noselect "README.org")
                (org-babel-execute-buffer)
                (save-buffer))'

    # Stage the regenerated README so the commit includes it instead of failing
    git add README.org
  '';
}
