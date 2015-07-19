(ns intersection
  (:use [clojure.string :only (join split split-lines)]
        [clojure.set :only (intersection)]))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (map #(split % #",") (split line #";"))))

(doseq [i (parse-file (first *command-line-args*))]
  (println (join "," (seq (intersection (set (first i)) (set (second i)))))))
