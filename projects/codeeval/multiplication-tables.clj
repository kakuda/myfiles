(ns multiplication-tables)

(doseq [l (map #(for [x (range 1 13)] (* % x)) (for [x (range 1 13)] x))]
  (println (apply str (interpose " " (map #(format "%3d" %) l)))))
