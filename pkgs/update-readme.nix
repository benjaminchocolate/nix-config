{
  writeShellApplication,
  emacs-nox,
  tree,
  perl,
}:
writeShellApplication {
  name = "update-readme";
  runtimeInputs = [
    emacs-nox
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
  '';
}
