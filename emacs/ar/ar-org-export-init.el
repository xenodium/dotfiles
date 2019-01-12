(package-initialize)

(require 'use-package)

(add-to-list 'load-path "~/.emacs.d/ar")
(add-to-list 'load-path "~/.emacs.d/local")
(add-to-list 'load-path "~/.emacs.d/external")

;; Temporary fix for exporting error:
;; Symbol’s value as variable is void: org-src-lang-modes
(defvar org-src-lang-modes nil)

(load "~/.emacs.d/features/package-extensions.el")
(load "~/.emacs.d/features/libs.el")
(load "~/.emacs.d/features/mac.el")
(load "~/.emacs.d/features/linux.el")
(load "~/.emacs.d/features/org.el")
(load "~/.emacs.d/ar/ar-ox-html.el")

(use-package whitespace)

(use-package github-theme
  :ensure t
  :config
  (load-theme 'github t)

  (with-eval-after-load 'org-faces
    (set-face-attribute 'org-link nil :underline nil)
    ;; Disable whitespace mode.
    (set-face-attribute 'whitespace-line nil
                        :foreground nil
                        :background nil)))

(ar/ox-html-export)
