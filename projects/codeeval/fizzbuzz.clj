(ns fizzbuzz
  (:use [clojure.string :only (join split split-lines)]))

(defn make-fizzbuzz-p [div]
  (fn [n] (zero? (rem n div))))

(defn to-fbstr [n fizz-p buzz-p]
  (cond (and (fizz-p n) (buzz-p n))
        "FB"
        (fizz-p n)
        "F"
        (buzz-p n)
        "B"
        :else (str n)))

(defn fb-line [f b n]
  (let [fizz-p (make-fizzbuzz-p f)
        buzz-p (make-fizzbuzz-p b)
        max (+ 1 n)]
    (for [n (range 1 max)]
      (to-fbstr n fizz-p buzz-p))))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (map #(Integer/parseInt %) (split line #" "))))

; main

(doseq [i (parse-file (first *command-line-args*))]
  (let [f (first i)
        b (second i)
        n (nth i 2)]
    (println (join " " (fb-line f b n)))))
