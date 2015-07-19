;;; fast-lookup.el --- Fast lookup alc or Yahoo! Honyaku

;; Copyright (C) 2009  Naoyuki Kakuda

;; Author: Naoyuki Kakuda <kakuda@gmail.com>

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:

;; Emacs Lisp Fast lookup is a utility that translate from English to Japanese
;; using web dictionary service.

;;; History:
;; Revision 0.0.1  2009/06/14 09:41:30  kakuda
;; Initial revision

(require 'url)

(defconst fast-lookup-version-number "0.0.1"
  "version number of fast-lookup")

(defconst fast-lookup-buffer "*Fast Lookup*"
  "Buffer name that displays translation result.")

(defconst fast-lookup-temp-buffer "*fast-lookup-temp*"
  "Output Buffer name from translation site.")

(setq fast-lookup-yahoo-regexp "<textarea rows=12 cols=30 name=\"trn_text\" id=\"trn_textText\" class=\"[a-z]*\">\\([^<]*\\)</textarea>")

(setq fast-lookup-alc-wordclass-regexp "\\(<div><span class=\"wordclass\">[^\r]*?</div></li>\\)")
(setq fast-lookup-alc-midashi-regexp "\\(<span class=\"midashi\">[^\r]*?</span></div>\\)")


(defun fast-lookup-alc (arg)
  "fast look up alc"
  (interactive "p")
  (setq english (buffer-substring-no-properties (region-beginning) (region-end)))
  (fast-lookup-alc-by-query english))

(defun fast-lookup-alc-by-query (query)
  (setq shingle (retrieve-http-content-alc (get-alc-url query)))
  (fast-lookup-initialize-buffer)
  (insert shingle)
  (sgml-mode)
  (sgml-tags-invisible t)
  (pop-to-buffer fast-lookup-buffer)
  (shrink-window-if-larger-than-buffer)
  (other-window -1))

(defun fast-lookup-yahoo (arg)
  "fast look up yahoo"
  (interactive "p")
  (setq english (buffer-substring-no-properties (region-beginning) (region-end)))
  (fast-lookup-yahoo-by-query english))

(defun fast-lookup-yahoo-by-query (query)
  (setq shingle (retrieve-http-content-yahoo query))
  (fast-lookup-initialize-buffer)
  (insert shingle)
  (pop-to-buffer fast-lookup-buffer)
  (shrink-window-if-larger-than-buffer)
  (other-window -1))

(global-set-key "\C-xy" 'fast-lookup-yahoo)
(global-set-key "\C-xc" 'fast-lookup-alc)

(defun get-alc-url (query)
  "Alc URL ’ÁÈ’¤ß’Î©’¤Æ"
  (concat "http://eow.alc.co.jp/" (fast-lookup-url-encode-string query) "/UTF-8/"))

(defun retrieve-http-content-alc (target-url)
  "HTTP ’¥²’¥Ã’¥È"
  (let ((url target-url)
        (url-request-method "GET")
        (url-request-extra-headers
         '(("User-Agent" . "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648)")))
        )
    (set-buffer (url-retrieve-synchronously url))
    (goto-char (point-min))
    (while (looking-at "HTTP/[0-9]+\\.[0-9]+ [13][0-9][0-9]")
      (delete-region (point) (re-search-forward "\r?\n\r?\n")))
    (unless (looking-at "HTTP/[0-9]+\\.[0-9]+ 200")
      (error (message "Cannot retrieve: %s" url)))
    (delete-region (point) (re-search-forward "\r?\n\r?\n"))
    (setq ret (decode-coding-string (buffer-string) 'utf-8-dos))
    (set-buffer (get-buffer-create fast-lookup-temp-buffer))
    (erase-buffer)
    (insert ret)
    (setq extracted (fast-lookup-exclusion-string fast-lookup-alc-wordclass-regexp))
    (if (eq extracted nil)
        (setq extracted (fast-lookup-exclusion-string fast-lookup-alc-midashi-regexp)))
    (if (eq extracted nil)
        (setq extracted ""))
    )
  (format "%s" extracted)
  )

(defun retrieve-http-content-yahoo (query)
  "HTTP ’¥²’¥Ã’¥È (Yahoo’ËÝ’Ìõ)"
  (let ((url "http://honyaku.yahoo.co.jp/transtext")
        (buf fast-lookup-temp-buffer)
        (url-request-method "POST")
        (url-request-extra-headers
         '(
           ("User-Agent" . "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.04506.648)")
           ("Content-Type" . "application/x-www-form-urlencoded")
           ))
        (url-request-data
         (concat "both=TH"
                 "&text=" query
                 "&clearFlg=1"
                 "&eid=CR-EJ"
                 )))
    ; ’¥«’¥ì’¥ó’¥È’¥Ð’¥Ã’¥Õ’¥¡’¤ò’»Ø’Äê
    (set-buffer (url-retrieve-synchronously url))
    (goto-char (point-min))
    (while (looking-at "HTTP/[0-9]+\\.[0-9]+ [13][0-9][0-9]")
      (delete-region (point) (re-search-forward "\r?\n\r?\n")))
    (unless (looking-at "HTTP/[0-9]+\\.[0-9]+ 200")
      (error (message "Cannot retrieve: %s" url)))
    (delete-region (point) (re-search-forward "\r?\n\r?\n"))
    (setq ret (decode-coding-string (buffer-string) 'utf-8))
    (set-buffer (get-buffer-create fast-lookup-temp-buffer))
    (erase-buffer)
    (insert ret)
    (fast-lookup-exclusion-string fast-lookup-yahoo-regexp))
    )

(defun fast-lookup-url-encode-string (str &optional coding)
  "URL’¥¨’¥ó’¥³’¡¼’¥Ç’¥£’¥ó’¥°"
  (apply (function concat)
         (mapcar
          (lambda (ch)
            (cond
             ((eq ch ?\n)               ; newline
              "%0D%0A")
             ((string-match "[-a-zA-Z0-9_:/]" (char-to-string ch)) ; xxx?
              (char-to-string ch))      ; printable
             ((char-equal ch ?\x20)     ; space
              "+")
             (t
              (format "%%%02X" ch))))   ; escape
          ;; Coerce a string to a list of chars.
          (append (encode-coding-string (or str "") (or coding 'iso-2022-jp))
                  nil))))

(defun fast-lookup-exclusion-string (regex)
  (goto-char (point-min))
  (when (re-search-forward regex nil t)
    (replace-regexp-in-string
     "</li>" "</li>\n" (match-string 1))))

(defun fast-lookup-initialize-buffer ()
  "Cleanup & create buffer"
  (interactive)
  (if (get-buffer fast-lookup-buffer)
      (kill-buffer fast-lookup-buffer)
    nil)
  (set-buffer (get-buffer-create fast-lookup-buffer))
  (erase-buffer))

(defun fast-lookup-initialize-temp-buffer ()
  "Cleanup & create temp buffer"
  (interactive)
  (if (get-buffer fast-lookup-temp-buffer)
      (kill-buffer fast-lookup-temp-buffer)
    nil)
  (set-buffer (get-buffer-create fast-lookup-temp-buffer))
  (erase-buffer))

(provide 'fast-lookup)
