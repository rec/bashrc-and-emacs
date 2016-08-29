(require 'package)
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(require 'cython-mode)
(require 'git-gutter)
(require 'google-c-style)
(require 'guess-style)
(require 'markdown-mode)
(require 's)
(require 'saveplace)
(require 'uniquify)
(require 'yaml-mode)

;; (require 'clang-format)
;; (require 'dired-x)
;; (require 'ido)
;; (require 'jump-to-next-pos)
;; (require 'python-mode)
;; (require 'template)
;; (require 'whitespace)
;; (require 'zop-to-char)