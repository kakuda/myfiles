(ns multiples
  (:use [clojure.string :only (split split-lines)]))

(defn smallest-multiple [x n]
  (if (<= x n) n
      (recur x (+ n n))))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (map #(Integer/parseInt %)(split line #","))))

(doseq [i (parse-file (first *command-line-args*))]
  (let [x (first i)
        n (second i)]
    (println (smallest-multiple x n))))
