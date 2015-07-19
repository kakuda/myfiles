(ns sum-digits
  (:use [clojure.string :only (split-lines)]))

(defn sum-of-digits [s]
  (reduce + (map #(Integer/parseInt (str %)) s)))

(defn parse-file [f]
  (split-lines (slurp f)))

(doseq [i (parse-file (first *command-line-args*))]
  (println (sum-of-digits i)))
