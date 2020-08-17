;;; -*- lexical-binding: t; -*-

(use-package ielm
  :commands ielm
  :hook ((ielm-mode . company-mode)))

(use-package elisp-mode
  :defer 30 ;; Prevent loading while loading elisp during init.
  :bind ("C-x C-e" . ar/eval-last-sexp)
  :hook ((emacs-lisp-mode . pcre-mode)
         (emacs-lisp-mode . ar/emacs-lisp-mode-hook-function)
         (ielm-mode . ar/emacs-lisp-mode-hook-function))
  :config
  (load "~/.emacs.d/features/config-elisp"))
