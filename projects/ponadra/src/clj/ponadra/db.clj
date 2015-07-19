(ns ponadra.db
  (:use
   [monger.core :only [connect! set-db! get-db]]
   monger.operators)
  (:require
   [monger.collection :as mc]
   [monger.query :as mq])
  (:import [org.bson.types ObjectId]
           [com.mongodb DB WriteConcern]))

(defn init []
  (connect!)
  (set-db! (get-db "ponadra")))

(defn add-song [item]
  (mc/insert "songs" (conj item {:_id (ObjectId.)})))

(defn latest-songs [num]
  (map #(dissoc % :_id)
       (mq/with-collection "songs"
         (mq/find {:similars {$ne []}})
         (mq/fields [:song-id :title :artist :image
                     :link :preview-url :similars])
         (mq/limit num))))

(defn update-song [oid m]
  (mc/update "songs" {:_id oid} {$set m }))

(defn all []
  (mc/find-maps "songs"))

(defn exists-song? [preview-url]
  (if (mc/find-one-as-map "songs" {:preview-url preview-url})
    true
    false))

(defn find-one [songid]
  (dissoc (mc/find-one-as-map "songs" {:song-id songid}) :_id :clj))

(defn remove-all []
  (mc/remove "songs"))
