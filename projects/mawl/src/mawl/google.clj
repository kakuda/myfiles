(ns mawl.google
  (:use mawl.core))

; http://www.takanashi-it-factory.com/archives/316
; https://developers.google.com/web-search/docs/reference?hl=ja#_intro_fonje

(def websearch-api-pref "http://ajax.googleapis.com/ajax/services/search/web?v=1.0&callback=foo&context=bar&rsz=large&start=0&hl=ja&q=")

(defn websearch [q]
  (fetch (str websearch-api-pref 