(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.org/packages/") t)

(setq-default line-spacing 3)

(require 'clang-format)
(require 'dired-x)
(require 'git-gutter)
(require 'google-c-style)
(require 'guess-style)
(require 'ido)
(require 'protobuf-mode)
(require 'saveplace)
(require 'template)
(require 'uniquify)
(require 'yaml-mode)

(require 'whitespace)
(setq whitespace-style '(face empty tabs lines-tail trailing))
(global-whitespace-mode t)

(setq grep-use-null-device nil)

(setq-default dired-listing-switches "-alhv")
(setq dired-recursive-copies t)
(global-auto-revert-mode t)

(add-hook 'shell-mode-hook
          #'(lambda ()
              (dirtrack-mode 1)))

(desktop-save-mode t)

(visit-tags-table (concat development-base "TAGS"))

(add-to-list 'default-frame-alist '(height . 80))
(add-to-list 'default-frame-alist '(width . 90))

(defun parent-directory (dir)
  (unless (equal "/" dir)
    (file-name-directory (directory-file-name dir))))

(defun find-file-upwards (file-to-find)
  "Recursively searches each parent directory starting from the default-directory.
looking for a file with name file-to-find.  Returns the path to it
or nil if not found."
  (cl-labels
      ((find-file-r (path)
                    (let* ((parent (file-name-directory path))
                           (possible-file (concat parent file-to-find)))
                      (cond
                       ((file-exists-p possible-file)
                        (parent-directory possible-file)) ; Found
                       ;; The parent of ~ is nil and the parent of / is itself.
                       ;; Thus the terminating condition for not finding the file
                       ;; accounts for both.
                       ((or (null parent)
                            (equal parent (directory-file-name parent))) nil) ; Not found
                       (t (find-file-r (directory-file-name parent))))))) ; Continue
    (find-file-r default-directory)))

(defun swirly-compile()
  "Run compile in the git directory."
  (interactive)
  (let ((default-directory (find-file-upwards ".git")))
    (call-interactively 'compile)))

(defun swirly-grep()
  "Run grep in the src/ripple directory."
  (interactive)
  (let ((default-directory
          (expand-file-name "src/ripple/" (find-file-upwards ".git"))))
    (call-interactively 'grep)))

(defun kill-matching-buffers (match)
  (interactive "sMatching string: ")
  (if (equal match "")
      (message "Cancelled.")
    (let*
        ((buffers (buffer-list))
         (delete-count 0)
         )
      (while buffers
        (let*
            ((buf (pop buffers))
             (filename (buffer-file-name buf)))
          (if filename
              (progn
                (message (concat match " : " filename))
                (if (string-match match filename)
                    (progn
                      (message (concat match " !! " filename))
                      (kill-buffer buf)
                      (setq delete-count (1+ delete-count))
                      (message buf)
                      )))))))))

;; (setq dired-omit-files
;;       (rx (or
;;            (seq bol (? ".") "#")         ;; emacs autosave files
;;            (seq "~" eol)                 ;; backup-files
;;            (seq ".pyc" eol)              ;; compiled python files
;;            (seq ".pyo" eol)              ;; compiled python files
;;            (seq bol "CVS" eol)           ;; CVS dirs
;; )))

(add-hook 'dired-mode-hook
          (lambda ()
            (dired-omit-mode t)
            ))

(add-hook 'python-mode-hook
          (lambda ()
            (git-gutter-mode t)
            ))

(add-hook 'yaml-mode-hook
          (lambda ()
            (define-key yaml-mode-map "\C-m" 'newline-and-indent)
            ))

(add-hook 'write-file-hooks
          'delete-trailing-whitespace
)

(add-hook 'c-mode-common-hook 'google-set-c-style)
(add-hook 'c-mode-common-hook 'google-make-newline-indent)

;; (defun my-python-mode-common-hook ()
;;   (setq python-basic-offset 4)
;; ;;  (define-key python-mode-map "\C-m" 'newline-and-indent)
;; )

;; (add-hook 'python-mode-common-hook 'my-python-mode-common-hook)

(global-font-lock-mode t)
(column-number-mode t)
(auto-compression-mode t)


(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.proto\\'" . protobuf-mode))
(add-to-list 'auto-mode-alist '("\\.(inl|proto)\\'"   . c-mode))
(add-to-list 'auto-mode-alist '("\\.(js|json)\\'"   . javascript-mode))
(add-to-list 'auto-mode-alist '("\\.pyx\\'" . python-mode))
(add-to-list 'auto-mode-alist '("SConstruct" . python-mode))

(template-initialize)
(blink-cursor-mode nil)

(setq uniquify-buffer-name-style 'post-forward-angle-brackets)
(setq zoom-font-frame-local-flag nil)

(setq backup-by-copying-when-mismatch t)

(defun make-auto-save-file-name ()
  (concat autosave-dir
   (if buffer-file-name
      (concat "#" (file-name-nondirectory buffer-file-name) "#")
    (expand-file-name
     (concat "#%" (buffer-name) "#")))))


;; Put backup files (ie foo~) in one place too. (The backup-directory-alist
;; list contains regexp=>directory mappings; filenames matching a regexp are
;; backed up in the corresponding directory. Emacs will mkdir it if necessary.)
(defvar backup-dir (concat "/tmp/emacs_backups/" (user-login-name) "/"))

(setq backup-directory-alist (list (cons "." backup-dir)))

;;;     Auto save and backup file configuration.

;;; newer backup code....
(setq backup-by-copying-when-linked t   ; handle links correctly
      delete-auto-save-files t          ; leave no "#" files in home directory
      kept-new-versions 10              ; keep 10 backups plus 2 oldest backups
      delete-old-versions t             ; delete excess backups silently
      version-control t)                ; make backup versions unconditionally

(defun normal-backup-enable-predicate (name)
 "Return T so that auto save files are always created, no matter where
the original file is stored."
 t)

;;  Make all auto-save files go into my garbage directory.  When root or others
;;  load my .emacs file, $_GARBAGE will not be set, so auto-save files will be
;;  put in /tmp.
(defvar auto-save-file-prefix
 (cond ((equal system-type 'windows-nt)
        (expand-file-name (concat (getenv "TMPDIR") "/")))
       ;; Root may not be able to write to the current user's backup
       ;; directory, since it may be NFS mounted from another host.
       ((equal (user-real-login-name) "root") "/tmp/")
       ((getenv "_GARBAGE") (concat (getenv "_GARBAGE") "/"))
       (t "/tmp/"))
     "*Prefix to prepend to all auto-save filenames.")

(defun make-auto-save-file-name ()
 "Return file name to use for auto-saves of current buffer."
 (concat auto-save-file-prefix
         "#"
         (if buffer-file-name
             (file-name-nondirectory buffer-file-name)
           (concat "%" (buffer-name)))
         "#"))

(defun auto-save-file-name-p (filename)
 "Return t if FILENAME can be yielded by make-auto-save-file-name.
FILENAME should lack slashes."
 (string-match (concat "^" auto-save-file-prefix "#.*#$") filename))

(defadvice switch-to-buffer (before existing-buffers-only activate)
  "When called interactively, switch to existing buffers only except when called with a prefix argument."
  (interactive
   (list (read-buffer "Switch to buffer: " (other-buffer)
                      (null current-prefix-arg)))))

(defadvice find-file (before existing-files-only activate)
  "When called interactively, only open existing files except when called with a prefix argument."
  (interactive
   (list (read-file-name "Find file: "
                         default-directory
                         nil
                         (null current-prefix-arg)))))

(put 'dired-find-alternate-file 'disabled nil)

(defun cycle-windows (&optional reverse)
   "Cycle the windows' buffers. If given a prefix argument, cycle in reverse."
   (interactive "P")
   (dolist (window (butlast (if reverse (reverse (window-list)) (window-list))))
     (let
       ((next-window-buffer (window-buffer (next-window window 0))))
       (set-window-buffer (next-window window 0) (window-buffer window))
       (set-window-buffer window next-window-buffer)))
   )

(defun mapcar-head (fn-head fn-rest list)
      "Like MAPCAR, but applies a different function to the first element."
      (if list
          (cons (funcall fn-head (car list)) (mapcar fn-rest (cdr list)))))

(defun camelize (s)
  "Convert under_score string S to CamelCase string."
  (mapconcat 'identity (mapcar
                        '(lambda (word) (capitalize (downcase word)))
                        (split-string s "_")) ""))

(defun camelize-method (s)
  "Convert under_score string S to camelCase string."
  (mapconcat 'identity (mapcar-head
                        '(lambda (word) (downcase word))
                        '(lambda (word) (capitalize (downcase word)))
                        (split-string s "_")) ""))

(defun split-name (s)
  (split-string
   (let ((case-fold-search nil))
     (downcase
      (replace-regexp-in-string "\\([a-z]\\)\\([A-Z]\\)" "\\1 \\2" s)))
   "[^A-Za-z0-9]+"))

(defun camelcase   (s) (mapconcat 'capitalize (split-name s) ""))
(defun underscore  (s) (mapconcat 'upcase     (split-name s) "_"))
;; (defun underscored (s) (mapconcat 'downcase   (split-name s) "_"))
;; (defun dasherize   (s) (mapconcat 'downcase   (split-name s) "-"))
;; (defun colonize    (s) (mapconcat 'capitalize (split-name s) "::"))
(defun locamel     (s)
  (mapconcat 'identity
             (mapcar-head 'downcase 'capitalize (split-name s))
             ""))

(defun camelscore (s)
  (cond ;; ((string-match-p "\\(?:[a-z]+_\\)+[a-z]+" s)	(dasherize  s))
        ((string-match-p "\\(?:[A-Z]+_\\)+[A-Z]+" s)	(locamel  s))
        ((string-match-p "\\(?:[A-Z][a-z]+\\)+$"  s)	(underscore  s)) ;; (locamel   s))
        (t						(camelcase s)) ))

(defun camelscore-word-at-point ()
  (interactive)
  (let* ((case-fold-search nil)
         (beg (and (skip-chars-backward "[:alnum:]_") (point)))
         (end (and (skip-chars-forward  "[:alnum:]_") (point)))
         (txt (buffer-substring beg end))
         (cml (camelscore txt)) )
    (if cml (progn (delete-region beg end) (insert cml))) ))

(defun rotate-file-suffix (file)
  "Returns one rotation through the file"
  (let* ((patterns
        '(
          ("\\.test\\.cpp" ".h")
          ("\\.h" ".cpp")
          ("\\.cpp" ".proto")
          ("\\.proto" ".test.cpp")
          ("\\.cc" ".h")
          ("\\.cpp" ".test.cpp")
          ("\\.cpp" ".pyx")
          ("\\.pyx" ".h")
          ("_test\\.py" ".py")
          ("\\.py" "_test.py")
          ))
         (working t))
  (while (and patterns working)
    (setq pattern (pop patterns))
    (if (string-match (car pattern) file)
        (progn
          (setq file
                (replace-regexp-in-string (car pattern)
                                          (cadr pattern)
                                          file))
          (setq working nil)))))
  file)

(defun try-file-directories (file)
  "Tries different possibilities to see if a file exists."
  (let* ((body (file-name-nondirectory file))
         (directory (file-name-directory file))

         (super (file-name-directory (directory-file-name directory)))

         (result-api (concat directory (file-name-as-directory "api") body))
         (result-impl (concat directory (file-name-as-directory "impl") body))
         (result-test (concat directory (file-name-as-directory "tests") body))
         (result-super (concat super body))
         (result-super-api (concat super (file-name-as-directory "api") body))
         (result-super-impl (concat super (file-name-as-directory "impl") body))
         (result-super-test (concat super (file-name-as-directory "tests") body))
         )
    (progn
      ;; (message (concat "1. " file " -> " result-impl ", "
      ;;                  result-super ", " result-super-api ", " result-super-impl))
      (cond
       ((file-readable-p result-api) result-api)
       ((file-readable-p result-impl) result-impl)
       ((file-readable-p result-test) result-test)
       ((file-readable-p result-super) result-super)
       ((file-readable-p result-super-api) result-super-api)
       ((file-readable-p result-super-impl) result-super-impl)
       ((file-readable-p result-super-test) result-super-test)
       (t file))
      )
    )
  )

(defun rotate-tests ()
  "Rotate between a file and its test file."
  (interactive)
  (let* ((filename (buffer-file-name))
         (new-file filename)
         (working2 t)
         (found nil))
    (while working2
      (setq old-file new-file)
      (setq new-file (rotate-file-suffix new-file))
      (if (or (string= new-file filename)
              (string= new-file old-file))
          (progn (setq working2 nil))  ;; Didn't find a buffer - we're done!
        (progn
          (if (not (file-readable-p new-file))
              (setq new-file (try-file-directories new-file))
            )
          (if (file-readable-p new-file)
              (progn (find-file new-file) (setq working2 nil))))))))

(defun to-two()
  (interactive)
  (delete-other-windows)
  (split-window-vertically)
)

(defun do-list-buffers()
  (interactive)
  (list-buffers)
  (other-window '1)
)

(defun do-two-list-buffers()
  (interactive)
  (to-two)
  (do-list-buffers)
)

(defun rotate-in-two ()
  "Kill all the other windows, split this one, rotate the other window, come back here."
  (interactive)
  (to-two)
  (other-window 1)
  (rotate-tests)
  (other-window 1)
)

(defun default-dired ()
  (interactive)
  (dired default-directory)
)

(defun default-dired-two ()
  (interactive)
  (to-two)
  (default-dired)
)

(defun home-dired ()
  (interactive)
  (dired "/Users/tom/Documents/development/rec/src/rec")
)

(defun home-dired-two ()
  (interactive)
  (to-two)
  (other-window 1)
  (home-dired)
)

(defun reload-file()
  (interactive)
  (find-alternate-file (buffer-file-name))
)

(defun shell-two()
  (interactive)
  (to-two)
  (shell)
)

(defun switch-to-buffer-two()
  (interactive)
  (to-two)
  (switch-to-buffer)
)

(defun find-file-two()
  (interactive)
  (to-two)
  (find-file)
)

(defun toggle-window-dedicated ()
  "Toggle whether the current active window is dedicated or not"

  (interactive)
  (message
   (if (let (window (get-buffer-window (current-buffer)))
         (set-window-dedicated-p window
                                 (not (window-dedicated-p window))))
       "Window '%s' is dedicated"
     "Window '%s' is normal")
   (current-buffer)))

(global-set-key [s-z] 'undo)

(global-set-key [f1] 'next-error)
(global-set-key [s-f1] 'goto-line)

(global-set-key [f2] 'rotate-tests)
(global-set-key [s-M-up] 'rotate-tests)
(global-set-key [s-f2] 'rotate-windows)

(global-set-key [f3] 'do-list-buffers)

(global-set-key [f4] 'switch-to-buffer)
(global-set-key [s-f4] 'shell)

(global-set-key [f5] 'find-file)
(global-set-key [s-f5] 'reload-file)

(global-set-key [f7] 'swirly-compile)

;;(global-set-key [f6] 'server-edit)
;;(global-set-key [f6] 'git-commit-commit)
(global-set-key [f6] 'magit-status)

(global-set-key [f8] 'swirly-grep)

(defun to-grep() (interactive) (switch-to-buffer "*grep*"))
(global-set-key [s-f8] 'to-grep)

(global-set-key [s-f9] 'kmacro-call-macro)
(global-set-key [f9] 'enlarge-window)

(global-set-key [f10] 'query-replace)
(global-set-key [s-f10] 'tags-query-replace)

(global-set-key [s-f11] 'yank-pop)
(global-set-key [f11] 'yank)

(global-set-key [f12] 'keyboard-quit)
(global-set-key [s-f12] 'append-next-kill)

(global-set-key [f13] 'delete-other-windows)
(global-set-key [s-f13] 'to-two)

(global-set-key [f14] 'split-window-vertically)
(global-set-key [s-f14] 'split-window-horizontally)

(global-set-key [f15] 'exchange-point-and-mark)
(global-set-key [s-f15] 'balance-windows)

(global-set-key [C-tab] 'clang-format-region)

(defun back-window()
  (interactive)
  (other-window -1)
)

(global-set-key [s-up] 'back-window)
(global-set-key [s-down] 'other-window)
