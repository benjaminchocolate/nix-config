;;; early-init.el --- Runs before init.el and the first frame  -*- lexical-binding: t; -*-

;;; Directories
;; This directory is a git checkout, so everything Emacs writes goes to the
;; XDG directories.  Set here because package.el and native compilation
;; pick their directories before init.el runs.

(defun my/xdg-dir (variable fallback)
  "Return the \"emacs/\" directory under the XDG base directory VARIABLE.
FALLBACK is used when the variable is unset, as when Emacs starts from
the Dock or launchd."
  (let ((base (getenv variable)))
    (file-name-as-directory
     (expand-file-name "emacs" (if (member base '(nil "")) fallback base)))))

(defconst my/data-dir (my/xdg-dir "XDG_DATA_HOME" "~/.local/share")
  "What Emacs installs: packages and tree-sitter grammars.")
(defconst my/state-dir (my/xdg-dir "XDG_STATE_HOME" "~/.local/state")
  "What Emacs remembers: history, bookmarks, Customize output.")
(defconst my/cache-dir (my/xdg-dir "XDG_CACHE_HOME" "~/.cache")
  "What Emacs can rebuild: native-compiled code.")

(setq package-user-dir (expand-file-name "elpa" my/data-dir)
      treesit-extra-load-path (list (expand-file-name "tree-sitter" my/data-dir)))

(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache (expand-file-name "eln-cache" my/cache-dir)))

;; Read by no-littering when it loads.
(setq no-littering-etc-directory (expand-file-name "etc/" my/state-dir)
      no-littering-var-directory (expand-file-name "var/" my/state-dir))

;;; Loading
;; Both must be set before the first package loads or installs.

(setq load-prefer-newer t
      package-native-compile t)

;;; Frames
;; Set here so nothing flashes before init.el runs.

(setq frame-resize-pixelwise t
      inhibit-compacting-font-caches t
      default-frame-alist
      '((fullscreen . maximized)
        (ns-transparent-titlebar . t)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (vertical-scroll-bars . nil)))

;;; early-init.el ends here
