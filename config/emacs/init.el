;;; init.el --- Personal Emacs configuration -*- lexical-binding: t -*-

;;; Commentary:
;; Conventions:
;; - Inside `use-package', user options go in :custom.  Outside, they use
;;   `setopt'.  Plain variables and runtime updates use `setq'.
;; - Functions on hooks are named, never lambdas, so they can be removed
;;   and read in C-h v.
;; - `;;' for comments on their own line, `;' only after code.  The elisp
;;   save hook re-indents lone `;' comments to column 40.

;;; Code:

;;; Packages

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(setopt package-install-upgrade-built-in t
        use-package-always-ensure t)    ; built-ins opt out with :ensure nil

;; First, so every package after it is compiled as it loads.
(use-package compile-angel
  :demand t
  :custom
  (compile-angel-verbose t)
  :config
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)
  (compile-angel-on-load-mode 1))

;; Before anything that writes files, so they land in its directories.
(use-package no-littering
  :config
  (let ((dir (no-littering-expand-var-file-name "lock-files/")))
    (make-directory dir t)
    (setopt lock-file-name-transforms `((".*" ,dir t)))))

;;; Basic behavior

(setopt make-backup-files nil
        auto-save-default nil
        inhibit-startup-screen t
        window-sides-vertical t)

;; Customize writes to the state directory (from early-init.el), not here.
(setopt custom-file (expand-file-name "custom.el" my/state-dir))
(load custom-file 'noerror)

(delete-selection-mode 1)
(global-auto-revert-mode 1)
(add-hook 'dired-mode-hook #'auto-revert-mode)

(use-package repeat
  :ensure nil
  :config
  (repeat-mode 1))

;;; Appearance
;; Frame parameters are in early-init.el.

(setopt ns-click-through nil)
(blink-cursor-mode -1)
(column-number-mode 1)

(setq-default line-spacing 0.3)

(defun my/no-line-spacing ()
  "Remove extra line spacing in the current buffer."
  (setq-local line-spacing 0))
(add-hook 'minibuffer-setup-hook #'my/no-line-spacing)

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

(defun my/flat-mode-line (&rest _)
  "Remove the box around the mode line faces."
  (dolist (face '(mode-line mode-line-active mode-line-inactive))
    (when (facep face)
      (set-face-attribute face nil :box nil))))
;; Before any theme loads, so the first theme gets it too.
(add-hook 'enable-theme-functions #'my/flat-mode-line)

(defun my/apply-theme (appearance)
  "Load the Modus theme that matches macOS APPEARANCE."
  (mapc #'disable-theme custom-enabled-themes)
  (pcase appearance
    ('light (load-theme 'modus-operandi-tinted t))
    ('dark  (load-theme 'modus-vivendi-tinted t))))
(add-hook 'ns-system-appearance-change-functions #'my/apply-theme)

(use-package standard-themes)
(use-package ef-themes)

;; Variable pitch for prose; code, tables and line numbers stay fixed.
(use-package mixed-pitch
  :hook (text-mode . mixed-pitch-mode))

(use-package mood-line
  :custom
  (mood-line-glyph-alist mood-line-glyphs-fira-code)
  :config
  (mood-line-mode 1))

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

;;; Line numbers and scrolling

(setopt display-line-numbers-type 'relative
        display-line-numbers-width-start t
        display-line-numbers-grow-only t)

(defun my/disable-line-numbers ()
  "Turn off line numbers in the current buffer."
  (display-line-numbers-mode -1))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'display-line-numbers-mode)
(add-hook 'conf-mode-hook #'display-line-numbers-mode)
;; org-mode derives from text-mode, so undo the text-mode hook there.
(add-hook 'org-mode-hook #'my/disable-line-numbers)

(use-package ultra-scroll
  :custom
  (scroll-conservatively 3)
  (scroll-margin 6)
  :config
  (ultra-scroll-mode 1))

;;; Completion
;; Minibuffer: vertico, orderless, marginalia.  In buffers:
;; completion-preview, with TAB falling back to *Completions*.

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
    ("<tab>" . completion-preview-complete))
  :config
  (with-eval-after-load 'org
    (add-to-list 'completion-preview-commands #'org-self-insert-command))
  (global-completion-preview-mode 1))

;; Based on https://protesilaos.com/codelog/2026-07-29-emacs-default-minibuffer-completion-overview/
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

;;; Editing (meow)

