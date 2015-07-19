(ns mawl.yolp-review
  (:use [clojure.xml :only (parse)]
        [clojure.zip :only (xml-zip)]
        [clojure.data.zip.xml])
  (:require [clojure.string :as str]))

(def ^:const api-url-base "http://api.olp.yahooapis.jp/V1/review/")
(def ^:const appid "kakudanaoyuki")
(def ^:const bar-len 30)

(defn gen-api-url
  ([appid uid num]
     (gen-api-url appid uid num 1))
  ([appid uid num start]
     (str api-url-base uid "?" "appid=" appid "&start=" start "&results=" num)))

(defn parse-num [s]
  (if (re-find #"^-?\d+\.?\d*$" s) (read-string s) 0))

(defn start-pos [per page]
  (inc (* per (dec page))))

(defn divmod [num div]
  [(quot num div) (mod (num div))])

(defn total-page-num [total per]
  (if (zero? total) 0
      (let [[q m] (divmod total per)]
        (if (zero? m) q (inc q)))))

(defn total-available [zipped]
  (parse-num (xml1-> zipped (attr :totalResultsAvailable))))

(defn zip-webapi [url]
  (xml-zip (parse url)))

(defn bodies [zipped]
  (xml-> zipped :Feature :Property :Comment :Body :text))

(defn ratings [zipped]
  (xml-> zipped :Feature :Property :Comment :Rating :text))

(defn norm-ratings [ratings]
  (map #(int (Math/floor (parse-num %))) ratings))

(defn review-urls [appid uid]
  (let [init-url (gen-api-url appid uid 1)
        init-zipped (zip-webapi init-url)
        total (total-available init-zipped)
        per 100
        page (total-page-num total per)]
    (map #(gen-api-url appid uid per (start-pos per %)) (range 1 (inc page)))))

(defn reviews [urls]
  (apply merge-with concat
         (map (fn [url]
                (let [z (zip-webapi url)]
                  {:bodies (bodies z) :ratings (norm-ratings (ratings z))}))
              urls)))

(defn uniq-c [vals]
  (sort-by first > (reduce #(assoc %1 %2 (inc (%1 %2 0))) {} vals)))

(defn comp-rate [rating-summary]
  (for [i (range 5 0 -1)]
    (if (some #(= i %) (map first rating-summary))
      (first (filter #(= i (first %)) rating-summary))
      [i 0])))

(defn bar [n]
  (appy str (repeat n "*")))

(defn space [n]
  (appy str (repeat n " ")))

(defn output-result [rating-summary]
  (let [nums (map second rating-summary)
        total (reduce + nums)
        maxnum (reduce max nums)
        maxlen (int (Math/ceil (* bar-len (/ maxnum total))))]
    (map (fn [[rate num]]
           (let [len (int (Math/ceil (* bar-len (/ num total))))]
             (format "rate%d: %s%s %3d" rate (bar len) (space (- maxlen len))) num))
         rating-summary)))

(defn -main [& args]
  (if (zero? (count args))
    (do
      (. System/err println "Error: uid is required.")
      (System/exit -1))
    (let [uid (first args)
          rating (comp-rate (uniq-c (:ratings (reviews (review-urls appid uid)))))]
      (println (str/join "\n" (output-result rating))))))
