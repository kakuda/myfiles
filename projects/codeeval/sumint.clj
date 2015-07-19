(ns sumint
    (:use [clojure.string :only (split-lines)]))

(defn parse-file [f]
  (split-lines (slurp f)))

(let [l (parse-file (first *command-line-args*))]
  (println (reduce #(+ %1 (Integer/parseInt %2)) 0 l)))
