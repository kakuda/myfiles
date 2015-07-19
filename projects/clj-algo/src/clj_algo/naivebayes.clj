(ns clj-algo.naivebayes)

(defn split-word-value [s]
  (let [sq (rest (first (re-seq #"([^:]+):(\d+)" s)))]
           {(first sq) (Integer/valueOf (second sq))}))

(defn train [train-data]
  (let [categories (set (map first train-data))
        catcount (reduce #(assoc %1 (first %2) (inc (%1 (first %2) 0)))
                         {} train-data)
        vocaburaries (set (flatten (map #(map (fn [a] (first (first (split-word-value a)))) (rest %)) train-data)))
        wordcount (apply merge
                         (for [[k v]
                               (apply merge-with concat
                                      (map #(assoc {} (first %) (rest %))
                                           train-data))]
                           {k (apply merge-with + (map split-word-value v))}))
        denominator (apply merge
                           (for [[k v] wordcount]
                             {k (+ (reduce + (vals v)) (count vocaburaries))}))]
    {:categories categories
     :catcount catcount
     :vocaburaries vocaburaries
     :wordcount wordcount
     :denominator denominator}))

(defn word-prob [word cat trained]
  (/ (inc (get (get (:wordcount trained) cat) word 0))
     (get (:denominator trained) cat)))

(defn doc-prob [doc cat trained]
  (let [total (reduce + (vals (:catcount trained)))
        pp (/ (get (:catcount trained) cat) total)]
    (reduce (fn [a b]
              (let [sq (split-word-value b)
                    word (first (first sq))
                    value (second (first sq))]
                (reduce (fn [v w]
                          (* v (word-prob w cat trained)))
                        a (repeat value word))))
                        pp doc)))

(defn score [doc cat trained]
  (let [total (reduce + (vals (:catcount trained)))
        score (Math/log (/ (get (:catcount trained) cat) total))]
    (reduce (fn [a b]
              (let [sq (split-word-value b)
                    word (first (first sq))
                    value (second (first sq))]
                (reduce (fn [v w]
                          (+ v (Math/log (word-prob w cat trained))))
                        a (repeat value word))))
            score doc)))

(defn classify [doc trained]
  (reduce (fn [a b]
            (if (> (score doc a trained) (score doc b trained)) a b))
          (:categories trained)))

(defn count-words [s]
  (reduce #(assoc %1 %2 (inc (%1 %2 0)))
          {} (re-seq #"[^\s]+" (.toLowerCase s))))

(defn read-file [path]
  (map #(re-seq #"[^\s]+" %)
       (with-open [rdr (clojure.java.io/reader path)]
         (reduce conj [] (line-seq rdr)))))

(defn mutual-information [target train-data k]
  (reduce (fn [a b]
            (if (= target (first b))
              (assoc a
                :np (inc (:np a))
                :n11 (reduce (fn [a b]
                               (let [m (split-word-value b)
                                     cat (first (first m))]
                                 (assoc a cat (inc (get a cat 0)))))
                             (:n11 a) (rest b)))
              (assoc a
                :nn (inc (:nn a))
                :n10 (reduce (fn [a b]
                               (let [m (split-word-value b)
                                     cat (first (first m))]
                                 (assoc a cat (inc (get a cat 0)))))
                             (:n10 a) (rest b)))))
          {:np 0 :nn 0 :n11 {} :n10 {} :V #{}} train-data))

(defn evaluate [trainfile testfile]
  (let [train-data (read-file trainfile)
        trained (train train-data)
        test-data (read-file testfile)
        numtest (count test-data)
        hit (reduce (fn [hit line]
                      (let [correct (first line)
                            words (rest line)
                            predict (classify words trained)]
                        (if (= correct predict) (inc hit) hit)))
                    0 test-data)]
    (println "accuracy:", (/ (float hit) (float numtest)))))

(defn test1 []
  (let [data [["yes", "Chinese:2", "Beijing:1"]
              ["yes", "Chinese:2", "Shanghai:1"]
              ["yes", "Chinese:1", "Macao:1"]
              ["no", "Tokyo:1", "Japan:1", "Chinese:1"]]
        trained (train data)
        test ["Chinese:3", "Tokyo:1", "Japan:1"]]
    (println "P(Chinese|yes) = ", (float (word-prob "Chinese" "yes" trained)))
    (println "P(Tokyo|yes) = ", (float (word-prob "Tokyo" "yes" trained)))
    (println "P(Japan|yes) = ", (float (word-prob "Japan" "yes" trained)))
    (println "P(Chinese|no) = ", (float (word-prob "Chinese" "no" trained)))
    (println "P(Tokyo|no) = ", (float (word-prob "Tokyo" "no" trained)))
    (println "P(Japan|no) = ", (float (word-prob "Japan" "no" trained)))

    (println "log P(yes|test) = ", (score test "yes" trained))
    (println "log P(no|test) = ", (score test "no" trained))
    (println (classify test trained))
    ))
