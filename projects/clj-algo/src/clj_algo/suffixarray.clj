(ns clj-algo.suffixarray)

(defn suffix-array [^String s]
  (sort-by
   second
   (loop [s s
          idx 0
          acc '()]
     (if (empty? s) acc
         (recur (apply str (rest s)) (inc idx) (cons [idx s] acc))))))

(defn suffix-array2 [^String s]
  (sort-by
   second
   (zipmap (iterate inc 0)
           (map #(apply str %)
                ;(take-while not-empty (iterate rest s))))
                (take-while identity (iterate next s))))))

(defn suffix-array3 [^String s]
  (if (empty? s) '()
      (cons s (suffix-array3 (rest s)))))

;; user> (time (dotimes [_ 100000] (suffix-array "abracadabra")))
;; "Elapsed time: 1733.048 msecs"
;; user> (time (dotimes [_ 100000] (suffix-array2 "abracadabra")))
;; "Elapsed time: 3209.27 msecs"
;; nil
