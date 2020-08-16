;;; -*- lexical-binding: t; -*-

(defun ar/swift-mode-hook ()
    "Called when entering `swift-mode'."
    (set-fill-column 100)
    (if (buffer-file-name)
        (when-let ((lint-config-file (locate-dominating-file (buffer-file-name)
                                                             ".swiftlint.yml")))
          (setq-local flycheck-swiftlint-config-file
                      (concat (file-name-as-directory
                               lint-config-file)
                              ".swiftlint.yml")))
      (message "No buffer filename in swift mode."))
    (setq-local company-backends '(company-swimports company-capf)))

  (require 'flycheck)
  (add-to-list 'flycheck-checkers 'swiftlint)

  (require 'company-swimports)
  (require 'flycheck-swiftlint)

  ;; Unset swift-mode:send-region. I prefer my default (ivy-resume).
  (bind-key "C-c C-r" nil swift-mode-map)

  (require 'info-look)
  (info-lookup-maybe-add-help
   :mode 'swift-mode
   :regexp "[#@_a-zA-Z][_a-zA-Z0-9]*"
   :doc-spec '(("(swift)Index" nil "['`‘]" "['’]")))

  (when (require 'reformatter nil 'noerror)
    (reformatter-define swift-format
      :program "swift-format"
      :args (let ((buffer (current-buffer))
                  (config-file (locate-dominating-file (buffer-file-name)
                                                       ".swift-format.json"))
                  (temp-file-path (make-temp-file "swift-format-")))
              (with-temp-file temp-file-path
                (insert-buffer buffer))
              (if config-file
                  (list "--configuration" config-file "-m" "format" temp-file-path))
              (list "-m" "format" temp-file-path)))
    (add-hook 'swift-mode-hook 'swift-format-on-save-mode))

  (defun ar/xcode-info ()
    (interactive)
    (shell-command "system_profiler SPDeveloperToolsDataType"))

  (defun ar/swift-public-interface ()
    "Open an occur buffer with file's public interface."
    (interactive)
    (assert (eq major-mode 'swift-mode) nil "Not in swift-mode")
    (let ((list-matching-lines-face nil))
      (occur "\\(public\\)\\|\\(open\\)")))

  ;; Curated Swift 5.1 documentation with cross-references, and keyword/topic indices.
  (use-package swift-helpful
    :ensure t
    :commands swift-helpful)