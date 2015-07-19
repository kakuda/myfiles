(ns clj-algo.rating
  (:import [java.util Calendar]
           [java.math MathContext]))
; http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
; http://d.hatena.ne.jp/makiyamakoji/20090512/p1

(def b [1.570796288 0.03706987906 -0.8364353589e-3
        -0.2250947176e-3 0.6841218299e-5 0.5824238515e-5
        -0.104527497e-5 0.8360937017e-7 -0.3231081277e-8
        0.3657763036e-10 0.6936233982e-12])

(defn p-normal-dist
  "正規分布のパーセンタイルを計算する"
  [percent]
  (cond
   (or (<= percent 0) (<= 1 percent)) Double/NaN
   (= percent 0.5) 0
   :else
   (let [w3 (- (Math/log (* 4 percent (- 1 percent))))
         w1 (reduce #(+ %1 (* (b %2) (Math/pow w3 %2)))
                    (first b) (range 1 (count b)))]
     (if (> percent 0.5)
       (Math/sqrt (* w1 w3))
       (- (Math/sqrt (* w1 w3)))))))

(defn score
  ([ratings percent]
     (let [pos (filter #(= 1 %) ratings)
           neg (filter zero? ratings)]
       (score (count pos) (count neg) percent)))
  ([pos neg percent]
     (let [n (+ pos neg)
           p (/ pos n)
           z (p-normal-dist percent)
           z2 (* z z)
           temp (+ (* p (- 1 p)) (/ z2 (* 4 n)))
           numerator (- (+ p (/ z2 (* 2 n))) (* z (Math/sqrt (/ temp n))))
           denominator (+ 1 (/ z2 n))]
       (/ numerator denominator))))

(defn score5 [ratings percent]
  (let [posneg (reduce (fn [m r]
                         (let [[p n] (cond
                                      (= r 5) [4 0]
                                      (= r 4) [3 1]
                                      (= r 3) [2 2]
                                      (= r 2) [1 3]
                                      (= r 1) [0 4])]
                           (assoc m
                             :pos (+ p (m :pos))
                             :neg (+ n (m :neg)))))
                       {:pos 0 :neg 0} ratings)]
    (score (posneg :pos) (posneg :neg) percent)))

; http://amix.dk/blog/post/19588

(defn reddit-hot [ups downs date]
  (let [cal (-> (doto (Calendar/getInstance)
                  (.clear)
                  (.setTime date))
                (.getTimeInMillis))
        s (- ups downs)
        order (Math/log10 (max (Math/abs s) 1))
        sign (if (> s 0) 1 (if (< s 0) -1 0))
        seconds (- cal 1134028003)]
    (.floatValue (BigDecimal. (+ order (/ (* sign seconds) 45000)) (MathContext. 7)))))
