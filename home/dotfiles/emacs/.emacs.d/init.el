;;; -*- Coding: iso-2022-7bit -*-
(setq debug-on-error t)

(defun fullscreen ()
  (interactive)
  (set-frame-parameter nil 'fullscreen
                       (if (frame-parameter nil 'fullscreen)
                           nil
                           'fullboth)))

(set-language-environment 'japanese)
(prefer-coding-system 'utf-8-unix)
(set-default-coding-systems 'utf-8-unix)
(set-keyboard-coding-system 'utf-8-unix)
(if (not window-system)
    (set-terminal-coding-system 'utf-8-unix))
(setq default-buffer-file-coding-system 'utf-8-unix)
(setq file-name-coding-system 'utf-8-unix)
(setq locale-coding-system 'utf-8)

(when (eq window-system 'ns)
  (require 'ucs-normalize)
  ;(prefer-coding-system 'utf-8-unix)
  (setq file-name-coding-system 'utf-8-hfs)
  (setq locale-coding-system 'utf-8-hfs)
  (setq ns-command-modifier (quote meta))
  ;(setq ns-alternate-modifier (quote super))
  ;(setq mac-command-modifier 'meta)
  (setq x-select-enable-clipboard t)
  (setq mac-option-modifier nil)
  (setq default-input-method "MacOSX")
  (setq grep-find-use-xargs 'bsd)
  (setq browse-url-generic-program "open")
  (add-hook 'window-setup-hook
            #'(lambda ()
                (fullscreen)
                (if (one-window-p)
                    (split-window-horizontally))))
  (create-fontset-from-ascii-font
   "Menlo-14:weight=normal:slant=normal" nil "menlomarugo")
  (set-fontset-font "fontset-menlomarugo"
                    'unicode
                    (font-spec :family "Hiragino Maru Gothic Pro"
                               :size 16)
                    nil
                    'append)
  (add-to-list 'default-frame-alist '(font . "fontset-menlomarugo")))

(require 'package)
(add-to-list 'package-archives
             '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "http://melpa.milkbox.net/packages/"))
(package-initialize)

(when (not package-archive-contents)
  (package-refresh-contents))

(defvar my-packages '(auto-complete
                      auto-save-buffers-enhanced
                      cider
                      clojure-mode
                      exec-path-from-shell
                      go-mode
                      helm
                      js3-mode
                      magit)
  "A list of packages to ensure are installed at launch.")

(dolist (p my-packages)
  (when (not (package-installed-p p))
    (package-install p)))

; auto-complete
(require 'auto-complete-config)
(global-auto-complete-mode t)
(setq ac-dictionary-files (list (concat user-emacs-directory ".dict")))
(ac-config-default)

;; custom function
; autoload if .el found.
(defun autoload-if-found (function file &optional docstring interactive type)
  "set autoload iff. FILE has found."
  (and (locate-library file)
       (autoload function file docstring interactive type)))

; Don't create file list buffer in dired-mode(defun dired-find-alternate-file ()
(defun dired-find-alternate-file ()
  "In dired, visit this file or directory instead of the dired buffer."
  (interactive)
  (set-buffer-modified-p nil)
  (find-alternate-file (dired-get-filename)))

; change color to edit file in today.
(defface my-face-f-2 '((t (:foreground "GreenYellow"))) nil)
(defvar my-face-f-2 'my-face-f-2)
(defun my-dired-today-search (arg)
  "Fontlock search function for dired."
  (search-forward-regexp
   (concat (format-time-string "%b %e" (current-time)) " [0-9]....") arg t))
(add-hook 'dired-mode-hook
          #'(lambda ()
              (font-lock-add-keywords
               major-mode
               (list
                '(my-dired-today-search . my-face-f-2)
                ))))

; hilight mode-line in view mode
(eval-after-load "view"
  '(setcar (cdr (assq 'view-mode minor-mode-alist))
           (if (fboundp 'propertize)
               (list (propertize " View"
                                 'face '(:foreground "white"
                                                     :background "DeepPink1")))
             " View")))

; hilight *completions* buffer
(defadvice display-completion-list (after display-completion-list-highlight activate)
  (let* ((str-list (mapc (lambda(x) (cond ((stringp x) x)
                                            ((symbolp x) (symbol-name x))
                                            ((listp x) (concat (car x)
                                                               (cadr x)))))
                           (ad-get-arg 0)))
         (str (car str-list)))
    (mapc (lambda (x)
              (while (or (> (length str) (length x))
                         (not (string= (substring str 0 (length str))
                                       (substring   x 0 (length str)))))
                (setq str (substring str 0 -1))))
            str-list)
    (save-current-buffer
      (set-buffer "*Completions*")
      (save-excursion
        (re-search-forward "Possible completions are:" (point-max) t)
        (while (re-search-forward (concat "[ \n]\\<" str) (point-max) t)
          (let ((o1 (make-overlay (match-beginning 0) (match-end 0)))
                (o2 (make-overlay (match-end 0)       (1+ (match-end 0)))))
            (overlay-put o1 'face '(:foreground "HotPink3"))
            (overlay-put o2 'face '(:foreground "white" :background "DeepSkyBlue4"))))))))

;; smart scroll
(defun sane-next-line (arg)
  "Goto next line by ARG steps with scrolling sanely if needed."
  (interactive "p")
  ;;(let ((newpt (save-excursion (line-move arg) (point))))
  (let ((newpt (save-excursion (next-line arg) (point))))
    (while (null (pos-visible-in-window-p newpt))
      (if (< arg 0) (scroll-down 1) (scroll-up 1)))
    (goto-char newpt)
    (setq this-command 'next-line)
    ()))

(defun sane-previous-line (arg)
  "Goto previous line by ARG steps with scrolling back sanely if needed."
  (interactive "p")
  (sane-next-line (- arg))
  (setq this-command 'previous-line)
  ())

(defun sane-newline (arg)
  "Put newline\(s\) by ARG with scrolling sanely if needed."
  (interactive "p")
  (let ((newpt (save-excursion (newline arg) (indent-according-to-mode) (point))))
    (while (null (pos-visible-in-window-p newpt)) (scroll-up 1))
    (goto-char newpt)
    (setq this-command 'newline)
    ()))

(defun reopen-file ()
  "Re-open file"
  (interactive)
  (let ((file-name (buffer-file-name))
        (old-supersession-threat
         (symbol-function 'ask-user-about-supersession-threat))
        (point (point)))
    (when file-name
      (fset 'ask-user-about-supersession-threat (lambda (fn)))
      (unwind-protect
          (progn
            (erase-buffer)
            (insert-file file-name)
            (set-visited-file-modtime)
            (goto-char point))
        (fset 'ask-user-about-supersession-threat
              old-supersession-threat)))))
;(define-key ctl-x-map "\C-r"  'reopen-file)

(defmacro exec-if-bound (sexplist)
  "関数が存在する時だけ実行する。（car の fboundp を調べるだけ）"
  `(if (fboundp (car ',sexplist))
       ,sexplist))

(defmacro defun-add-hook (hookname &rest sexplist)
  "add-hook のエイリアス。引数を関数にパックして hook に追加する。"
  `(add-hook ,hookname
             (function (lambda () ,@sexplist))))
(defun load-safe (loadlib)
  "安全な load。読み込みに失敗してもそこで止まらない。"
  ;; missing-ok で読んでみて、ダメならこっそり message でも出しておく
  (let ((load-status (load loadlib t)))
    (or load-status
        (message (format "[load-safe] failed %s" loadlib)))
    load-status))

(defun escape-html-region (start end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (beginning-of-buffer)
      (replace-string "&" "&amp;")
      (beginning-of-buffer)
      (replace-string "<" "&lt;")
      (beginning-of-buffer)
      (replace-string ">" "&gt;")
     (beginning-of-buffer)
     (replace-string "\"" "&quot;")
      (widen))))

(defun unescape-html-region (start end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (beginning-of-buffer)
      (replace-string "&amp;" "&")
      (beginning-of-buffer)
      (replace-string "&lt;" "<")
      (beginning-of-buffer)
      (replace-string "&gt;" ">")
     (beginning-of-buffer)
     (replace-string "&quot;" "\"")
      (widen))))

(defun insert-html-tt (start end)
  (interactive "r")
  (save-excursion
    (save-restriction
      (narrow-to-region start end)
      (beginning-of-buffer)
      (insert "<tt>")
      (end-of-buffer)
      (insert "</tt>")
      (widen)
      )))

(defun delete-blank-lines-region (start end)
  (interactive "*r")
  (save-restriction
    (narrow-to-region start end)
    (save-excursion
      (goto-char (point-min))
      (while (and (re-search-forward "^$" nil t)
                  (not (eobp)))
        (delete-blank-lines)))))

;; find-fileでディレクトリが無ければ作る
(defun make-directory-unless-directory-exists ()
  (let (
        (d (file-name-directory buffer-file-name))
        )
    (unless (file-directory-p d)
      (when (y-or-n-p "No such directory: make directory?")
        (make-directory d t))
      )
    )
  nil
  )
(add-hook 'find-file-not-found-hooks
          'make-directory-unless-directory-exists)

;; *scratch*バッファを消さない
(defun my-make-scratch (&optional arg)
  (interactive)
  (progn
    ;; "*scratch*" を作成して buffer-list に放り込む
    (set-buffer (get-buffer-create "*scratch*"))
    (funcall initial-major-mode)
    (erase-buffer)
    (when (and initial-scratch-message (not inhibit-startup-message))
      (insert initial-scratch-message))
    (or arg (progn (setq arg 0)
                   (switch-to-buffer "*scratch*")))
    (cond ((= arg 0) (message "*scratch* is cleared up."))
          ((= arg 1) (message "another *scratch* is created")))))

(add-hook 'kill-buffer-query-functions
          ;; *scratch* バッファで kill-buffer したら内容を消去するだけにする
          #'(lambda ()
              (if (string= "*scratch*" (buffer-name))
                  (progn (my-make-scratch 0) nil)
                  t)))

(add-hook 'after-save-hook
          ;; *scratch* バッファの内容を保存したら *scratch* バッファを新しく作る
          #'(lambda ()
              (unless (member (get-buffer "*scratch*") (buffer-list))
                (my-make-scratch 1))))

(defun window-toggle-division ()
  "ウィンドウ 2 分割時に、縦分割<->横分割"
  (interactive)
  (unless (= (count-windows 1) 2)
    (error "ウィンドウが 2 分割されていません。"))
  (let (before-height (other-buf (window-buffer (next-window))))
    (setq before-height (window-height))
    (delete-other-windows)

    (if (= (window-height) before-height)
        (split-window-vertically)
      (split-window-horizontally)
      )

    (switch-to-buffer-other-window other-buf)
    (other-window -1)))
(global-set-key "\C-o" 'window-toggle-division)

(defun pcomplete/sudo ()
  "Completion rules for the `sudo' command."
  (let ((pcomplete-help "complete after sudo"))
    (pcomplete-here (pcomplete-here (eshell-complete-commands-list)))))

;; global configuration
(setq inhibit-startup-message t)
(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs 'y-or-n-p)   ; y/n
(auto-compression-mode t)
(exec-if-bound (resize-minibuffer-mode 1))
(setq visible-bell t)
(transient-mark-mode t)
(show-paren-mode t)
(blink-cursor-mode 0)
(display-time)
(line-number-mode t)
(column-number-mode t)
(menu-bar-mode 0)
(if window-system (progn (tool-bar-mode 0)))
(add-to-list 'global-mode-string '("" default-directory "-"))
(windmove-default-keybindings)
(when (not (eq window-system 'ns))
  (global-set-key [?\e left] 'windmove-left)
  (global-set-key [?\e right] 'windmove-right)
  (global-set-key [?\e up] 'windmove-up)
  (global-set-key [?\e down] 'windmove-down))
(setq windmove-wrap-around t)
(setq completion-ignore-case t)
(add-to-list 'completion-ignored-extensions ".svn/")
(add-to-list 'completion-ignored-extensions "CVS/")
(add-to-list 'completion-ignored-extensions ".git/")
(setq-default dabbrev-case-fold-search t)
(recentf-mode)
(setq scroll-step 1)
(setq truncate-partial-width-windows nil)
(add-hook 'emacs-lisp-mode-hook #'(lambda () (setq mode-name "Elisp")))
(setq enable-recursive-minibuffers t)

(setq default-tab-width 4)
(add-hook 'shell-mode-hook
          #'(lambda () (setq tab-width 4)))
(setq-default indent-tabs-mode nil)
(add-to-list 'load-path "/usr/local/share/emacs/site-lisp")
(add-to-list 'load-path "~/.emacs.d")

;; mode-line
(setq-default mode-line-format
              '("-"
                mode-line-mule-info
                mode-line-modified
                mode-line-frame-identification
                mode-line-buffer-identification
                " "
                global-mode-string
                " %[("
                mode-name
                mode-line-process
                minor-mode-alist
                "%n" ")%]-"
                (which-func-mode ("" which-func-format "-"))
                (line-number-mode "L%l-")
                (column-number-mode "C%c-")
                (-3 . "%p")
                "-%-")
              )
(setq mode-line-frame-identification " ")
(setcar (cdr (assq 'abbrev-mode minor-mode-alist)) " Abb")

;; Key bindings
(cond
 ((string-match "^22" emacs-version) (iswitchb-mode 1))
 ((string-match "^23\.1" emacs-version) (iswitchb-default-keybindings)))

(keyboard-translate ?\C-h ?\C-?)
(global-set-key "\C-h" nil)
(global-set-key "\C-ch" 'help-command)
(global-set-key "\C-cg" 'goto-line)
(global-set-key "\C-cr" 'replace-string)
(global-set-key "\C-c\C-r" 'recentf-open-files)
(global-set-key "\C-x\C-i" 'indent-region)
(global-set-key "\M-?" 'help-for-help)
(global-set-key [home] 'beginning-of-buffer)
(global-set-key [end] 'end-of-buffer)
(global-set-key [up] 'sane-previous-line)
(global-set-key [down] 'sane-next-line)
(global-set-key "\C-cc" 'comment-region)
(global-set-key "\C-cu" 'uncomment-region)
;(global-set-key "\C-m" 'newline-and-indent)
(global-set-key "\C-j" 'newline-and-indent)
;(global-set-key "\C-cf" 'find-grep-dired)

;; syntax color (M-x list-faces-display)
(global-font-lock-mode t)
;(setq font-lock-maximum-decoration t)
;(set-face-background 'default "black")
;(set-face-foreground 'default "white")
;(set-face-background 'modeline "black")
;(set-face-foreground 'modeline "white")
;(set-face-foreground 'font-lock-comment-face "green")
;(set-face-foreground 'font-lock-function-name-face "SteelBlue")
;(set-face-foreground 'font-lock-builtin-face "#5083b2")

(defface my-mark-tabs '((t (:foreground "red" :underline t))) nil)
(defface my-mark-whitespace '((t (:background "gray"))) nil)
(defface my-mark-lineendspaces '((t (:foreground "SteelBlue" :underline t))) nil)
(defvar my-mark-tabs 'my-mark-tabs)
(defvar my-mark-whitespace 'my-mark-whitespace)
(defvar my-mark-lineendspaces 'my-mark-lineendspaces)
(defadvice font-lock-mode (before my-font-lock-mode ())
  (font-lock-add-keywords
    major-mode
    '(
      ("\t" 0 my-mark-tabs append)
      ("　" 0 my-mark-whitespace append)
    ("[ \t]+$" 0 my-mark-lineendspaces append)
     )))
(ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
(ad-activate 'font-lock-mode)

;; major & minor mode

; remove spaces & chenge tab to space when saved
;(require 'untabify-file)

;; perl mode
(defalias 'perl-mode 'cperl-mode)
(global-set-key "\r" 'newline-and-indent)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(cperl-close-paren-offset -4)
 '(cperl-continued-statement-offset 4)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(cperl-tab-always-indent t)
 '(custom-safe-themes (quote ("86e74c4c42677b593d1fab0a548606e7ef740433529b40232774fbb6bc22c048" default)))
 '(php-mode-force-pear t))
(setq-default indent-tabs-mode nil)
(setq fill-column 78)
(setq auto-fill-mode t)
(abbrev-mode 1)
; variable & subroutine completion
; http://www.gentei.org/~yuuji/software/perlplus.el
(add-hook 'cperl-mode-hook
          #'(lambda ()
              (require 'perlplus)
              (define-key cperl-mode-map "\M-\t" 'perlplus-complete-symbol)
              (define-key cperl-mode-map "\C-c\C-e" 'perl-eval-region)
              (define-key cperl-mode-map "\C-c\C-t" 'perltidy-region)
              (perlplus-setup)
              (abbrev-mode 0)
              (make-local-variable 'compile-command)
              (setq compile-command
                    (concat "perl -wc "
                            (buffer-file-name)))))

; perltidy ( yinst install ypan/perl-Perl-Tidy )
(defun perltidy-region ()
  "Run perltidy on the current region."
  (interactive)
  (save-excursion
    (shell-command-on-region (point) (mark) "perltidy -q" nil t)))
(defun perltidy-defun ()
  "Run perltidy on the current defun."
  (interactive)
  (save-excursion (mark-defun)
                  (perltidy-region)))
(defun perl-eval-buffer () (interactive)
  "Evaluate the buffer with perl."
  (shell-command-on-region (point-min) (point-max) "perl -e"))
(defun perl-eval-region () (interactive)
  "Evaluate the buffer with perl."
  (shell-command-on-region (region-beginning) (region-end) "perl"))

;; ruby mode.
;; http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/misc/ruby-mode.el
;; http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/misc/inf-ruby.el
;; http://www.ruby-lang.org/cgi-bin/cvsweb.cgi/~checkout~/ruby/misc/ruby-electric.el
(autoload 'ruby-mode "ruby-mode"
  "Mode for editing ruby source files" t)
(setq auto-mode-alist
      (append '(("\\.rb$" . ruby-mode)
                ("[Rr]akefile" . ruby-mode))
              auto-mode-alist))
(setq interpreter-mode-alist (append '(("ruby" . ruby-mode))
                                     interpreter-mode-alist))
(defun ruby-lint ()
  "Performs a Ruby lint-check on the current file."
  (interactive)
  (shell-command (concat "ruby -c " (buffer-file-name))))

(autoload 'run-ruby "inf-ruby"
  "Run an inferior Ruby process")
(autoload 'inf-ruby-keys "inf-ruby"
  "Set local key defs for inf-ruby in ruby-mode")

;(require 'ruby-electric)
(autoload 'ruby-electric "ruby-electric"
  "Show parent in ruby-mode" t)
(defun ruby-eval-buffer () (interactive)
  "Evaluate the buffer with ruby."
  (shell-command-on-region (point-min) (point-max) "ruby"))
(defun ruby-eval-region () (interactive)
  "Evaluate the buffer with ruby."
  (shell-command-on-region (region-beginning) (region-end) "ruby"))
;(ruby-electric-mode t)

;; refe
; http://ns103.net/~arai/ruby/refe.el
(require 'refe)

(add-hook 'ruby-mode-hook
          #'(lambda ()
              (inf-ruby-keys)
              (define-key ruby-mode-map "\C-c\C-f" 'refe)
              (define-key ruby-mode-map "\C-c\C-l" 'ruby-lint)
              (define-key ruby-mode-map "\C-c\C-e" 'ruby-eval-region)
              ;;(add-hook 'after-save-hook 'ruby-lint)
              ))

;; php-mode
; http://ourcomments.org/Emacs/DL/elisp/php-mode.el
; http://users.etu.info.unicaen.fr/~ethomas/php-mode.el
(require 'php-mode)
(setq php-manual-url "http://www.php.net/manual/ja/")
(setq tags-file-name "/home/nakakuda/dev/work/TAGS")

(setq php-manual-path "~/src/html")

(setq php-program-name "/usr/bin/env -S php -d open_basedir= ")
(defun php-lint ()
  "Performs a PHP lint-check on the current file."
  (interactive)
  (shell-command (concat "/usr/bin/env -S php -d open_basedir= -l " (buffer-file-name))))
(defun php-exec ()
  "Execute a PHP on the current file."
  (interactive)
  (shell-command (concat "/usr/bin/env -S php -d open_basedir= " (buffer-file-name))))
;; (defun php-eval-region ()
;;   "PHP eval"
;;   (interactive)
;;   (shell-command-on-region (region-beginning) (region-end) "php -d open_basedir= ~/.emacs.d/eval.php"))

(defun php-eval-region (beg end)
  "Run selected region as PHP code"
  (interactive "r")
  (let ((code (concat "<?php " (buffer-substring beg end))))
    (with-temp-buffer
      (insert code)
      (shell-command-on-region (point-min) (point-max) "php")
      )))

(defun php-dump-region ()
  "PHP dump"
  (interactive)
  (shell-command-on-region (region-beginning) (region-end) "/usr/bin/env -S php -d open_basedir= ~/.emacs.d/dump.php"))
(defun my-insert-vardump-debug ()
  (interactive)
  (insert-string "echo \"<pre>\\n\";\nvar_dump();\necho \"</pre>\\n\";")
  (indent-according-to-mode))
(defun my-insert-printr-debug ()
  (interactive)
  (insert-string "echo \"<pre>\\n\";\nprint_r();\necho \"</pre>\\n\";")
  (indent-according-to-mode))

(autoload 'php-imenu-create-index "php-imenu" nil t)
;; Add the index creation function to the php-mode-hook
;; In php-mode 1.2, it's php-mode-user-hook.  In 1.4, it's php-mode-hook.
(add-hook 'php-mode-hook 'php-imenu-setup)
(defun php-imenu-setup ()
  (setq imenu-create-index-function (function php-imenu-create-index))
  ;; uncomment if you prefer speedbar:
  ;(setq php-imenu-alist-postprocessor (function reverse))
  (imenu-add-menubar-index)
  )

;(add-hook 'php-mode-user-hook 'turn-on-font-lock)
(add-hook 'php-mode-hook
          #'(lambda ()
              (setq indent-tabs-mode nil)
              (define-key php-mode-map "\M-j" 'php-complete-function)
              (define-key php-mode-map "\C-c\C-l" 'php-lint)
              (define-key php-mode-map "\C-c\C-d" 'php-exec)
              (define-key php-mode-map "\C-c\C-e" 'php-eval-region)
              (define-key php-mode-map "\C-c\C-p" 'php-dump-region)
              (define-key php-mode-map '[(control .)] nil)
              ;(define-key php-mode-map '[(control c)(control .)] 'php-show-arglist)
              ;(define-key php-mode-map (kbd "C-c ps") 'php-show-arglist)
              ;(define-key php-mode-map (kbd "C-c dv") 'my-insert-vardump-debug)
              ;(define-key php-mode-map (kbd "C-c dr") 'my-insert-printr-debug)
              (define-key c-mode-base-map "\C-ca" 'align-current)
              (c-set-offset 'arglist-intro '+)
              (c-set-offset 'arglist-close 0)
              ;(c-toggle-auto-hungry-state 1)
              (modify-syntax-entry ?_ "w" php-mode-syntax-table)
              ;(add-hook 'after-save-hook 'php-lint)
              (require 'php-completion)
              (php-completion-mode t)
              (define-key php-mode-map (kbd "C-o") 'phpcmp-complete)
              (when (require 'auto-complete nil t)
                (make-variable-buffer-local 'ac-sources)
                ;(add-to-list 'ac-sources 'ac-source-php-completion)
                (add-to-list 'ac-sources 'ac-source-php-completion-patial)
                (auto-complete-mode t)
                )
              ))

;; align
(require 'align)
(add-to-list 'align-rules-list
             '(php-assignment
               (regexp . "[^-=!^&*+<>/.| \t\n]\\(\\s-*[.-=!^&*+<>/|]*\\)=>?\\(\\s-*\\)\\([^= \t\n]\\\|$\\)")
               (justify .t)
               (tab-stop . nil)
               (modes . '(php-mode))))
(add-to-list 'align-dq-string-modes 'php-mode)
(add-to-list 'align-sq-string-modes 'php-mode)
(add-to-list 'align-open-comment-modes 'php-mode)
(setq align-region-separate (concat "\\(^\\s-*$\\)\\|"
                                    "\\([({}\\(/\*\\)]$\\)\\|"
                                    "\\(^\\s-*[)}\\(\*/\\)][,;]?$\\)\\|"
                                    "\\(^\\s-*\\(}\\|for\\|while\\|if\\|else\\|"
                                    "switch\\|case\\|break\\|continue\\|do\\)[ ;]\\)"
                                    ))

;; dmacro.el
;; http://pitecan.com/papers/JSSSTDmacro/dmacro.el
(defconst *dmacro-key* "\C-xr" "repeat-key")
(global-set-key *dmacro-key* 'dmacro-exec)
(autoload 'dmacro-exec "dmacro" nil t)

; unique buffer name
(require 'uniquify)
(setq uniquify-buffer-name-style 'post-forward-angle-brackets)

;; python-mode, pycomplete
;; http://python-mode.cvs.sourceforge.net/*checkout*/python-mode/python-mode/python-mode.el
;; http://python-mode.cvs.sourceforge.net/*checkout*/python-mode/python-mode/pycomplete.el (require pycompilete.py)
;; http://python-mode.cvs.sourceforge.net/*checkout*/python-mode/python-mode/doctest-mode.el
;; M-TAB: completion
;; C-c C-c execute python(Buffer)
;; C-c | execute python(Region)
;; C-c ! python shell
;; http://www.mirrorservice.org/sites/www.ibiblio.org/gentoo/distfiles/Pymacs-0.22.tar.gz
;; (autoload 'python-mode "python-mode" "Python editing mode." t)
;; (setq-default py-indent-offset 4)
;; (setq auto-mode-alist
;;             (cons '("\\.py$" . python-mode) auto-mode-alist))
;; (add-hook 'python-mode-hook
;;           '(lambda()
;;              (set (make-variable-buffer-local 'beginning-of-defun-function)
;;                   'py-beginning-of-def-or-class)
;;              (setq outline-regexp "def\\|class ")
;;              ;(require 'pycomplete)
;;              (setq indent-tabs-mode nil)))

;; (defadvice py-execute-region (around my-py-execute-region)
;;   "back to the original buffer when py-execute-region finished."
;;   (if (get-buffer "*Python Output*")
;;       (kill-buffer "*Python Output*")
;;     nil)
;;   ad-do-it
;;   (shrink-window-if-larger-than-buffer)
;;   (other-window -1)
;; )

;; (ad-enable-advice 'py-execute-region 'around 'my-py-execute-region)
;; (ad-activate 'py-execute-region)

;; shell-mode
(setq shell-file-name "zsh")
(setq shell-command-switch "-c")
(setq explicit-shell-file-name shell-file-name)
(setenv "SHELL" shell-file-name)
(autoload 'ansi-color-for-comint-mode-on "ansi-color"
  "Set `ansi-color-for-comint-mode' to t." t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

(add-hook 'shell-mode-hook
          #'(lambda ()
              (define-key shell-mode-map [up] 'comint-previous-input)
              (define-key shell-mode-map [down] 'comint-next-input)
              (set-buffer-process-coding-system 'utf-8-unix 'utf-8-unix)))
(add-hook 'comint-output-filter-functions
          'comint-watch-for-password-prompt)

;; eshell-mode
(setq eshell-glob-include-dot-dot nil)
(setq eshell-cmpl-cycle-completions t)
(setq eshell-cmpl-ignore-case t)
(setq eshell-cmpl-cycle-cutoff-length 5)
(setq eshell-save-history-on-exit t)
(setq eshell-ask-to-save-history 'always)
(setq eshell-ls-dired-initial-args (quote ("-h")))
(setq eshell-term-name "ansi")
(setq eshell-history-file-name "~/.zsh-history")
(setq eshell-history-size 100000)
;; (setq eshell-modules-list (quote (eshell-alias
;;                                   eshell-basic
;;                                   eshell-cmpl eshell-dirs eshell-glob
;;                                   eshell-hist eshell-ls eshell-pred
;;                                   eshell-prompt eshell-rebind
;;                                   eshell-script eshell-smart
;;                                   eshell-term eshell-unix eshell-xtra
;;                                   )))

(add-hook 'comint-output-filter-functions 'shell-strip-ctrl-m nil t)
;;; From: http://www.emacswiki.org/cgi-bin/wiki.pl/EshellEnhancedLS
(eval-after-load "em-ls"
  '(progn
     ;; (defun ted-eshell-ls-find-file-at-point (point)
     ;;          "RET on Eshell's `ls' output to open files."
     ;;          (interactive "d")
     ;;          (find-file (buffer-substring-no-properties
     ;;                      (previous-single-property-change point 'help-echo)
     ;;                      (next-single-property-change point 'help-echo))))
     (defun pat-eshell-ls-find-file-at-mouse-click (event)
       "Middle click on Eshell's `ls' output to open files.
 From Patrick Anderson via the wiki."
       (interactive "e")
       (ted-eshell-ls-find-file-at-point (posn-point (event-end event))))
     (defun ted-eshell-ls-find-file ()
       (interactive)
       (let ((fname (buffer-substring-no-properties
                     (previous-single-property-change (point) 'help-echo)
                     (next-single-property-change (point) 'help-echo))))
         ;; Remove any leading whitespace, including newline that might
         ;; be fetched by buffer-substring-no-properties
         (setq fname (replace-regexp-in-string "^[ \t\n]*" "" fname))
         ;; Same for trailing whitespace and newline
         (setq fname (replace-regexp-in-string "[ \t\n]*$" "" fname))
         (cond
          ((equal "" fname)
           (message "No file name found at point"))
          (fname
           (find-file fname)))))
     (let ((map (make-sparse-keymap)))
       ;;          (define-key map (kbd "RET")      'ted-eshell-ls-find-file-at-point)
       ;;          (define-key map (kbd "<return>") 'ted-eshell-ls-find-file-at-point)
       (define-key map (kbd "RET")      'ted-eshell-ls-find-file)
       (define-key map (kbd "<return>") 'ted-eshell-ls-find-file)
       (define-key map (kbd "<mouse-2>") 'pat-eshell-ls-find-file-at-mouse-click)
       (defvar ted-eshell-ls-keymap map))
     (defadvice eshell-ls-decorated-name (after ted-electrify-ls activate)
       "Eshell's `ls' now lets you click or RET on file names to open them."
       (add-text-properties 0 (length ad-return-value)
                            (list 'help-echo "RET, mouse-2: visit this file"
                                  'mouse-face 'highlight
                                  'keymap ted-eshell-ls-keymap)
                            ad-return-value)
       ad-return-value)))

(defun eshell/clear ()
  "Clear the current buffer, leaving one prompt at the top."
  (interactive)
  (let ((inhibit-read-only t))
    (erase-buffer)))
;(add-to-list 'eshell-command-aliases-list (list "ll" "ls -lFGa"))
(add-hook 'after-init-hook  #'(lambda() (eshell)))

;(setq eshell-prefer-to-shell t)
(setq eshell-hist-ignoredups t)
(setq eshell-prompt-function
      (lambda ()
        (concat "[kaku: "
                (eshell/pwd)
                (if (= (user-uid) 0) "]\n# " "]$ "))))
(setq eshell-prompt-regexp "^[^#$]*[$#] ")
(add-hook 'eshell-mode-hook
          #'(lambda ()
              (define-key eshell-mode-map "\C-a" 'eshell-bol)
              (define-key eshell-mode-map "\M-p" 'helm-eshell-history)
              (define-key eshell-mode-map [remap pcomplete] 'helm-esh-pcomplete)))

(setq exec-path (cons "/opt/local/bin" exec-path))
(when (eq system-type 'darwin)
  (setenv "JAVA_HOME"
          (replace-regexp-in-string
           "\n+$" "" (shell-command-to-string "/usr/libexec/java_home -v 1.7.0_25"))))
(setenv "HADOOP_COMMON_HOME" (concat (getenv "HOME") "/local/hadoop"))
(setenv "HADOOP_HDFS_HOME" (getenv "HADOOP_COMMON_HOME"))
(setenv "HADOOP_MAPRED_HOME" (getenv "HADOOP_COMMON_HOME"))
(setenv "YARN_HOME" (getenv "HADOOP_MAPRED_HOME"))
(setenv "HADOOP_CONF_DIR" (concat (getenv "HADOOP_COMMON_HOME") "/conf"))
(setenv "YARN_CONF_DIR" (getenv "HADOOP_CONF_DIR"))
(setenv "LANG" "en_US.UTF-8")
(setenv "LC_ALL" "en_US.UTF-8")
(setenv "GRADLE_HOME" "/opt/local/share/java/gradle")
(setenv "GOPATH" (expand-file-name "~/local/gobase"))
(add-to-list 'exec-path (getenv "GOPATH"))
(setenv "PATH"
        (concat (concat (getenv "GOPATH") "/bin:")
                "$HOME/local/bin:/opt/local/bin:"
                (getenv "PATH")))

;; editing remote file /method:username@hostname:path
;; ex. /su:root@localhost:/etc/fstab
;; yinst emacs_tramp
(require 'tramp)
;(setq tramp-debug-buffer t)
(setq tramp-default-method "sshx")
(setq tramp-auto-save-directory "~/.emacs.d/tramp-auto-save")
(setq tramp-verbose 10)
(setq tramp-auto-save-directory "/tmp")
(setq auto-save-file-name-transforms
      '(("??`/[^/]*:??(.+/??)*??(.*??)" "/tmp/??2")))
(setq tramp-chunksize 328)
(setq process-connection-type t)
;(setq tramp-default-method "scpx")
;(setq tramp-default-method "ssh")
;; (add-to-list
;;   'tramp-multi-connection-function-alist
;;   '("sshx" tramp-multi-connect-rlogin "ssh -t %h -l %u /bin/sh%n"))
;; (add-to-list
;;   'tramp-multi-connection-function-alist
;;   '("sshp10022" tramp-multi-connect-rlogin "ssh -t %h -l %u -p 10022 /bin/sh%n"))
;; (setq tramp-auto-save-directory "/tmp")
;; (setq auto-save-file-name-transforms
;;       '(("??`/[^/]*:??(.+/??)*??(.*??)" "/tmp/??2")))

(defvar find-file-root-prefix
  (if (featurep 'xemacs) "/[sudo/root@localhost]" "/sudo:root@localhost:" )
  "*The filename prefix used to open a file with `find-file-root'.")

(defvar find-file-root-history nil
  "History list for files found using `find-file-root'.")

(defvar find-file-root-hook nil
  "Normal hook for functions to run after finding a \"root\" file.")

(defun find-file-root ()
  "*Open a file as the root user.
   Prepends `find-file-root-prefix' to the selected file name so that it
   maybe accessed via the corresponding tramp method."

  (interactive)
  (require 'tramp)
  (let* ( ;; We bind the variable `file-name-history' locally so we can
         ;; use a separate history list for "root" files.
         (file-name-history find-file-root-history)
         (name (or buffer-file-name default-directory))
         (tramp (and (tramp-tramp-file-p name)
                     (tramp-dissect-file-name name)))
         path dir file)

    ;; If called from a "root" file, we need to fix up the path.
    (when tramp
      (setq path (tramp-file-name-path tramp)
            dir (file-name-directory path)))

    (when (setq file (read-file-name "Find file (UID = 0): " dir path))
      (find-file (concat find-file-root-prefix file))
      ;; If this all succeeded save our new history list.
      (setq find-file-root-history file-name-history)
      ;; allow some user customization
      (run-hooks 'find-file-root-hook))))

(global-set-key [(control x) (control r)] 'find-file-root)

(defface find-file-root-header-face
  '((t (:foreground "white" :background "red3")))
  "*Face use to display header-lines for files opened as root.")

(defun find-file-root-header-warning ()
  "*Display a warning in header line of the current buffer.
   This function is suitable to add to `find-file-root-hook'."
  (let* ((warning "WARNING: EDITING FILE AS ROOT!")
         (space (+ 6 (- (window-width) (length warning))))
         (bracket (make-string (/ space 2) ?-))
         (warning (concat bracket warning bracket)))
    (setq header-line-format
          (propertize  warning 'face 'find-file-root-header-face))))

(defun find-file-hook-root-header-warning ()
  (when (and buffer-file-name (string-match "root@localhost" buffer-file-name))
    (find-file-root-header-warning)))
(add-hook 'find-file-hook 'find-file-hook-root-header-warning)

;; Subversion
;; http://www.xsteve.at/prg/emacs/psvn.el
;(require 'psvn)
(load-library "psvn")
(add-hook 'dired-mode-hook
          #'(lambda ()
              (require 'dired-x)
              ;;(define-key dired-mode-map "V" 'cvs-examine)
              ;;(setq process-coding-system-alist '(("svn" . utf-8)))
              (define-key dired-mode-map "V" 'svn-status)
              (turn-on-font-lock)
              ))
(setq svn-status-hide-unmodified t)
(setq process-coding-system-alist (cons '("svn" . utf-8) process-coding-system-alist))
(add-hook 'svn-pre-parse-status-hook 'svn-status-parse-fixup-externals-full-path)

(defun svn-status-parse-fixup-externals-full-path ()
 "Subversion 1.7 adds the full path to externals.  This
pre-parse hook fixes it up to look like pre-1.7, allowing
psvn to continue functioning as normal."
 (goto-char (point-min))
 (let (( search-string  (file-truename default-directory) ))
      (save-match-data
        (save-excursion
          (while (re-search-forward search-string (point-max) t)
          (replace-match "" nil nil)
          )))))

;; wdired
(autoload 'wdired-change-to-wdired-mode "wdired")
(eval-after-load "dired"
  #'(lambda ()
      (define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)))

;; scheme-mode
(setq process-coding-system-alist
      (cons '("gosh" utf-8 . utf-8) process-coding-system-alist))

(setq scheme-program-name "gosh -i")
(autoload 'scheme-mode "cmuscheme" "Major mode for Scheme." t)
(autoload 'run-scheme "cmuscheme" "Run an inferior Scheme process." t)

(defun scheme-other-window ()
  "Run scheme on other window"
  (interactive)
  (switch-to-buffer-other-window
   (get-buffer-create "*scheme*"))
  (run-scheme scheme-program-name))

(define-key global-map "\C-cS" 'scheme-other-window)

(put 'and-let* 'scheme-indent-function 1)
(put 'begin0 'scheme-indent-function 0)
(put 'call-with-client-socket 'scheme-indent-function 1)
(put 'call-with-input-conversion 'scheme-indent-function 1)

(put 'call-with-input-file 'scheme-indent-function 1)
(put 'call-with-input-process 'scheme-indent-function 1)
(put 'call-with-input-string 'scheme-indent-function 1)
(put 'call-with-iterator 'scheme-indent-function 1)
(put 'call-with-output-conversion 'scheme-indent-function 1)
(put 'call-with-output-file 'scheme-indent-function 1)
(put 'call-with-output-string 'scheme-indent-function 0)
(put 'call-with-temporary-file 'scheme-indent-function 1)
(put 'call-with-values 'scheme-indent-function 1)
(put 'dolist 'scheme-indent-function 1)
(put 'dotimes 'scheme-indent-function 1)
(put 'if-match 'scheme-indent-function 2)
(put 'let*-values 'scheme-indent-function 1)
(put 'let-args 'scheme-indent-function 2)
(put 'let-keywords* 'scheme-indent-function 2)
(put 'let-match 'scheme-indent-function 2)
(put 'let-optionals* 'scheme-indent-function 2)
(put 'let-syntax 'scheme-indent-function 1)
(put 'let-values 'scheme-indent-function 1)
(put 'let/cc 'scheme-indent-function 1)
(put 'let1 'scheme-indent-function 2)
(put 'letrec-syntax 'scheme-indent-function 1)
(put 'make 'scheme-indent-function 1)
(put 'multiple-value-bind 'scheme-indent-function 2)
(put 'parameterize 'scheme-indent-function 1)
(put 'parse-options 'scheme-indent-function 1)
(put 'receive 'scheme-indent-function 2)
(put 'rxmatch-case 'scheme-indent-function 1)
(put 'rxmatch-cond 'scheme-indent-function 0)
(put 'rxmatch-if  'scheme-indent-function 2)
(put 'rxmatch-let 'scheme-indent-function 2)
(put 'syntax-rules 'scheme-indent-function 1)
(put 'unless 'scheme-indent-function 1)
(put 'until 'scheme-indent-function 1)
(put 'when 'scheme-indent-function 1)
(put 'while 'scheme-indent-function 1)
(put 'with-builder 'scheme-indent-function 1)
(put 'with-error-handler 'scheme-indent-function 0)
(put 'with-error-to-port 'scheme-indent-function 1)
(put 'with-input-conversion 'scheme-indent-function 1)
(put 'with-input-from-port 'scheme-indent-function 1)
(put 'with-input-from-process 'scheme-indent-function 1)
(put 'with-input-from-string 'scheme-indent-function 1)
(put 'with-iterator 'scheme-indent-function 1)
(put 'with-module 'scheme-indent-function 1)
(put 'with-output-conversion 'scheme-indent-function 1)
(put 'with-output-to-port 'scheme-indent-function 1)
(put 'with-output-to-process 'scheme-indent-function 1)
(put 'with-output-to-string 'scheme-indent-function 1)
(put 'with-port-locking 'scheme-indent-function 1)
(put 'with-string-io 'scheme-indent-function 1)
(put 'with-time-counter 'scheme-indent-function 1)
(put 'with-signal-handlers 'scheme-indent-function 1)

(autoload 'scheme-smart-complete "scheme-complete" nil t)
(eval-after-load 'scheme
  '(progn (define-key scheme-mode-map "\e\t" 'scheme-smart-complete)))
(eval-after-load 'scheme
  '(progn (define-key scheme-mode-map "\t" 'scheme-complete-or-indent)))

(require 'gca)

;; C-c C-uで(use module)をインサートする
(define-key scheme-mode-map "\C-c\C-u" 'gca-insert-use)
(let ((m (make-sparse-keymap)))
  ;; C-c C-d h でドキュメントを検索する
  (define-key m "h" 'gca-show-info)
  ;; C-c C-d i でauto-info-modeの切り替えを行う。(ONの場合自動的にinfoを表示します)
  (define-key m "i" 'auto-info-mode)
  (define-key scheme-mode-map "\C-c\C-d" m))

;; C-c C-,でinfoの次のトピックを表示します(検索結果が複数あった場合)
;(define-key scheme-mode-map [(control c)(control ,)] 'gca-info-next)

;; C-. でシンボルを補完する
;(define-key scheme-mode-map [(control .)] 'gca-completion-current-word)

;; C-c C-. でコードのひな形をインサートする
;(define-key scheme-mode-map [(control c) (control .)] 'gca-insert-template)
;(define-key c-mode-map [(control c) (control .)] 'gca-insert-template)

;; C-c t でテストケースをインサートする (run-schemeでtgosh.scmを使う必要があります)
;; C-u で引数を与えると、その番号で実行された結果をもとにしてテストケースを作成します。
;; 省略時は直前の実行結果が使われます。
(define-key scheme-mode-map "\C-ct" 'gca-make-test)
;; C-c h で履歴をみる (run-schemeでtgosh.scmを使う必要があります)
(define-key scheme-mode-map "\C-ch" 'gca-show-history)
(setq scheme-program-name "gosh ~/.emacs.d/tgosh.scm")

;; M-x info-lookup-symbol でカーソル上の関数をgaucheのinfoで引く
(eval-after-load "info-look"
  '(progn
     (info-lookup-add-help
      :topic 'symbol
      :mode 'scheme-mode
      :regexp "[^()`',\"\t\n]+"
      :ignore-case t
      :doc-spec '(("(gauche-refj.info)Index - 手続きと構文索引" nil
                   "^ -+ [^:]+: *" "[\n ]")
                  ("(gauche-refj.info)Index - モジュール索引" nil
                   "^ -+ [^:]+: *" "[\n ]")
                  ("(gauche-refj.info)Index - クラス索引" nil
                   "^ -+ [^:]+: *" "[\n ]")
                  ("(gauche-refj.info)Index - 変数索引" nil
                   "^ -+ [^:]+: *" "[\n ]"))
      :parse-rule "[^()`',\" \t\n]+"
      :other-modes nil)

     (info-lookup-add-help
      :mode 'inferior-scheme-mode
      :other-modes '(scheme-mode))
))

;; auto save buffers
; http://0xcc.net/misc/auto-save/auto-save-buffers.el
(require 'auto-save-buffers)
(run-with-idle-timer 2.0 t 'auto-save-buffers)

;; kill-summary
; http://mibai.tec.u-ryukyu.ac.jp/~oshiro/Programs/elisp/kill-summary.el
(autoload 'kill-summary "kill-summary" nil t)
(define-key global-map "\ey" 'kill-summary)

;; browse-kill-ring
; http://www.todesschaf.org/files/browse-kill-ring.el
; n,p: next,prev  y: paste  q: quit  e: edit  U: undo  s,r: search
(autoload 'browse-kill-ring "browse-kill-ring" "interactively insert items from kill-ring" t)
(global-set-key "\C-x\C-y" 'browse-kill-ring)
(make-face 'separator)
(set-face-foreground 'separator "slate gray")
(setq browse-kill-ring-display-style 'one-line
      browse-kill-ring-quit-action 'kill-and-delete-window
      browse-kill-ring-resize-window t
      browse-kill-ring-separator "-------"
      browse-kill-ring-highlight-current-entry t
      browse-kill-ring-separator-face 'region
      browse-kill-ring-maximum-display-length 100)

;; redo
; http://www.wonderworks.com/download/redo.el
(require 'redo)
(global-set-key "\C-]" 'redo)
(defadvice kill-new (before ys:no-kill-new-duplicates activate)
  (setq kill-ring (delete (ad-get-arg 0) kill-ring)))

(defun try-complete-abbrev (old)
  (if (expand-abbrev) t nil))

(setq hippie-expand-try-functions-list
      '(;try-complete-file-name-partially
        ;try-complete-file-name
        try-expand-tempo
        try-expand-tempo-snippets
        try-expand-abbrev
        try-expand-all-abbrevs
        ;try-expand-list try-expand-line
        try-expand-dabbrev
        try-expand-dabbrev-all-buffers
        try-expand-dabbrev-from-kill
        try-complete-lisp-symbol-partially
        try-complete-lisp-symbol))

;(setq hippie-expand-try-functions-list
;      '(try-complete-abbrev
;        try-complete-file-name
;        try-expand-dabbrev))

;; find-recursive
; http://www.webweavertech.com/ovidiu/emacs/find-recursive.txt
(require 'find-recursive)

;; GNU GLOBAL
(autoload 'gtags-mode "gtags" "" t)
(setq gtags-mode-hook
      #'(lambda ()
          (local-set-key "\M-t" 'gtags-find-tag)
          (local-set-key "\M-r" 'gtags-find-rtag)
          (local-set-key "\M-s" 'gtags-find-symbol)
          (local-set-key "\C-t" 'gtags-pop-stack)
          ))

;; anything
; http://www.emacswiki.org/cgi-bin/wiki/download/anything.el
; http://www.emacswiki.org/cgi-bin/wiki/download/anything-config.el
(require 'anything-config)
(setq anything-sources
      (list anything-c-source-buffers+
            anything-c-source-imenu
                                        ; anything-c-source-bookmarks
            anything-c-source-file-name-history
                                        ; anything-c-source-man-pages
            anything-c-source-info-pages
                                        ; anything-c-source-calculation-result
            anything-c-source-emacs-commands
                                        ; anything-c-source-emacs-functions
            anything-c-source-kill-ring
            anything-c-source-locate))

(global-set-key "\C-xb" 'anything)
(global-set-key "\M-y" 'anything-show-kill-ring)
(define-key anything-map (kbd "C-p") 'anything-previous-line)
(define-key anything-map (kbd "C-n") 'anything-next-line)
(define-key anything-map (kbd "C-v") 'anything-next-source)
(define-key anything-map (kbd "M-v") 'anything-previous-source)
                                        ;(anything-iswitchb-setup)
(require 'anything-project)
(global-set-key (kbd "C-c C-f") 'anything-project)
(setq ap:project-files-filters
      (list
       (lambda (files)
         (remove-if 'file-directory-p files))))

(ap:add-project
 :name 'leiningen
 :look-for 'ap:leiningen-root-detector
 :grep-extensions '("\\.clj" "\\.htm" "\\.jar"))
(defun ap:leiningen-root-detector (files)
  (ap:all-files-exist '("project.clj" "src" "test") files))

(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

; color-moccur
; http://www.bookshelf.jp/elc/color-moccur.el
(require 'color-moccur)
(setq dmoccur-recursive-search t)
(setq moccur-split-word t)
(when (require 'migemo nil t)
  (setq moccur-use-migemo t))
(setq dmoccur-exclusion-mask
      (append '("\\.so$" "\\.a$") dmoccur-exclusion-mask))
(setq *moccur-buffer-name-exclusion-list* '(".+TAGS.+" "*Completions*" "*Messages*"))
; moccur-edit
; http://www.bookshelf.jp/elc/moccur-edit.el
(load "moccur-edit")
(global-set-key "\C-cf" 'moccur-grep-find)

; anything-c-moccur
; http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el
(require 'anything-c-moccur)
(setq anything-c-moccur-anything-idle-delay 0.2
      anything-c-moccur-higligt-info-line-flag t
      anything-c-moccur-enable-auto-look-flag t
      anything-c-moccur-enable-initial-pattern t)
(global-set-key (kbd "M-o") 'anything-c-moccur-occur-by-moccur)
(global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur)
(add-hook 'dired-mode-hook
          #'(lambda ()
              (local-set-key (kbd "O") 'anything-c-moccur-dired-do-moccur-by-moccur)))

; dabbrev-ja
; http://namazu.org/%7Etsuchiya/elisp/dabbrev-ja.el
(load "dabbrev-ja")

; install-elisp
; http://www.emacswiki.org/cgi-bin/wiki/download/install-elisp.el
(require 'install-elisp)
(setq install-elisp-repository-directory "~/.emacs.d/")

;; Additional definitions by Pierpaolo Bernardi.
(defun cl-indent (sym indent)
  (put sym 'common-lisp-indent-function
       (if (symbolp indent)
       (get indent 'common-lisp-indent-function)
     indent)))

(cl-indent 'if '1)
(cl-indent 'generic-flet 'cl-flet)
(cl-indent 'generic-labels 'labels)
(cl-indent 'with-accessors 'multiple-value-bind)
(cl-indent 'with-added-methods '((1 4 ((&whole 1))) (2 &body)))
(cl-indent 'with-condition-restarts '((1 4 ((&whole 1))) (2 &body)))
(cl-indent 'with-simple-restart '((1 4 ((&whole 1))) (2 &body)))

(require 'info)
(add-to-list 'Info-additional-directory-list "/usr/share/info")
(add-to-list 'Info-additional-directory-list "/opt/local/share/info")
(add-to-list 'Info-additional-directory-list "~/.emacs.d/info")

; xcscope
; http://cscope.cvs.sourceforge.net/viewvc/*checkout*/cscope/cscope/contrib/xcscope/xcscope.el
; $ cd target-dir; ~/svn/tool/cscope-indexer -r
; C-c s s   Find symbol.
; C-c s d   Find global definition.
; C-c s g   Find global definition (alternate binding).
; C-c s G   Find global definition without prompting.
; C-c s c   Find functions calling a function.
; C-c s C   Find called functions (list functions called from a function).
; C-c s t   Find text string.
; C-c s e   Find egrep pattern.
; C-c s f   Find a file.
; C-c s i   Find files #including a file.
(require 'xcscope)

; saveplace
(require 'saveplace)
(setq-default save-place t)

(defun credmp/flymake-display-err-minibuf ()
  "Displays the error/warning for the current line in the minibuffer"
  (interactive)
  (let* ((line-no             (flymake-current-line-no))
         (line-err-info-list  (nth 0 (flymake-find-err-info flymake-err-info line-no)))
         (count               (length line-err-info-list))
         )
    (while (> count 0)
      (when line-err-info-list
        (let* ((file       (flymake-ler-file (nth (1- count) line-err-info-list)))
               (full-file  (flymake-ler-full-file (nth (1- count) line-err-info-list)))
               (text (flymake-ler-text (nth (1- count) line-err-info-list)))
               (line       (flymake-ler-line (nth (1- count) line-err-info-list))))
          (message "[%s] %s" line text)
          )
        )
      (setq count (1- count)))))

; flymake
(when (require 'flymake nil t)
  (set-face-background 'flymake-errline "red")
  (set-face-foreground 'flymake-errline "black")
  (set-face-background 'flymake-warnline "yellow")
  (set-face-foreground 'flymake-warnline "black")

  ;; PHP用設定
  (when (not (fboundp 'flymake-php-init))
    ;; flymake-php-initが未定義のバージョンだったら、自分で定義する
    (defun flymake-php-init ()
      (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))
             (local-file  (file-relative-name
                           temp-file
                           (file-name-directory buffer-file-name))))
        (list "php" (list "-f" local-file "-l"))))
    (setq flymake-allowed-file-name-masks
          (append
           flymake-allowed-file-name-masks
           '(("\\.php[345]?$" flymake-php-init)
             ("\\.inc$" flymake-php-init)
             )))
    (setq flymake-err-line-patterns
          (cons
           '("\\(\\(?:Parse error\\|Fatal error\\|Warning\\): .*\\) in \\(.*\\) on line \\([0-9]+\\)" 2 3 nil 1)
           flymake-err-line-patterns))
    )
  (add-hook 'php-mode-hook
            #'(lambda()
                (flymake-mode t)
                (define-key php-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

  ; for Ruby
  (when (not (fboundp 'flymake-ruby-init))
    (defun flymake-ruby-init ()
      (let* ((temp-file   (flymake-init-create-temp-buffer-copy
                           'flymake-create-temp-inplace))
             (local-file  (file-relative-name
                           temp-file
                           (file-name-directory buffer-file-name))))
        (list "ruby" (list "-c" local-file)))
      )
    (push '(".+\\.rb$" flymake-ruby-init) flymake-allowed-file-name-masks)
    (push '("Rakefile$" flymake-ruby-init) flymake-allowed-file-name-masks)
    (push '("^\\(.*\\):\\([0-9]+\\): \\(.*\\)$" 1 2 nil 3) flymake-err-line-patterns)
    )

  (add-hook
   'ruby-mode-hook
   #'(lambda ()
       ;; Don't want flymake mode for ruby regions in rhtml files
       (if (not (null buffer-file-name)) (flymake-mode t))
       (define-key ruby-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)))

  ; for Python
  ;; (when (not (fboundp 'flymake-pylint-init))
  ;;   (defun flymake-pylint-init ()
  ;;     (let* ((temp-file (flymake-init-create-temp-buffer-copy
  ;;                        'flymake-create-temp-inplace))
  ;;            (local-file (file-relative-name
  ;;                         temp-file
  ;;                         (file-name-directory buffer-file-name))))
  ;;       (list "~/svn/tools/pep8.py" (list "--repeat" local-file))))

  ;;   (add-to-list 'flymake-allowed-file-name-masks
  ;;                '("\\.py\\'" flymake-pylint-init))
  ;;   (setq flymake-err-line-patterns
  ;;         (cons
  ;;          '("^\\(.*\\):\\([0-9]+\\):\\([0-9]+\\): \\(.*\\)$" 1 2 3 4)
  ;;          flymake-err-line-patterns))
  ;;   )
  ;; (add-hook
  ;;  'python-mode-hook
  ;;  '(lambda()
  ;;     (flymake-mode t)
  ;;     (define-key py-mode-map "\C-cd" 'credmp/flymake-display-err-minibuf)
  ;;     ))
  )

; gdb
(setq gdb-many-windows t)
(add-hook 'gdb-mode-hook #'(lambda () (gud-tooltip-mode t)))
(setq gdb-use-separate-io-buffer t)
(setq gud-tooltip-echo-area nil)

; run-test
(load "run-test-setting")

; clojure-mode
(setq clojure-mode-font-lock-comment-sexp t)

(defun lein-ring ()
  (interactive)
  (let ((root (locate-dominating-file default-directory "project.clj")))
    (when (not root)
      (error "Not in a Leiningen project."))
    (shell-command (format "cd %s && lein ring server-headless &" root)
                   "*lein-ring*")
    (set-process-filter (get-buffer-process "*lein-ring*")
                        (lambda (process output)
                            (set-process-filter process nil)))
    (message "Starting Clojure ring server...")))

; cl-indent-patches
; http://boinkor.net/lisp/cl-indent-patches.el
(require 'cl-indent-patches)

; sr-speedbar
(setq sr-speedbar-right-side nil)

(defun info-mode ()
  (interactive)
  (let ((file-name (buffer-file-name)))
    (kill-buffer (current-buffer))
    (info file-name)))
(add-to-list 'auto-mode-alist '("\\.info\\'" . info-mode))

; helm
(global-set-key (kbd "C-c h") 'helm-mini)
(helm-mode 1)
(setq helm-ff-transformer-show-only-basename nil)

; term-paste-mode
(require 'term-paste-mode)

; color-theme for emacs 24
(load-theme 'wombat)

(define-key ac-complete-mode-map (kbd "C-:") 'ac-complete-with-helm)

; go-mode
(require 'go-mode)
(add-hook 'go-mode-hook
          '(lambda()
            (setq c-basic-offset 4)
            (setq indent-tabs-mode t)
            (local-set-key (kbd "M-.") 'godef-jump)
            (local-set-key (kbd "C-c C-r") 'go-remove-unused-imports)
            (local-set-key (kbd "C-c i") 'go-goto-imports)
            (local-set-key (kbd "C-c d") 'godoc)))
;(add-hook 'before-save-hook 'gofmt-before-save)

; cider-mode
(require 'cider)
(add-hook 'cider-mode-hook 'cider-turn-on-eldoc-mode)
(setq nrepl-hide-special-buffers t)
(setq nrepl-buffer-name-show-port t)

(require 'org)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . t)
   (clojure . t)))

(setq org-babel-clojure-backend 'cider)

(setq org-edit-src-content-indentation 0
      org-src-tab-acts-natively t
      org-src-fontify-natively t
      org-confirm-babel-evaluate nil)

(org-defkey org-mode-map "\C-x\C-e" 'cider-eval-last-sexp)
(org-defkey org-mode-map "\C-c\C-d" 'cider-doc)

; js3-mode
(setq js3-mirror-mode t)
(autoload 'js3-mode "js3" nil t)
(add-to-list 'auto-mode-alist '("\\.js$" . js3-mode))
(add-hook 'js3-mode-hook
          (lambda ()
            (setq js3-indent-level 4)
            (setq js3-mode-dev-mode-p t)
            (setq js3-auto-indent-p t)
            (setq js3-enter-indents-newline t)
            (setq js3-indent-on-enter-key t)
            (when (require 'auto-complete nil t)
              (make-variable-buffer-local 'ac-sources)
              (add-to-list 'ac-sources 'ac-source-yasnippet)
              (auto-complete-mode t))))

; exec-path-from-shell
(exec-path-from-shell-initialize)
