(ns unpassize
  (:use [clojure.java.shell :only [sh]])
  (:import [java.io File]
           [java.util.regex Pattern]))

(defn make-regexp [ext]
  (Pattern/compile (str ".*\\." ext "$")))

(defn filter-ext [files ext]
  (filter #(re-seq (make-regexp ext) %) files))

(defn list-dirs [path]
  (let [f (File. path)]
    (map #(str (.getAbsolutePath f) "/" (.getName %))
         (filter #(.isDirectory %) (.listFiles f)))))

(defn exists-subdir? [path]
  (some #(.isDirectory %) (.listFiles (File. path))))

(defn flatten-dir [path dest]
  (let [f (File. path)]
    (if (exists-subdir? path)
      (doseq [dir (filter #(.isDirectory %) (.listFiles f))]
        (.renameTo dir (File. dest (.getName dir))))
      (.renameTo f (File. dest (.getName f))))))

(defn list-files [path]
  (let [f (File. path)]
    (map #(str (.getAbsolutePath f) "/" (.getName %)) (.listFiles f))))

(defn mkdir! [path]
  (if-not (.exists (File. path))
    (.mkdir (File. path))))

(defn cmd-fail? [res]
  (not= 0 (:exit res)))

(defn outdir-name [res]
  (first (distinct (map second (re-seq #"Extracting +(.*?)/.*?\.\p{Alpha}+\n" (:out res))))))

(defn unrar! [path dir pass]
  (sh "/opt/local/bin/unrar" "x" (format "-p%s" pass) "-x*.txt" path dir))

(defn p7zx! [path dir pass]
  (sh "/opt/local/bin/7za" "x" (format "-p%s" pass) (format "-o%s" dir) path))

(defn p7za! [path outdir]
  (sh "/opt/local/bin/7za" "a" (str outdir "/" (.getName (File. path)) ".7z") "-r" (str path "/*")))

(def *in-path* "/Volumes/HDD1/work")
(def *out-path* (str *in-path* "/out"))
(def *move-path* (str *in-path* "/move"))
(def *archive-path* (str *in-path* "/archive"))
(def *failed-path* (str *in-path* "/failed"))
(def *passwords* ["fac1ca55" "I7zMV2" "Guill666"])

(defn move-failed-dir [path]
  (println "moved failed path:" path)
  (mkdir! *failed-path*)
  (let [from (File. path)
        to   (File. *failed-path*)]
    (.renameTo from (File. to (.getName from)))))

(defn decompress [path dir type passes]
  (if (empty? passes)
    (move-failed-dir path)
    (let [fname (if (= type :7z) p7zx! unrar!)
          res (fname path dir (first passes))]
      (if (cmd-fail? res)
        (decompress path dir type (rest passes))
        (outdir-name res)))))

(defn extract-archive [path]
  (cond (.endsWith path ".rar")
        (decompress path *out-path* :rar *passwords*)
        (.endsWith path ".7z")
        (decompress path *out-path* :7z *passwords*)))

(defn agent-rearchive []
  (let [files (list-files *in-path*)
        agents (map #(agent %) files)]
    (mkdir! *out-path*)
    (mkdir! *move-path*)
    (doseq [agent agents] (send agent extract-archive))
    (apply await agents)))

(defn parallel-rearchive []
  (println "extract archives")
  ; extract archives
  (let [files (list-files *in-path*)]
    (mkdir! *out-path*)
    (doall
     (pmap extract-archive files)))

  (println "move directories")
  ; move directories
  (let [dirs (list-dirs *out-path*)]
    (mkdir! *move-path*)
    (doall
     (pmap #(flatten-dir % *move-path*) dirs)))

  (println "archive directories")
  ; archive directories
  (let [dirs (list-dirs *move-path*)]
    (doall
     (pmap #(p7za! % *archive-path*) dirs))))

(parallel-rearchive)
