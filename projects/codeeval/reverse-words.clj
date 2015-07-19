(ns reverse-words
  (:use [clojure.string :only (join split split-lines)]))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (split line #" ")))

(doseq [i (parse-file (first *command-line-args*))]
  (println (join " " (reverse i))))
