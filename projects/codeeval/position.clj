(ns position
  (:use [clojure.string :only (split split-lines)]))

(comment
  86  -> "1010110" 2,3  true
  125 -> "1111101" 1,2  false
)

(defn every-bit? [n p]
  (let [bn (reverse (Integer/toBinaryString n))]
    (if (every? #(= (nth bn (dec %)) \1) p)
      "true"
      "false")))

(defn parse-file [f]
  (for [line (split-lines (slurp f))]
    (map #(Integer/parseInt %) (split line #","))))

(doseq [i (parse-file (first *command-line-args*))]
  (let [n (first i)
        p (rest i)]
    (println (every-bit? n p))))
