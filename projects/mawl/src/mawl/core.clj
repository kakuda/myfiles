(ns mawl.core
  (:require
   [clojure.string :as cs]
   [clj-http.client :as client])
  (:import
   (org.mozilla.universalchardet UniversalDetector Constants))
  )

(def headers {"User-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.11 (KHTML, like Gecko) Chrome/23.0.1271.6 Safari/537.11"
              "Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
              "Accept-Language", "ja,en-us;q=0.7,en;q=0.3",
              "Accept-Encoding", "gzip,deflate",
              "Accept-Charset", "Shift_JIS,utf-8;q=0.7,*;q=0.7",
              "Keep-Alive", "300",
              "Connection", "keep-alive"})

(defn fetch-adhoc [url]
  (:body (client/get url {:as :byte-array :headers headers})))

(def fetch (memoize fetch-adhoc))

(defn filter-remove-tag [byte-array]
  (.getBytes (cs/replace (String. byte-array "utf-8") "<.*?>" "") "utf-8"))

(defn detect [byte-array]
  (.getDetectedCharset
   (doto
       (UniversalDetector. nil)
     (.handleData  byte-array 0 (count byte-array))
     (.dataEnd))))

(defn to-utf8 [byte-array]
  (String. byte-array (detect byte-array)))

(defn fetch-utf8 [url]
  (to-utf8 (fetch url)))

(defn re-seconds [re str]
  (map second (re-seq re str)))

(defn ext-title [url]
  (re-seconds #"<B><FONT size=\"\+2\">(.*?)<\/FONT><\/B>" (to-utf8 (fetch url))))
