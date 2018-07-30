;;; Init.el GC values (undone at end).
(setq gc-cons-threshold (* 384 1024 1024)
      gc-cons-percentage 0.6)

;;; Temprarily avoid loading modes during init (undone at end).
(defvar ar/init--file-name-handler-alist file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Transparent titlebar on
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)))

;; Match theme color early on, so loading experience is smoother.
(set-background-color "#1b181b")

;; Hide UI (early on).

;; Don't want a mode line while loading init.
(setq mode-line-format nil)

;; No scrollbar by default.
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; No nenubar by default.
(when (fboundp 'menu-bar-mode) (menu-bar-mode -1))

;; No toolbar by default.
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))

;; No tooltip by default.
(when (fboundp 'tooltip-mode) (tooltip-mode -1))

;; No Alarms.
(setq ring-bell-function 'ignore)

;; macOS basics.
(when (string-equal system-type "darwin")
  (menu-bar-mode 1)
  ;; Fixes mode line separator issues on macOS.
  (setq ns-use-srgb-colorspace nil)
  (setq mac-command-modifier 'meta)
  (setq exec-path (append exec-path '("~/homebrew/bin"
                                      "~/homebrew/Cellar/llvm/HEAD/bin"
                                      "/usr/local/bin"))))
;;;; Set up package tls START

(require 'cl)
(require 'package)

;; Don't auto-initialize.
(setq package-enable-at-startup nil)

;; Don't add that `custom-set-variables' block to init.
(setq package--init-file-ensured t)

(require 'tls)

;; From https://github.com/hlissner/doom-emacs/blob/5dacbb7cb1c6ac246a9ccd15e6c4290def67757c/core/core-packages.el#L102
(setq gnutls-verify-error (not (getenv "INSECURE")) ; you shouldn't use this
      tls-checktrust gnutls-verify-error
      tls-program (list "gnutls-cli --x509cafile %t -p %p %h"
                        ;; compatibility fallbacks
                        "gnutls-cli -p %p %h"
                        "openssl s_client -connect %h:%p -no_ssl2 -no_ssl3 -ign_eof"))

(setq package-archives `(("gnu" . "https://elpa.gnu.org/packages/")
                         ("melpa" . "https://melpa.org/packages/")))

(package-initialize)

;;;; Set up package tls END

;;;; Set up use-package START

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; use-package-enable-imenu-support must be
;; set before requiring use-package.
(setq use-package-enable-imenu-support t)
(require 'use-package)
;; (setq use-package-verbose t)

(use-package async
  :ensure t
  :config
  (async-bytecomp-package-mode +1))

(use-package use-package-ensure-system-package
  :ensure t)

(use-package use-package-chords
  :ensure t
  :config
  (key-chord-mode 1))

;;;; Set up use-package END

;;;; Init helpers START

(use-package validate
  :ensure t
  :config
  (defalias 'vsetq 'validate-setq))

;; https://oremacs.com/2015/01/17/setting-up-ediff
;; Macro for setting custom variables.
;; Similar to custom-set-variables, but more like setq.
(defmacro csetq (variable value)
  `(funcall (or (get ',variable 'custom-set)
                'set-default)
            ',variable ,value))

;;;; Init helpers END

;;;; Appearance START

;; Get rid of splash screens.
;; From http://www.emacswiki.org/emacs/EmacsNiftyTricks
(vsetq inhibit-splash-screen t)
(vsetq initial-scratch-message nil)

(when (display-graphic-p)
  (setq ns-use-proxy-icon nil)
  (vsetq frame-title-format '("Ⓔ ⓜ ⓐ ⓒ ⓢ")))

(use-package base16-theme
  :ensure t
  :config
  (load-theme 'base16-atelier-heath t)
  (let ((line (face-attribute 'mode-line :underline)))
    (set-face-attribute 'mode-line          nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :overline   line)
    (set-face-attribute 'mode-line-inactive nil :underline  line)
    (set-face-attribute 'mode-line          nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :box        nil)
    (set-face-attribute 'mode-line-inactive nil :background "#695d69")))

;; No color for fringe, blends with the rest of the window.
(set-face-attribute 'fringe nil :background nil)

;; Ensure window is maximized after window setup.
(use-package maxframe
  :ensure t
  :hook (window-setup . maximize-frame))

(use-package moody
  :ensure t
  :config
  (vsetq x-underline-at-descent-line t)

  (setq-default mode-line-format
                '(" "
                  mode-line-front-space
                  mode-line-client
                  mode-line-frame-identification
                  mode-line-buffer-identification " " mode-line-position
                  (vc-mode vc-mode)
                  (multiple-cursors-mode mc/mode-line)
                  " " mode-line-modes
                  mode-line-end-spaces))

  (use-package minions
    :ensure t
    :config
    (minions-mode +1))

  (moody-replace-mode-line-buffer-identification)
  (moody-replace-vc-mode))

;;;; Appearance END

(add-hook
 'emacs-startup-hook
 (lambda ()
   ;; Undo GC values post init.el.
   (vsetq gc-cons-threshold 16777216
          gc-cons-percentage 0.1)
   (run-with-idle-timer 5 t #'garbage-collect)
   (vsetq garbage-collection-messages t)
   (setq file-name-handler-alist ar/init--file-name-handler-alist)

   (message "Emacs ready in %s with %d garbage collections."
            (format "%.2f seconds"
                    (float-time
                     (time-subtract after-init-time before-init-time)))
            gcs-done)

   ;; Additional load paths.
   (add-to-list 'load-path "~/.emacs.d/ar")
   (add-to-list 'load-path "~/.emacs.d/local")
   (add-to-list 'load-path "~/.emacs.d/external")

   (use-package server
     :defer 10
     :config
     (unless (server-running-p)
       (server-start)))

   (use-package s
     :ensure t)

   ;; Ask shell for PATH, MANPATH, and exec-path and update Emacs environment.
   ;; We do this early on as we assert binaries are installed throughout
   ;; init.
   (use-package exec-path-from-shell
     :ensure t
     :config
     (exec-path-from-shell-initialize))
   (load "~/.emacs.d/features/ivy.el")
   (load "~/.emacs.d/features/maintenance.el")
   (load "~/.emacs.d/features/ui.el")
   (load "~/.emacs.d/features/files.el")
   (load "~/.emacs.d/features/editing.el")
   (load "~/.emacs.d/features/git.el")
   (load "~/.emacs.d/features/navigation.el")
   (load "~/.emacs.d/features/platform.el")
   (load "~/.emacs.d/features/helm.el")
   (load "~/.emacs.d/features/file.el")
   (load "~/.emacs.d/features/hydra.el")
   (load "~/.emacs.d/features/eshell.el")
   (load "~/.emacs.d/features/org.el")
   (load "~/.emacs.d/features/dired.el")
   (load "~/.emacs.d/features/dev.el")
   (load "~/.emacs.d/features/company.el")
   (load "~/.emacs.d/features/objc.el")
   (load "~/.emacs.d/features/elfeed.el")
   (load "~/.emacs.d/features/modal.el")
   (load "~/.emacs.d/features/mail.el")
   (dolist (file (file-expand-wildcards "~/.emacs.d/work/*.el"))
     (load file))))

(provide 'init)
;;; init.el ends here

;; Local Variables:
;; compile-command: "make newinit"
;; End:
