;;; ar-bazel.el --- Bazel support.

;;; Commentary:
;; Bazel helpers.


;;; Code:

(require 'ar-file)
(require 's)
(require 'f)
(require 'dash)

(defvar ar/bazel-compile-command "bazel build --ios_minimum_os=8.2")

(defun ar/bazel-compile ()
  "Invoke `'compile with `'completing-read a build rule in either current or parent directories."
  (interactive)
  (compile (format "%s %s" ar/bazel-compile-command
                   (ar/bazel-completing-read-build-rule))))

(defun ar/bazel-completing-read-build-rule ()
  "Find a build file in current or parent directories and `'completing-read a build rule."
  (let ((closest-build-file (ar/file-either-closest (if (equal major-mode 'dired-mode)
                                                        default-directory
                                                      (buffer-file-name)) "BUILD")))
    (assert closest-build-file nil "No BUILD found.")
    (format "%s:%s"
            (ar/bazel-qualified-package-path closest-build-file)
            (completing-read "build rule: " (ar/bazel-rule-names-in-build-file-path closest-build-file)))))


(defun ar/bazel-build-rule-names (str)
  (mapcar (lambda (match)
            (nth 1 match))
          ;; match: name = "rulename"
          (s-match-strings-all "name *= *\"\\(.*\\)\""
                               str)))

(defun ar/bazel-rule-names-in-build-file-path (file-path)
  "Get rule names in build FILE-PATH."
  (ar/bazel-build-rule-names (with-temp-buffer
                               (insert-file-contents file-path)
                               (buffer-string))))

(defun ar/bazel-qualified-rule-names-in-build-file-path (file-path)
  "Get qualified rule names in build FILE-PATH."
  (let ((package-path (ar/bazel-qualified-package-path file-path)))
    (-map (lambda (rule-name)
            (format "%s:%s" package-path rule-name))
          (ar/bazel-rule-names-in-build-file-path file-path))))

(defun ar/bazel-qualified-package-path (path)
  "Convert PATH to workspace-qualified package: /some/path/workspace/package/BUILD => //package."
  (replace-regexp-in-string (ar/bazel-workspace-path) "//" (s-chop-suffix "/" (file-name-directory (expand-file-name path)))))

(defun ar/bazel-workspace-path ()
  "Get bazel project path."
  (let ((workspace (locate-dominating-file default-directory "WORKSPACE")))
    (assert workspace nil "Not in a bazel project.")
    (expand-file-name workspace)))

(defun ar/bazel-workspace-build-files ()
  "Get all BUILD files in bazel project."
  (process-lines "find" (ar/bazel-workspace-path) "-name" "BUILD"))

(defun ar/bazel-workspace-build-rules ()
  "Get all workspace qualified rules."
  (-mapcat 'ar/bazel-qualified-rule-names-in-build-file-path
           (ar/bazel-workspace-build-files)))

(defun ar/bazel-insert-rule ()
  "Insert a qualified build rule, with completion."
  (interactive)
  (insert (completing-read "build rule: " (ar/bazel-workspace-build-rules))))

(provide 'ar-bazel)

;;; ar-bazel.el ends here
