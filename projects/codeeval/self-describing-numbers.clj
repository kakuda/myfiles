(ns self-describing-numbers
  (:use [clojure.string :only (split split-lines)]))

(defn square [n]
  (* n n))

(defn square-per-digit [n]
  (map #(square (Character/digit % 10)) (str n)))

(defn happy-number? [n]
  (loop [n n, seen #{}]
    (cond (= n 1) true
          (seen n) false
          :else
          (recur (reduce + (square-per-digit n)) (conj seen n)))))

(defn self-describe? [n]
  (let [s (str n)
        idx (map-indexed (fn [i c] [i c]) s)] ; [0 \2] [1 \0] [2 \2] [3 \0]
    (map #(= (first %) (second %)) idx)))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (Integer/parseInt line)))

(doseq [i (parse-file (first *command-line-args*))]
  (println (if (self-describe? i) 1 0)))
