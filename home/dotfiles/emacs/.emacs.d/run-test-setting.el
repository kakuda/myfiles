;;; run-test-setting.el

;; autoload
(autoload 'run-test "run-test" nil t)
(autoload 'run-test-in-new-frame "run-test" nil t)
(autoload 'run-test-in-mini-buffer "run-test" nil t)

;; key bindings
(define-key global-map "\C-c\C-t" 'run-test)
(define-key global-map "\C-cT" 'run-test-in-new-frame)
(define-key global-map "\C-[\M-\C-t" 'run-test-in-mini-buffer)

;;; end of file
