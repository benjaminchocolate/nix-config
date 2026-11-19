;;; init.el --- Personal Emacs configuration -*- lexical-binding: t -*-

;;; Commentary:
;; Conventions used throughout:
;; - Inside `use-package', user options go in :custom (same machinery
;;   as `setopt': runs the option's :set function and checks its type).
;; - Outside `use-package', user options use `setopt'.  Plain variables
;;   (defvar, not defcustom) and runtime updates inside functions use `setq'.
;; - Functions on hooks are named, never lambdas, so they can be removed
;;   and read in C-h v.
;; - `;;' for comments on their own line, `;' only after code on the same
;;   line.  The elisp save hook below re-indents lone `;' comments to
;;   column 40.

;;; Code:

;;; ------------------------------------------------------------------
;;; Packages
;;; ------------------------------------------------------------------
;; Archives must be set before anything uses :ensure.

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setopt package-install-upgrade-built-in t
        use-package-always-ensure t)    ; built-ins below opt out with :ensure nil

;; Load early so other packages write their files into its directories.
(use-package no-littering
  :config
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setopt lock-file-name-transforms `((".*" ,dir t)))))


;;; ------------------------------------------------------------------
;;; Basic behavior
;;; ------------------------------------------------------------------

(setopt make-backup-files nil
        auto-save-default nil
        inhibit-startup-screen t)

;; Keep Customize output out of this file, but still apply it.  Emacs
;; rewrites custom.el on its own, so it lives with the rest of the state
;; (`my/state-dir' is defined in early-init.el), not in this git checkout.
(setopt custom-file (expand-file-name "custom.el" my/state-dir))
(load custom-file 'noerror)


;;; ------------------------------------------------------------------
;;; Appearance
;;; ------------------------------------------------------------------
;; Frame parameters (size, titlebar, startup colors) live in early-init.el.

(setopt ns-click-through nil)

(blink-cursor-mode -1)
(column-number-mode 1)

(defun my/flat-mode-line (&rest _)
  "Remove the box around the mode line faces.
Runs after every theme load via `enable-theme-functions'."
  (dolist (face '(mode-line mode-line-active mode-line-inactive))
    (when (facep face)
      (set-face-attribute face nil :box nil))))
;; Added before the theme loads so it applies to the first theme too.
(add-hook 'enable-theme-functions #'my/flat-mode-line)

(use-package standard-themes)

(use-package ef-themes
  :config
  ;; :no-confirm skips the "Really load?" prompt, which otherwise comes
  ;; back every time the theme package updates.
  ;;(load-theme 'ef-symbiosis :no-confirm))
  )
(defun my/apply-theme (appearance)
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'modus-operandi-tinted t))
    ('dark  (load-theme 'modus-vivendi-tinted t))))

(add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

;; Font candidates and the :height that matches their x-heights:
;; 0xProto Regular x-height 0.550   :height 0.90
;; 0xPropo Medium  x-height 0.550   :height 0.90
;; Atkinson Mono   x-height 0.496   :height 1.00
;; Atkinson Next   x-height 0.496   :height 1.00
;; Source Serif 4  x-height 0.475   :height 1.04
;; Charter Roman   x-height 0.481   :height 1.03
(set-face-attribute 'default nil :family "Atkinson Hyperlegible Mono" :height 150)
(set-face-attribute 'fixed-pitch nil :family "Atkinson Hyperlegible Mono" :height 1.0)
(set-face-attribute 'variable-pitch nil :family "Atkinson Hyperlegible Next" :height 1.0)
(set-face-attribute 'line-number nil :inherit '(shadow fixed-pitch))

;; Prose buffers (org, markdown, plain text) get variable pitch, while
;; code, tables and line numbers stay fixed.  mixed-pitch-mode does the
;; variable-pitch remap itself, so `variable-pitch-mode' isn't needed.
(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

(use-package mood-line

  ;; Enable mood-line
  :config
  (mood-line-mode)

  ;; Use pretty Fira Code-compatible glyphs
  :custom
  (mood-line-glyph-alist mood-line-glyphs-fira-code))

(use-package nerd-icons
  :custom
  (nerd-icons-font-family "Symbols Nerd Font Mono")
  :config
  ;; Use the icon font for the Private Use Area code points.
  (dolist (range '((#xE000 . #xF8FF) (#xF0000 . #xFFFFD)))
    (set-fontset-font t range nerd-icons-font-family nil 'prepend)))

(use-package ligature
  :config
  (ligature-set-ligatures
   'prog-mode
   '("->" "<-" "=>" "<=" ">=" "==" "!=" "===" "!==" "&&" "||"
     "::" "++" "--" "<<" ">>" "..." "/*" "*/" "//" "|>" "<|"))
  (global-ligature-mode 1))


;;; ------------------------------------------------------------------
;;; Line numbers
;;; ------------------------------------------------------------------
;; Type and width options must be set before the mode turns on.

(setopt display-line-numbers-type 'relative
        display-line-numbers-width-start t ; size the gutter to the buffer's line count
        display-line-numbers-grow-only t)

(defun my/disable-line-numbers ()
  "Turn off line numbers in the current buffer."
  (display-line-numbers-mode -1))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
;; org-mode derives from text-mode, so undo the text-mode hook there.
(add-hook 'org-mode-hook #'my/disable-line-numbers)


;;; ------------------------------------------------------------------
;;; Scrolling
;;; ------------------------------------------------------------------

(use-package ultra-scroll
  :custom
  (scroll-conservatively 3)             ; any value works since v0.4
  (scroll-margin 6)                     ; supported since v0.7
  :config
  (ultra-scroll-mode 1))


;;; ------------------------------------------------------------------
;;; Completion
;;; ------------------------------------------------------------------
;; Minibuffer: vertico + orderless + marginalia.
;; In-buffer: completion-preview, with TAB falling back to the built-in
;; *Completions* buffer configured in the `minibuffer' block.

(use-package vertico
  :init
  (vertico-mode 1))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :bind (:map minibuffer-local-map
              ("M-A" . marginalia-cycle))
  :init
  ;; Enabled in :init so it's active right away (this loads the package).
  (marginalia-mode 1))

(use-package completion-preview
  :ensure nil
  :demand t
  :custom
  (completion-preview-minimum-symbol-length 2)
  :bind
  ( :map completion-preview-active-mode-map
    ("M-i" . completion-preview-insert-word)
    ("M-n" . completion-preview-next-candidate)
    ("M-p" . completion-preview-prev-candidate)
    ("M-<return>" . completion-preview-insert)
    ;; TAB defers to the *Completions* buffer for more candidates.
    ("<tab>" . completion-preview-complete))
  :config
  (with-eval-after-load 'org
    (add-to-list 'completion-preview-commands #'org-self-insert-command))
  (global-completion-preview-mode 1))

;; Based on Prot's built-in completion setup:
;; https://protesilaos.com/codelog/2026-07-29-emacs-default-minibuffer-completion-overview/
(use-package minibuffer
  :ensure nil
  :demand t
  :custom
  (completions-format 'one-column)
  (completions-max-height 12)
  (completion-auto-help t)
  (completion-auto-select nil)
  (minibuffer-visible-completions t)
  (completion-eager-update t)
  :bind
  ( :map completion-in-region-mode-map
    ("M-i" . minibuffer-choose-completion)
    ("M-n" . minibuffer-next-completion)
    ("M-p" . minibuffer-previous-completion)))


;;; ------------------------------------------------------------------
;;; Editing (meow)
;;; ------------------------------------------------------------------

(delete-selection-mode 1)

(use-package meow
  :config
  (defun meow-setup ()
    ;; A plain defvar, not a user option, so setq is correct here.
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; SPC j/k run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
     ;; SPC 0-9 for digit arguments.
     '("1" . meow-digit-argument)
     '("2" . meow-digit-argument)
     '("3" . meow-digit-argument)
     '("4" . meow-digit-argument)
     '("5" . meow-digit-argument)
     '("6" . meow-digit-argument)
     '("7" . meow-digit-argument)
     '("8" . meow-digit-argument)
     '("9" . meow-digit-argument)
     '("0" . meow-digit-argument)
     '("/" . meow-keypad-describe-key)
     '("?" . meow-cheatsheet))
    (meow-normal-define-key
     '("0" . meow-expand-0)
     '("9" . meow-expand-9)
     '("8" . meow-expand-8)
     '("7" . meow-expand-7)
     '("6" . meow-expand-6)
     '("5" . meow-expand-5)
     '("4" . meow-expand-4)
     '("3" . meow-expand-3)
     '("2" . meow-expand-2)
     '("1" . meow-expand-1)
     '("-" . negative-argument)
     '(";" . meow-reverse)
     '("," . meow-inner-of-thing)
     '("." . meow-bounds-of-thing)
     '("[" . meow-beginning-of-thing)
     '("]" . meow-end-of-thing)
     '("a" . meow-append)
     '("A" . meow-open-below)
     '("b" . meow-back-word)
     '("B" . meow-back-symbol)
     '("c" . meow-change)
     '("d" . meow-delete)
     '("D" . meow-backward-delete)
     '("e" . meow-next-word)
     '("E" . meow-next-symbol)
     '("f" . meow-find)
     '("g" . meow-cancel-selection)
     '("G" . meow-grab)
     '("h" . meow-left)
     '("H" . meow-left-expand)
     '("i" . meow-insert)
     '("I" . meow-open-above)
     '("j" . meow-next)
     '("J" . meow-next-expand)
     '("k" . meow-prev)
     '("K" . meow-prev-expand)
     '("l" . meow-right)
     '("L" . meow-right-expand)
     '("m" . meow-join)
     '("n" . meow-search)
     '("o" . meow-block)
     '("O" . meow-to-block)
     '("p" . meow-yank)
     '("q" . meow-quit)
     '("Q" . meow-goto-line)
     '("r" . meow-replace)
     '("R" . meow-swap-grab)
     '("s" . meow-kill)
     '("t" . meow-till)
     '("u" . meow-undo)
     '("U" . meow-undo-in-selection)
     '("v" . meow-visit)
     '("w" . meow-mark-word)
     '("W" . meow-mark-symbol)
     '("x" . meow-line)
     '("X" . meow-goto-line)
     '("y" . meow-save)
     '("Y" . meow-sync-grab)
     '("z" . meow-pop-selection)
     '("'" . repeat)
     '("<escape>" . ignore)))
  (meow-setup)
  ;; No line-expansion hints; relative line numbers cover this.
  (setf (alist-get 'line meow-expand-hint-counts) 0)
  (meow-global-mode 1))


;;; ------------------------------------------------------------------
;;; Programming
;;; ------------------------------------------------------------------

(use-package emacs
  :ensure nil
  :custom
  ;; This option has a :set function that updates
  ;; `major-mode-remap-alist'; plain setq would leave ts-modes off.
  (treesit-enabled-modes t)             ; use ts-modes wherever available
  (treesit-font-lock-level 3)           ; 1-4, where 4 is max highlighting
  (treesit-auto-install-grammar 'ask)   ; or `always' / `ask-dir'
  :hook
  ;; Buffer-local version; `electric-pair-mode' is global.
  (prog-mode . electric-pair-local-mode))

(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :init
  (with-eval-after-load 'treesit
    (add-to-list 'treesit-language-source-alist
                 '(nix "https://github.com/nix-community/tree-sitter-nix"))))

(use-package eglot
  :ensure nil
  :preface
  (defun my/eglot-format-on-save ()
    "Format with the language server before saving, while Eglot manages the buffer."
    (if (eglot-managed-p)
        (add-hook 'before-save-hook #'eglot-format-buffer nil t)
      (remove-hook 'before-save-hook #'eglot-format-buffer t)))
  :hook
  (((c-ts-mode c++-ts-mode nix-ts-mode) . eglot-ensure)
   (eglot-managed-mode . my/eglot-format-on-save))
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; also manage referenced non-project files
  ;; Avoid changing line heights if your font is wonky. See
  ;; https://github.com/joaotavora/eglot/discussions/1492
  (eglot-code-action-indicator "h")
  ;; Don't log every JSON-RPC event (big performance win).  This is the
  ;; supported switch for what overriding `jsonrpc--log-event' did.
  (eglot-events-buffer-config '(:size 0 :format full))
  :config
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd"))))

(defun my/indent-buffer ()
  "Re-indent the whole buffer."
  (indent-region (point-min) (point-max)))

(defun my/elisp-format-on-save ()
  "Use spaces and re-indent the buffer before each save."
  (setq-local indent-tabs-mode nil)
  (add-hook 'before-save-hook #'my/indent-buffer nil t))
(add-hook 'emacs-lisp-mode-hook #'my/elisp-format-on-save)

(use-package devdocs
  :bind ("C-h D" . devdocs-lookup))


;;; ------------------------------------------------------------------
;;; Tools
;;; ------------------------------------------------------------------

(use-package magit)

(use-package ghostel
  :bind ("C-c t" . ghostel))

(use-package dashboard
  :demand t                             ; :bind alone would defer loading past startup
  :bind ("C-c h" . dashboard-open)
  :custom
  (dashboard-center-content t)
  (dashboard-vertically-center-content t)
  ;; Also show the dashboard in frames made with `emacsclient -c'.
  (initial-buffer-choice #'dashboard-open)
  :config
  (dashboard-setup-startup-hook))

;; (use-package emacs-everywhere
;;   :config
;;   (defun my/emacs-everywhere-fix-osacompile (args)
;;     "Make emacs-everywhere compile its AppleScripts into the data fork.
;; Its `-r scpt:128' flag writes to the resource fork, which current
;; macOS can't run (script error -1758)."
;;     (let ((cmd (car args)))
;;       (if (and (stringp cmd)
;;                (string-match
;;                 "\\`osacompile -r scpt:128 -t osas -o \\(\\S-+\\) \\(\\S-+\\)\\'"
;;                 cmd))
;;           (let ((out (match-string 1 cmd))
;;                 (src (match-string 2 cmd)))
;;             (cons (format "rm -f %s && osacompile -o %s %s" out out src)
;;                   (cdr args)))
;;         args)))
;;   (advice-add 'shell-command :filter-args #'my/emacs-everywhere-fix-osacompile))

(use-package pdf-tools
  :ensure t
  :config
  (pdf-tools-install)
  (add-hook 'pdf-view-mode-hook #'pdf-view-roll-minor-mode))


;;; ------------------------------------------------------------------
;;; Org
;;; ------------------------------------------------------------------

;; Set before Org loads so the paths can build on `org-directory'.
(setopt org-directory "~/Documents/Org/"
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        ;; Daily page: plan at the top, log below, one page per day.
        org-capture-templates
        `(("t" "Today's page" entry
           (file+olp+datetree ,(expand-file-name "log.org" org-directory))
           "* Today\n- [ ] %?\n* Log\n"
           :jump-to-captured t)
          ("i" "Inbox" entry
           (file ,(expand-file-name "inbox.org" org-directory))
           "* %?\n%U")))

(defun my/refresh-agenda-files (&rest _)
  "Rebuild `org-agenda-files' from every .org file under `org-directory'."
  ;; A runtime update rather than configuration, so setq.
  (setq org-agenda-files
        (directory-files-recursively org-directory "\\.org\\'")))

(use-package org
  :ensure nil
  :demand t                             ; load now so org-wild-notifier starts at launch
  :bind ("C-c c" . org-capture)
  :custom
  ;; This option's :set function loads the languages, so it replaces a
  ;; separate `org-babel-do-load-languages' call.
  (org-babel-load-languages '((emacs-lisp . t) (python . t)))
  (org-babel-python-command "python3")
  :config
  (advice-add 'org-agenda :before #'my/refresh-agenda-files)
  (advice-add 'org-agenda-redo :before #'my/refresh-agenda-files))

(use-package alert
  :custom
  (alert-default-style 'osx-notifier))

(use-package org-wild-notifier
  :after org
  :custom
  (org-wild-notifier-alert-time '(30 10))
  (org-wild-notifier-day-wide-alert-times '("09:00"))
  (org-wild-notifier-keyword-whitelist '("TODO"))
  :config
  (org-wild-notifier-mode 1))

(use-package org-modern
  :hook
  ((org-mode . org-modern-mode)
   (org-agenda-finalize . org-modern-agenda)))

(use-package olivetti
  :custom
  (olivetti-body-width 80)
  (olivetti-style 'fancy)
  :custom-face
  (olivetti-fringe ((t (:background "#1f161c"))))
  :hook
  ((org-mode . olivetti-mode)
   (org-mode . visual-line-mode)))

(use-package ox-typst
  :after org)


;;; ------------------------------------------------------------------
;;; To look into
;;; ------------------------------------------------------------------
;; - magit and moving around
;; - accessibility
;; - margin on the side
;; - file associations
;; - claude
;; - code folding: (setopt hs-show-indicators t hs-display-lines-hidden t)

;;; init.el ends here




;;If an export ever fails in a confusing way, temporarily turn cleanup off:
;;(setq org-latex-remove-logfiles nil)
(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-logfiles-extensions "tex"))


(with-eval-after-load 'ox-latex
  (add-to-list 'org-latex-classes
               '("exam" "\\documentclass[answers]{exam}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}"))))


(setq org-list-allow-alphabetical t)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((dot . t)))


;;(setenv "PATH" (concat (file-name-directory (executable-find "dot")) ":" (getenv "PATH")))


;; Use Noto Sans Symbols 2 for symbol characters the main fonts lack.
;;(set-fontset-font t 'symbol "Noto Sans Symbols 2" nil 'append)


;; Ensure Emacs loads the most recent byte-compiled files.
(setq load-prefer-newer t)

(use-package compile-angel
  :demand t
  :config
  ;; Set `compile-angel-verbose' to nil to disable compile-angel messages.
  ;; (When set to nil, compile-angel won't show which file is being compiled.)
  (setq compile-angel-verbose t)

  ;; The following directive prevents compile-angel from compiling your init
  ;; files. If you choose to remove this push to `compile-angel-excluded-path-suffixes'
  ;; and compile your pre/post-init files, ensure you understand the
  ;; implications and thoroughly test your code. For example, if you're using
  ;; the `use-package' macro, you'll need to explicitly add:
  ;; (eval-when-compile (require 'use-package))
  ;; at the top of your init file.
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)

  ;; Uncomment the line below to compile automatically when an Elisp file is saved
  ;; (add-hook 'emacs-lisp-mode-hook #'compile-angel-on-save-local-mode)

  ;; A global mode that compiles .el files when they are loaded
  ;; using `load' or `require'.
  (compile-angel-on-load-mode 1))

(setq package-native-compile t)

(setq inhibit-compacting-font-caches t)

(require 'project)
(setopt project-vc-extra-root-markers '(".project"))

(add-hook 'dired-mode-hook 'auto-revert-mode)

;;(setq insert-directory-program (executable-find "gls"))

(use-package dape
  :ensure t
  ;; :preface
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  ;; (setq dape-key-prefix "\C-x\C-a")

  ;;  :hook
  ;; Save breakpoints on quit
  ;; (kill-emacs . dape-breakpoint-save)
  ;; Load breakpoints on startup
  ;; (after-init . dape-breakpoint-load)

  ;; :custom
  ;; Turn on global bindings for setting breakpoints with mouse
  ;; (dape-breakpoint-global-mode +1)

  ;; Info buffers to the right
  ;; (dape-buffer-window-arrangement 'right)
  ;; Info buffers like gud (gdb-mi)
  ;; (dape-buffer-window-arrangement 'gud)
  ;; (dape-info-hide-mode-line nil)

  ;; Projectile users
  ;; (dape-cwd-function #'projectile-project-root)

  ;; :config
  ;; Pulse source line (performance hit)
  ;; (add-hook 'dape-display-source-hook #'pulse-momentary-highlight-one-line)

  ;; Save buffers on startup, useful for interpreted languages
  ;; (add-hook 'dape-start-hook (lambda () (save-some-buffers t t)))

  ;; Kill compile buffer on build success
  ;; (add-hook 'dape-compile-hook #'kill-buffer)
  )

;; For a more ergonomic Emacs and `dape' experience
(use-package repeat
  :custom
  (repeat-mode +1))

;; Left and right side windows occupy full frame height
(use-package emacs
  :custom
  (window-sides-vertical t))

;;(use-package reader
;;  :vc (:url "https://codeberg.org/MonadicSheep/emacs-reader"))

(setq org-agenda-timegrid-use-ampm t)
(setq org-agenda-span 2
      org-agenda-start-day "+0d")

;; Hide duplicates of the same todo item
;; If it has more than one of timestamp, scheduled,
;; or deadline information
(setq org-agenda-skip-timestamp-if-done t
      org-agenda-skip-deadline-if-done t
      org-agenda-skip-scheduled-if-done t
      ;;org-agenda-skip-scheduled-if-deadline-is-shown t
      ;;org-agenda-skip-timestamp-if-deadline-is-shown t)

      ;; Ricing org agenda
      ;;(setq org-agenda-current-time-string "")
      ;;(setq org-agenda-time-grid '((daily) () "" ""))
      )

;; A minimal time grid instead
;;(setq org-agenda-time-grid '((daily) (600 1200 1800) "---" "-----"))

;; Remove category names and scheduling type from agenda view
;;(setq org-agenda-prefix-format '(
;;                                 (agenda . "  %?-2i %t ")
;;                                 (todo . " %i %-12:c")
;;                                 (tags . " %i %-12:c")
;;                                 (search . " %i %-12:c")))
;;

(setq-default line-spacing 0.3)



(setq org-cycle-separator-lines 1)

(defun ben/no-line-spacing ()
  (setq-local line-spacing 0))
(add-hook 'minibuffer-setup-hook #'ben/no-line-spacing)

;; Use macOS's native font smoothing
;;(setq mac-allow-anti-aliasing t)

;;(use-package meow-ghostel
;;  :ensure t
;;  :after (ghostel meow)
;;  :hook (ghostel-mode . meow-ghostel-mode))

(use-package meow-ghostel
  :vc (:url "https://github.com/dakra/meow-ghostel" :rev :newest)
  :after (ghostel meow)
  :hook (ghostel-mode . meow-ghostel-mode))

;; make warnings less annoying

(use-package swift-mode
  :ensure t
  :mode "\\.swift\\'"
  :interpreter "swift")

;;(add-to-list 'eglot-server-programs
;;             '(swift-mode . ("sourcekit-lsp")))

(add-hook 'swift-mode-hook #'eglot-ensure)

(use-package zig-mode
  :ensure t)

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs
               '(zig-mode . ("zls"))))

(use-package treemacs
  :ensure t)

(use-package minimap
  :ensure t)

(use-package matlab-mode
  :ensure t)

;; Setup ruby
;; fix quotes pairing workflow

(use-package csv-mode)

(global-auto-revert-mode 1)

(use-package languagetool
  :ensure t
  :defer t
  :commands (languagetool-check
             languagetool-clear-suggestions
             languagetool-correct-at-point
             languagetool-correct-buffer
             languagetool-set-language
             languagetool-server-mode
             languagetool-server-start
             languagetool-server-stop)
  :config
  (setq languagetool-java-arguments '("-Dfile.encoding=UTF-8")

        ;;languagetool-console-command "~/.languagetool/languagetool-commandline.jar"
        ;;languagetool-server-command "~/.languagetool/languagetool-server.jar"))
        languagetool-console-command "/opt/homebrew/opt/languagetool/libexec/languagetool-commandline.jar"
        languagetool-server-command "/opt/homebrew/opt/languagetool/libexec/languagetool-server.jar"))
