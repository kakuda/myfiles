(ns lowercase
  (:use [clojure.string :only (split-lines)]))

(defn parse-file [f]
  (split-lines (slurp f)))

(doseq [i (parse-file (first *command-line-args*))]
    (println (.toLowerCase i)))
