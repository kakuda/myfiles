(ns ponadra.logic
  (:require
   [ponadra.db :as db]))

(defn latest-songs
  ([]
     (latest-songs 100))
  ([num]
     (db/latest-songs num)))

(defn song [id]
  (db/find-one id))
