;;; undo-group.el --- Undo groups of changes
;;
;; ~harley/share/emacs/pkg/undo-group/undo-group.el ---
;;
;; $Id: undo-group.el,v 1.12 2003/03/17 18:50:16 harley Exp $
;;

;; Author:    Harley Gorrell <harley@mahalito.net>
;; URL:       http://www.mahalito.net/~harley/elisp/undo-group.el
;; License:   GPL v2

;;; Commentary:
;; * Undo a group of changes at a time.
;; * You explicitly set the group mark.
;; * Make your undo-limit and undo-strong-limit really big!

;; An undo boundary is marked with a single nil (nil). A
;; undo group boundary is marked with a double nil (nil
;; nil).  This choice means the present undo code does not
;; have to be changed and you can undo though groups with a
;; pause at the group boundary.  This also relies upon the
;; fact that the function undo-boundary will not add a
;; boundary if one is already there.

;; Presently, if invoked without a group boundary it will
;; undo to the beginning.

;;; History:
;; 98-May-13 : jhg
;; - written as a lark for Jonathan Epstein
;;   <Jonathan_Epstein@nih.gov> who was "looking for a
;;   mechanism to perform transaction-oriented undo operations
;;   in emacs."  (Message-ID: <355A0821.67598B48@nih.gov>)
;;
;; 98-May-23 : jhg
;; - Renamed to undo-group.
;; - Undo group boundary is now a double nil
;;
;;  2003-03-16 : Updated URL and contact info.

;;; Code:

(defvar undo-group-list nil
  "Temporary global variable.")

;;;###autoload
(defun undo-group-boundary ()
  "Mark an undo group boundary."
  (interactive)
  (if (car buffer-undo-list) ; check for first null
      (setq buffer-undo-list (cons nil buffer-undo-list)))
  (if (car (cdr buffer-undo-list)) ; check for second
      (setq buffer-undo-list (cons nil buffer-undo-list)))
  nil)

;;;###autoload
(defun undo-group (&optional arg)
  "Undo a entire group (or ARG groups) of changes."
  (interactive "*p")
  (setq arg (or arg 1))
  (if (not (eq last-command 'undo))
      (progn (undo-start)
	     (undo-more 1))) ; pop first nil
  ;; Undo how many?
  (undo-more (undo-group-count arg pending-undo-list))
  ;; i am a member of the undo family
  (setq this-command 'undo))


(defun undo-group-count (arg undolist)
  "Count the number of undos in the last ARG UNDOLIST groups."
  (let ((ucount 0))
    (while (and (> arg 0) undolist)
      (if (null (car undolist)) ; undo boundary
	  (setq ucount (+ ucount 1)))
      (if (not (or (car undolist) (car (cdr undolist)))) ; group boundary
	  (setq arg (- arg 1)))
      (setq undolist (cdr undolist))
      (if (null undolist)
	  (setq ucount (+ ucount 1)))
      )
    ;; trailing null
    (if (and undolist (null (car undolist)))
	  (setq ucount (+ ucount 1)
		undolist (cdr undolist)))
    ucount))

;;
(provide 'undo-group)

;;; undo-group ends here
