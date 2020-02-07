;;; -*- lexical-binding: t; -*-
(use-package yasnippet
  :ensure t
  :validate-custom
  (yas-indent-line 'fixed)
  (yas-triggers-in-field t)
  :commands (yas-expand
             yas-minor-mode)
  :config
  (use-package ar-yas
    :commands (ar/yas-install--github-yasnippets
               ar/yas-install-external-yasnippets))

  (use-package yasnippet-snippets
    :ensure t)

  (add-to-list 'yas-snippet-dirs
               "~/.emacs.d/yasnippets/personal" t)

  (yas-reload-all))
