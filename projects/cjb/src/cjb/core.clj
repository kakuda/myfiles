(ns cjb.core)

(defn hash [s]
  (reduce (fn [h c] (+ (* 33 h) (int c))) 5381 s))

(defn make [f]
  )

(defn add [k, v]
  )

(defn get [k]
  )

(defn dump []
  )
