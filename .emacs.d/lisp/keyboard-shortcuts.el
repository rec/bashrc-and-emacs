(defalias 'gsk 'global-set-key)

(defun shrink-window()
  (interactive)
  (enlarge-window -1)
  )

(defun trim-string (string)
  "Remove white spaces in beginning and ending of STRING.
White space here is any of: space, tab, emacs newline (line feed, ASCII 10)."
  (replace-regexp-in-string
   "\\`[ \t\n]*" ""
   (replace-regexp-in-string "[ \t\n]*\\'" "" string))
  )

(defun run-shell(x) (trim-string (shell-command-to-string x)))

(defun swirly-to-root()
  (interactive)
  (dired (run-shell "/development/grit/Root.py"))
)

(setq default-prefix "")

(defun swirly-find-file-body(direction)
  (let ((file (run-shell
               (concat "/development/grit/Grit.py efind "
                       default-prefix
                       " "
                       (buffer-file-name)
                       " "
                       direction))))
    (if (string-equal file "")
        (error "Pattern not found")
      (if (file-exists-p file)
          (find-file file)
        (error "File not found")))))


(defun swirly-find-file(prefix)
  (interactive (list (read-string "Find by prefix: ")) )
  (setq default-prefix prefix)
  (swirly-find-file-body "+")
)

(defun swirly-find-file-next()
  (interactive)
  (swirly-find-file-body "+")
)

(defun swirly-find-file-prev()
  (interactive)
  (swirly-find-file-body "-")
)

(defun swirly-run-python() (interactive)
  (let ((buf (get-buffer "*Python*")))
    (if (eq nil buf)
        (run-python)
      (switch-to-buffer "*Python*"))))


;; Clear can't be used.
(gsk [kp-equal] 'balance-windows)
(gsk [kp-divide] 'kmacro-call-macro)
(gsk [kp-multiply] 'keyboard-escape-quit)

(gsk [home] 'swirly-to-root)
(gsk [kp-up] 'back-window)  (gsk [s-kp-up] 'swirly-find-file-prev)
(gsk [kp-prior] 'shrink-window)
(gsk [kp-subtract] 'delete-window)

(gsk [kp-left] 'jump-to-prev-pos)
(gsk [kp-begin] 'exchange-point-and-mark)  (gsk [s-kp-begin] 'swirly-find-file)
(gsk [kp-right] 'jump-to-next-pos)
(gsk [kp-add] 'split-window-vertically)

;; End can't be used.
(gsk [kp-down] 'other-window)   (gsk [s-kp-down] 'swirly-find-file-next)
(gsk [kp-next] 'enlarge-window)
(gsk [kp-enter] 'repeat-complex-command)

(gsk [kp-delete] 'other-frame)  (gsk [s-kp-delete] 'delete-frame)

(gsk [prior] 'scroll-down-command)
(gsk [next] 'scroll-up-command)

(defun swirly-kill-buffer()
  (interactive)
  (kill-buffer)
)

(gsk [f1] 'next-error)            (gsk [s-f1] 'goto-line)
(gsk [f2] 'rotate-tests)
(gsk [f3] 'switch-to-buffer)      (gsk [s-f3] 'swirly-kill-buffer)
(gsk [f4] 'do-list-buffers)
(gsk [f5] 'find-file)             (gsk [s-f5] 'reload-file)
(gsk [f6] 'git-commit-commit)     (gsk [s-f6] 'magit-status)
(gsk [f7] 'swirly-compile)        (gsk [s-f7] 'to-compile)
(gsk [f8] 'swirly-grep)           (gsk [s-f8] 'to-grep)
(gsk [f9] 'dabbrev-expand)
(gsk [f10] 'query-replace)
(gsk [f11] 'shell)                (gsk [s-f11] 'swirly-run-python)
(gsk [f12] 'kill-line)            (gsk [s-f12] 'kill-ring-save)
(gsk [f13] 'yank)                 (gsk [s-f13] 'yank-pop)

(gsk [f14] 'save-buffer)          (gsk [s-f14] 'save-some-buffers)
(gsk [Scroll_Lock] 'save-buffer)  (gsk [s-Scroll_Lock] 'save-some-buffers)

(gsk [f15] 'undo)
(gsk [pause] 'undo)

(gsk [s-z] 'undo)
(gsk [M-z] 'zop-to-char)

;; TODO:
;; (gsk [s-f11] 'append-next-kill)
;; (gsk [s-f4] 'switch-to-buffer-other-frame)
;; run-python doesn't switch to Python shell if it exists.
