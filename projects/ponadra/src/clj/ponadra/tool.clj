(ns ponadra.tool
  (:use ponadra.itunes
        clojure.java.shell)
  (:require [ponadra.db :as db]))

(defn crawl []
  (doseq [url (map #(feed-url % "topsongs" 10) (keys genres))]
    (println url)
    (doseq [item (feed url)]
      (let [entry (extract-entry item)
            preview-url (:preview-url entry)]
        (when (not (db/exists-song? preview-url))
          (println (str (:title entry) " / " (:artist entry)))
          (db/add-song entry)
          (when (not (exists-preview? preview-url))
            (Thread/sleep 500)
            (download preview-url "songs/m4a")
            ))))))

(defn update-image []
  (doseq [entry (db/all)]
    (let [id (:_id entry)
          image (-> (read-string (:clj entry)) :im:image last :label)]
      (db/update-song id {:image image}))))

(defn add-preview-id []
  (doseq [entry (db/all)]
    (let [id (:_id entry)
          image (-> (read-string (:clj entry)) :im:image last :label)]
      (db/update-song id {:image image}))))

(defn clean []
  (println (sh "sh" "-c" "rm -rf songs/*.m4a songs/mp3/*.mp3 songs/mfcc/*.mfc songs/raw/*.raw songs/sig/*.sig"))
  (db/remove-all)
  )

(defn calc []
;  (sh "sh" "./m4a-to-mp3.sh" :dir "songs")
  (sh "python" "/Users/kaku/Documents/Programs/Python/aidiary/mp3_to_mfcc.py" "songs/mp3" "songs/mfcc" "songs/raw")
  (sh "python" "/Users/kaku/Documents/Programs/Python/aidiary/mfcc_to_signature.py" "songs/mfcc" "songs/sig")
  )

(defn -main [& args]
  ;; (db/init)
  ;; (clean)
  ;; (crawl)
  (calc)
  ;(update-image)
  )
