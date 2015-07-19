(ns clj-algo.search
  (:use clojure.set))
; http://www.slideshare.net/igrigorik/building-mini-google-in-ruby

(def docs [[1 "今日はいい天気です"]
           [2 "今日はラーメンを食べました"]
           [3 "私はラーメンが大好きです"]
           [4 "私はサカナクションが大好きです"]])

(defn bigram [s]
  (map #(apply str %) (partition 2 1 s)))

(defn inverted-index [docs]
  (reduce (fn [idx doc]
            (let [[id text] doc]
              (merge-with union idx
                          (zipmap (bigram text) (repeat #{id})))))
          {} docs))

(defn search [idx query]
  (let [q (cond
           (string? query) (bigram query)
           (vector? query) (flatten (map bigram query)))]
    (apply intersection (map idx q))))
