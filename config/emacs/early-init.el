;;; early-init.el --- Runs before init.el and the first frame  -*- lexical-binding: t; -*-


;;; ------------------------------------------------------------------
;;; Where Emacs keeps what it writes
;;; ------------------------------------------------------------------
;; This directory is a git checkout (~/.config/emacs links to config/emacs
;; in the dotfiles repo), so only files I write belong here.  Everything
;; Emacs writes goes to the XDG directories instead.  Set here because
;; package.el and native compilation pick their directories before
;; init.el runs.

(defun my/xdg-dir (variable fallback)
  "Return the \"emacs/\" directory under the XDG base directory VARIABLE.
FALLBACK is used when the environment variable is unset, which can
happen when Emacs is started from the Dock or by launchd."
  (let ((base (getenv variable)))
    (file-name-as-directory
     (expand-file-name "emacs" (if (member base '(nil "")) fallback base)))))

(defconst my/data-dir (my/xdg-dir "XDG_DATA_HOME" "~/.local/share")
  "What Emacs installs: packages and tree-sitter grammars.")
(defconst my/state-dir (my/xdg-dir "XDG_STATE_HOME" "~/.local/state")
  "What Emacs remembers: history, bookmarks, Customize output.")
(defconst my/cache-dir (my/xdg-dir "XDG_CACHE_HOME" "~/.cache")
  "What Emacs can rebuild: native-compiled code.")

;; Installed packages (also where `use-package' :vc checkouts go).
(setq package-user-dir (expand-file-name "elpa" my/data-dir))

;; Extra place to look for tree-sitter grammars.
(setq treesit-extra-load-path
      (list (expand-file-name "tree-sitter" my/data-dir)))

;; Native-compiled .eln files.
(when (fboundp 'startup-redirect-eln-cache)
  (startup-redirect-eln-cache (expand-file-name "eln-cache" my/cache-dir)))

;; no-littering (loaded first thing in init.el) reads these when it loads
;; and sends every other package's files to them.
(setq no-littering-etc-directory (expand-file-name "etc/" my/state-dir)
      no-littering-var-directory (expand-file-name "var/" my/state-dir))



;;; ------------------------------------------------------------------
;;; Frames
;;; ------------------------------------------------------------------
;; Set here so nothing flashes before init.el runs.

(setq frame-resize-pixelwise t)

(setq default-frame-alist
      '((fullscreen . maximized)
        ;;(ns-appearance . dark)
        ;; follow macOS instead of hardcoded dark mode
        (ns-transparent-titlebar . t)
        (tool-bar-lines . 0)
        (menu-bar-lines . 0)
        (vertical-scroll-bars . nil)))

;; ef-symbiosis's bg-main and fg-main, so the first frame starts in the
;; theme's colors.  If you switch themes, get the new values with
;; M-: (face-background 'default) and M-: (face-foreground 'default).
;;(setq initial-frame-alist
;;      '((background-color . "#130911")
;;        (foreground-color . "#d0d0d0")))

;;; early-init.el ends here
