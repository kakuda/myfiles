(ns ponadra.itunes
  (:use [clojure.string :only (join split)]
        [clojure.java.io :only (make-output-stream file)])
  (:require [clj-http.client :as client])
  (:gen-class))

(def ^:const genres {:j-pop 27 :r&b 15 :anime 29 :electro 7 :alternative 20 :classic 5 :soundtrack 16 :jazz 11 :dance 17 :hiphop 18 :fitness 50 :blues 2 :pop 14 :reggae 24 :rock 21 :world 19 :vocal 23 :folk 30})

(def ^:const feedtype #{"topalbums" "topmixes" "topsongs" "newreleases" "justadded" "featuredalbums"})

(def ^:const rss-format "http://itunes.apple.com/jp/rss/%s/limit=%d/genre=%d/json")

(defn feed-url
  ([genre]
     (feed-url genre "topsongs"))
  ([genre feed]
     (feed-url genre feed 10))
  ([genre feed num]
     (format rss-format feed num (genres genre))))

(defn filename [url]
  (last (split url #"/")))

(defn remove-ext [filename]
  (first (split filename #"\.aac(\.p)?\.m4a")))

(defn extract-entry [item]
  (let [url (((first (filter #(boolean (% :im:duration)) (item :link))) :attributes) :href)]
    {:title (-> item :im:name :label)
     :artist (-> item :im:artist :label)
     :image (-> item :im:image last :label)
     :link (-> item :id :label)
     :price (-> item :im:price :label)
     :preview-url url
     :song-id (remove-ext (filename url))
     :category (-> item :category :attributes :label)
     :releasedate (-> item :im:releaseDate :attributes :label)
     :similars []
     :clj (str item)
     }))

(defn feed [url]
  (-> (client/get url {:as :json}) :body :feed :entry))

(defn fetch-songs [url]
  (map extract-entry (feed url)))

(defn download
  ([url]
     (download url "."))
  ([url dir]
     (let [res  (client/get url {:as :byte-array})
           data (:body res)
           name (filename url)]
       (with-open [w (make-output-stream (join "/" [dir name]) {})]
         (.write w data)))))

(defn exists-preview? [url]
  (let [filename (filename url)]
    (.exists (file (str "songs/" filename)))))
