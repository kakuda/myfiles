(ns fibonacci
  (:use [clojure.string :only (split-lines)]))

(defn fib [n]
  (take (inc n) (map first (iterate (fn [[a b]] [b (+ a b)]) [0 1]))))

(defn parse-file [f]
  (map #(Integer/parseInt %) (split-lines (slurp f))))

(doseq [i (parse-file (first *command-line-args*))]
  (println (last (fib i))))

