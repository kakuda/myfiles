(ns sum-prime)

(defn nums [] (iterate inc 2))

(defn sieve [[p & xs]]
  (remove #(= (rem % p) 0) xs))

(defn primes []
  (map first (iterate sieve (nums))))

(defn palindrome? [n]
  (= (str n) (apply str (reverse (str n)))))

(println (reduce + (take 1000 (primes))))
