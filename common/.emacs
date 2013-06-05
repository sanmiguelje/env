;; Don't Show Warnings
(setq warning-minimum-level 'error)
(setq warning-minimum-log-level 'error)

;; Fix for ECB
(setq stack-trace-on-error t)
(setq ecb-tip-of-the-day nil)

;; Follow symlinks
(setq vc-follow-symlinks t)

(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/ecb/")
(add-to-list 'load-path "~/.emacs.d/web-mode/")
(add-to-list 'load-path "~/.emacs.d/rinari/")
(add-to-list 'load-path "~/.emacs.d/rhtml")
(add-to-list 'load-path "~/.emacs.d/php-mode")
(add-to-list 'load-path "~/.emacs.d/haml-mode")
(add-to-list 'load-path "~/.emacs.d/coffee-mode")
(add-to-list 'load-path "~/.emacs.d/nginx-mode")
(add-to-list 'load-path "~/.emacs.d/scss-mode")

;; load some files
(require 'rinari) ;; Rinari
(require 'ido) ;; Interactively Do Things (highly recommended, but not strictly required)
(require 'rspec-mode)
(require 'simple-wiki)
(require 'ecb)
(require 'web-mode)
(require 'rhtml-mode)
(require 'php-mode)
(require 'haml-mode)
(require 'coffee-mode)
(require 'sass-mode)
(require 'scss-mode)
(require 'nginx-mode)
(load "ws-trim")

(ido-mode t)

;; Rinari Vars
(setq
 nxhtml-global-minor-mode t
 mumamo-chunk-coloring 'submode-colored
 nxhtml-skip-welcome t
 indent-region-mode t
 rng-nxml-auto-validate-flag nil
 nxml-degraded t)

;; mode loaders
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.jsp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . rhtml-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("[.]stub_data$" . javascript-mode))
(add-to-list 'auto-mode-alist '("[.]wiki$" . simple-wiki-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.C\\'" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.rake\\'" . ruby-mode))
(add-to-list 'auto-mode-alist '("\\.css\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.scss\\'" . css-mode))
(add-to-list 'auto-mode-alist '("\\.php\\'" . php-mode))
(add-to-list 'auto-mode-alist '("\\.haml\\'" . haml-mode))
(add-to-list 'auto-mode-alist '("\\.coffee\\'" . coffee-mode))
(add-to-list 'auto-mode-alist '("\\.scss\\'" . scss-mode))
(add-to-list 'auto-mode-alist '("\\.sass\\'" . sass-mode))
(add-to-list 'auto-mode-alist '("\\.py\\'" . python-mode))

(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
;;(setq indent-line-function 'insert-tab)

;; ws-trim settings
(global-ws-trim-mode t)
(set-default 'ws-trim-level 1)
(add-hook 'ws-trim-method-hook 'no-tabs-hook)
(defun no-tabs-hook ()
  (interactive)
  (if (string/= major-mode "html-mode")
      (ws-trim-tabs)))

(put 'upcase-region 'disabled nil)

;; turn off tabs
(setq-default indent-tabs-mode nil)

;; set line width
(setq-default fill-column 120)

;; set tab stops
(setq tab-stop-list (number-sequence 4 120 4))

;; move directory where backups are saved
(defvar user-temporary-file-directory
  (concat temporary-file-directory user-login-name "/"))
(make-directory user-temporary-file-directory t)
(setq backup-by-copying t)
(setq backup-directory-alist
      `(("." . ,user-temporary-file-directory)
        (,tramp-file-name-regexp nil)))
(setq auto-save-list-file-prefix
      (concat user-temporary-file-directory ".auto-saves-"))
(setq auto-save-file-name-transforms
      `((".*" ,user-temporary-file-directory t)))

;; ruby mode settings
(add-hook 'ruby-mode-hook
          (lambda ()
            (setq show-trailing-whitespace t)
            (local-set-key "\r" 'reindent-then-newline-and-indent)
            (setq indent-tabs-mode nil)
            (setq ruby-deep-indent-paren nil)
            (setq ruby-indent-tabs-mode nil)))
;;            (add-hook 'before-save-hook
;;                      (lambda () (if (not indent-tabs-mode)
;;                                     (untabify (point-min) (point-max)))))))
(setq ruby-indent-level 4)

(defadvice ruby-indent-line (after unindent-closing-paren activate)
  (let ((column (current-column))
        indent offset)
    (save-excursion
      (back-to-indentation)
      (let ((state (syntax-ppss)))
        (setq offset (- column (current-column)))
        (when (and (eq (char-after) ?\))
                   (not (zerop (car state))))
          (goto-char (cadr state))
          (setq indent (current-indentation)))))
    (when indent
      (indent-line-to indent)
      (when (> offset 0) (forward-char offset)))))

(defadvice ruby-indent-line (after line-up-args activate)
  (let (indent prev-indent arg-indent)
    (save-excursion
      (back-to-indentation)
      (when (zerop (car (syntax-ppss)))
        (setq indent (current-column))
        (skip-chars-backward " \t\n")
        (when (eq ?, (char-before))
          (ruby-backward-sexp)
          (back-to-indentation)
          (setq prev-indent (current-column))
          (skip-syntax-forward "w_.")
          (skip-chars-forward " ")
          (setq arg-indent (current-column)))))
    (when prev-indent
      (let ((offset (- (current-column) indent)))
        (cond ((< indent prev-indent)
               (indent-line-to prev-indent))
              ((= indent prev-indent)
               (indent-line-to (+ prev-indent ruby-indent-level))))
        (when (> offset 0) (forward-char offset))))))

;; python mode
(add-hook 'python-mode-hook
          (lambda () (semantic-mode)))

;; rhtml mode
(add-hook 'rhtml-mode-hook
          (lambda () (rinari-launch)))

;; web mode
(add-hook 'web-mode-hook
          (lambda ()
            (setq web-mode-markup-indent-offset 4)
            (setq show-trailing-whitespace t)
            (local-set-key "\r" 'reindent-then-newline-and-indent)
            (setq indent-tabs-mode nil)))

;; c mode settings
(add-hook 'c-mode-hook
          (lambda ()
            (setq c-basic-offset 2)))

;; html-mode settings
(add-hook 'html-mode-hook
          (lambda ()
            (setq sgml-basic-offset 4)
            (setq indent-tabs-mode nil)))

;; xml-mode settings
(add-hook 'nxml-mode-hook
          (lambda ()
            (setq nxml-child-indent 4)))

;; coffee-mode settings
(add-hook 'coffee-mode-hook
          (lambda ()
            (setq tab-width 2)))

;; whitespace settings
(autoload 'whitespace-mode           "whitespace" "Toggle whitespace visualization."        t)
(autoload 'whitespace-toggle-options "whitespace" "Toggle local `whitespace-mode' options." t)

(global-set-key (kbd "C-x w") 'delete-trailing-whitespace)
(global-set-key (kbd "C-n") 'newline)

(defun move-line (n)
  "Move the current line up or down by N lines."
  (interactive "p")
  (setq col (current-column))
  (beginning-of-line) (setq start (point))
  (end-of-line) (forward-char) (setq end (point))
  (let ((line-text (delete-and-extract-region start end)))
    (forward-line n)
    (insert line-text)
    ;; restore point to original column in moved line
    (forward-line -1)
    (forward-char col)))

(defun move-line-up (n)
  "Move the current line up by N lines."
  (interactive "p")
  (move-line (if (null n) -1 (- n))))

(defun move-line-down (n)
  "Move the current line down by N lines."
  (interactive "p")
  (move-line (if (null n) 1 n)))

(global-set-key (kbd "ESC <up>") 'move-line-up)
(global-set-key (kbd "ESC <down>") 'move-line-down)

(define-key global-map (kbd "RET") 'newline-and-indent)

;; aquamacs set opacity
(add-to-list 'default-frame-alist '(alpha . (80 70)))
;; aquamacs switch to white on black
(require 'color-theme)
(color-theme-clarity)

(defface extra-whitespace-face
  '((t (:background "pale green")))
  "Used for tabs and such.")
(defvar my-extra-keywords
  '(("\t" . 'extra-whitespace-face)))
(add-hook 'emacs-lisp-mode-hook
          (lambda () (font-lock-add-keywords nil my-extra-keywords)))
(add-hook 'text-mode-hook
          (lambda () (font-lock-add-keywords nil my-extra-keywords)))
(add-hook 'c-mode-common-hook
          (lambda () (font-lock-add-keywords nil my-extra-keywords)))

(defun duplicate-line()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank)
  )
(global-set-key (kbd "C-d") 'duplicate-line)

;; Indent Rigidly N
(defun indent-rigidly-n (n)
  "Indent the region, or otherwise the current line, by N spaces."
  (let* ((use-region (and transient-mark-mode mark-active))
         (rstart (if use-region (region-beginning) (point-at-bol)))
         (rend   (if use-region (region-end)       (point-at-eol)))
         (deactivate-mark "irrelevant")) ; avoid deactivating mark
    (indent-rigidly rstart rend n)))
(defun indent-rigidly-4 ()
  "Indent the region, or otherwise the current line, by 4 spaces."
  (interactive)
  (indent-rigidly-n 4))
(defun outdent-rigidly-4 ()
  "Indent the region, or otherwise the current line, by -4 spaces."
  (interactive)
  (indent-rigidly-n -4))
(defun outdent-rigidly-2 ()
  "Indent the region, or otherwise the current line, by -2 spaces."
  (interactive)
  (indent-rigidly-n -2))
(global-set-key (kbd "M-<tab>") 'indent-rigidly-4)
(global-set-key (kbd "C-M-<tab>") 'outdent-rigidly-4)

;; force tab
(global-set-key (kbd "C-<tab>") 'tab-to-tab-stop)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ecb-options-version "2.40")
 '(safe-local-variable-values (quote ((setq ruby-indent-tabs-mode nil) (ruby-compilation-executable . "ruby") (ruby-compilation-executable . "ruby1.8") (ruby-compilation-executable . "ruby1.9") (ruby-compilation-executable . "rbx") (ruby-compilation-executable . "jruby")))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )


;; Start Everything I want to
(ecb-activate)
