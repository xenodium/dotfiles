(require 'ar-vsetq)

(use-package helm
  ;; Save current position to mark ring when jumping to a different place
  :hook  (helm-goto-line-before . helm-save-current-pos-to-mark-ring)
  :ensure t
  :config
  (use-package helm-utils)
  (use-package helm-elisp
    :config
    ;; Helm now defaults to 'helm-display-buffer-in-own-frame. Override this behavior.
    (ar/vsetq helm-show-completion-display-function #'helm-default-display-buffer))

  (ar/vsetq helm-scroll-amount 4) ; scroll 4 lines other window using M-<next>/M-<prior>
  (ar/vsetq helm-input-idle-delay 0.01) ; be idle for this many seconds, before updating candidate buffer
  (ar/vsetq helm-split-window-default-side 'below) ;; open helm buffer below.
  (ar/vsetq helm-split-window-in-side-p t)
  (ar/vsetq helm-candidate-number-limit 200)

  (use-package helm-config)

  (use-package helm-imenu
    :defer t
    :config
    (use-package imenu
      :config
      ;; Automatically rescan for imenu changes.
      (set-default 'imenu-auto-rescan t))
    (use-package imenu-anywhere
      :ensure t))

  (defun ar/helm-keyboard-quit-dwim (&optional arg)
    "First time clear miniuffer. Quit thereafter."
    (interactive "P")
    (if (> (length (minibuffer-contents)) 0)
        (call-interactively 'helm-delete-minibuffer-contents)
      (helm-keyboard-quit)))

  :bind (:map helm-map
         ("C-i" . helm-execute-persistent-action) ; make TAB works in terminal
         ("C-z" . helm-select-action) ; list actions using C-z
         ("M-p" . helm-previous-source)
         ("M-n" . helm-next-source)
         ("C-g" . ar/helm-keyboard-quit-dwim)))

;; Differentiate C-i key binding from TAB.
(define-key input-decode-map (kbd "C-i") (kbd "H-i"))
