(ns rightmost
  (:use [clojure.string :only (split split-lines)]))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (split line #",")))

(doseq [i (parse-file (first *command-line-args*))]
  (let [S (first i)
        t (second i)]
   (println (.lastIndexOf S t))))
