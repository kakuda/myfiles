(ns clj-algo.core)

(defn box-muller
  "ボックス＝ミューラー法による正規乱数"
  []
  (* (Math/sqrt (* -2.0 (Math/log (Math/random)))) (Math/sin (* 2.0 Math/PI (Math/random)))))

(defn arithmetic-mean
  "算術平均"
  [xs]
  (cond
   (empty? xs) 0
   (and (= (count xs) 1) (zero? (first xs))) 0
   :else (/ (reduce + xs) (count xs))))

(defn standard-deviation
  "標準偏差"
  [xs]
  (cond
   (empty? xs) 0
   (and (= (count xs) 1) (zero? (first xs))) 0
   :else (let [mean (arithmetic-mean xs)
               n (count xs)]
           (Math/sqrt (/ (reduce + (map #(Math/pow (- % mean) 2) xs)) n)))))

(defn median
  "中央値"
  [xs]
  (cond
   (empty? xs) 0
   (and (= (count xs) 1) (zero? (first xs))) 0
   :else 
  )