(use-package meow
  :config
  (defun meow-setup ()
    (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
    (meow-motion-overwrite-define-key
     '("j" . meow-next)
     '("k" . meow-prev)
     '("<escape>" . ignore))
    (meow-leader-define-key
     ;; SPC j/k run the original command in MOTION state.
     '("j" . "H-j")
     '("k" . "H-k")
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

;;; Programming

(use-package emacs
  :ensure nil
  :custom
  ;; Its :set function updates `major-mode-remap-alist'; setq would not.
  (treesit-enabled-modes t)
  (treesit-font-lock-level 3)
  (treesit-auto-install-grammar 'ask)
  :hook
  (prog-mode . electric-pair-local-mode))

(use-package project
  :ensure nil
  :custom
  (project-vc-extra-root-markers '(".project")))

;; Buffer-local direnv, so eglot finds each project's flake tools.
(use-package envrc
  :init
  ;; Depth 90 runs it after other global modes, so its hooks run before theirs.
  (add-hook 'after-init-hook #'envrc-global-mode 90)
  :config
  (keymap-set envrc-mode-map "C-c e" #'envrc-command-map))

(defun my/indent-buffer ()
  "Re-indent the whole buffer."
  (indent-region (point-min) (point-max)))

(defun my/elisp-format-on-save ()
  "Use spaces and re-indent the buffer before each save."
  (setq-local indent-tabs-mode nil)
  (add-hook 'before-save-hook #'my/indent-buffer nil t))
(add-hook 'emacs-lisp-mode-hook #'my/elisp-format-on-save)

(use-package eglot
  :ensure nil
  :preface
  (defun my/eglot-format-on-save ()
    "Format with the language server before saving, while Eglot manages the buffer."
    (if (eglot-managed-p)
        (add-hook 'before-save-hook #'eglot-format-buffer nil t)
      (remove-hook 'before-save-hook #'eglot-format-buffer t)))
  :hook
  (((c-ts-mode c++-ts-mode nix-ts-mode swift-mode) . eglot-ensure)
   (eglot-managed-mode . my/eglot-format-on-save))
  :custom
  (eglot-send-changes-idle-time 0.1)
  (eglot-extend-to-xref t)              ; also manage referenced files outside the project
  ;; Keeps line heights stable: https://github.com/joaotavora/eglot/discussions/1492
  (eglot-code-action-indicator "h")
  ;; Don't log JSON-RPC events; a large speedup.
  (eglot-events-buffer-config '(:size 0 :format full))
  :config
  (add-to-list 'eglot-server-programs '(nix-ts-mode . ("nixd")))
  (add-to-list 'eglot-server-programs '(zig-mode . ("zls"))))

(use-package nix-ts-mode
  :mode "\\.nix\\'"
  :init
  (with-eval-after-load 'treesit
    (add-to-list 'treesit-language-source-alist
                 '(nix "https://github.com/nix-community/tree-sitter-nix"))))

(use-package swift-mode
  :mode "\\.swift\\'"
  :interpreter "swift")

(use-package zig-mode)
(use-package matlab-mode)
(use-package csv-mode)

(use-package devdocs
  :bind ("C-h D" . devdocs-lookup))

(use-package dape)

;;; Tools

(use-package magit)

(use-package ghostel
  :bind ("C-c t" . ghostel))

(use-package meow-ghostel
  :vc (:url "https://github.com/dakra/meow-ghostel" :rev :newest)
  :after (ghostel meow)
  :hook (ghostel-mode . meow-ghostel-mode))

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

(use-package pdf-tools
  :magic ("%PDF" . pdf-view-mode)
  :hook (pdf-view-mode . pdf-view-roll-minor-mode)
  :config
  (pdf-tools-install :no-query))

(use-package treemacs)
(use-package minimap)

(use-package languagetool
  :commands (languagetool-check
             languagetool-clear-suggestions
             languagetool-correct-at-point
             languagetool-correct-buffer
             languagetool-set-language
             languagetool-server-mode
             languagetool-server-start
             languagetool-server-stop)
  :custom
  (languagetool-java-arguments '("-Dfile.encoding=UTF-8"))
  (languagetool-console-command "/opt/homebrew/opt/languagetool/libexec/languagetool-commandline.jar")
  (languagetool-server-command "/opt/homebrew/opt/languagetool/libexec/languagetool-server.jar"))

;;; Org

;; Before Org loads: the paths build on `org-directory', and Org reads
;; `org-list-allow-alphabetical' only when it loads.
(setopt org-directory "~/Documents/Org/"
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-list-allow-alphabetical t
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
  (setq org-agenda-files
        (directory-files-recursively org-directory "\\.org\\'")))

(use-package org
  :ensure nil
  :demand t                             ; so org-wild-notifier starts at launch
  :bind ("C-c c" . org-capture)
  :custom
  ;; Its :set function loads the languages.
  (org-babel-load-languages '((emacs-lisp . t) (python . t) (dot . t) (shell . t)))
  (org-babel-python-command "python3")
  (org-cycle-separator-lines 1)
  :config
  (advice-add 'org-agenda :before #'my/refresh-agenda-files)
  (advice-add 'org-agenda-redo :before #'my/refresh-agenda-files))

(use-package org-agenda
  :ensure nil
  :defer t
  :custom
  (org-agenda-span 2)
  (org-agenda-start-day "+0d")
  (org-agenda-timegrid-use-ampm t)
  ;; Hide repeats of a done item that has a timestamp, deadline and schedule.
  (org-agenda-skip-timestamp-if-done t)
  (org-agenda-skip-deadline-if-done t)
  (org-agenda-skip-scheduled-if-done t))

(use-package ox-latex
  :ensure nil
  :defer t
  :config
  ;; To debug a failed export, set `org-latex-remove-logfiles' to nil.
  (add-to-list 'org-latex-logfiles-extensions "tex")
  (add-to-list 'org-latex-classes
               '("exam" "\\documentclass[answers]{exam}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}"))))

(use-package ox-typst
  :after org)

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
  :hook
  ((org-mode . olivetti-mode)
   (org-mode . visual-line-mode)))

;;; To look into
;; - magit and moving around
;; - accessibility
;; - margin on the side
;; - file associations
;; - claude
;; - less annoying warnings
;; - Ruby setup; quote pairing workflow
;; - code folding: (setopt hs-show-indicators t hs-display-lines-hidden t)
;; - reader: https://codeberg.org/MonadicSheep/emacs-reader
;; - emacs-everywhere: needs an osacompile advice (removed; see git history)

;;; init.el ends here
