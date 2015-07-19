; ファイルを1行づつ処理する
(use 'clojure.contrib.io)
(use '[clojure.contrib.duck-streams :only (reader)])
(doseq [line (line-seq (reader (java.io.File. "foo.txt")))]
  (println line))

; ファイルを1行づつ処理する type2
(use 'clojure.contrib.io)
(use '[clojure.contrib.duck-streams :only (read-lines)])
(doseq [line (read-lines "./build.xml")]
  (println line))

; 正規表現で分割
(re-split #"\n" "foo\nbar\nyoo") ; => ("foo" "bar" "yoo")

; HTTP接続
(use '[clojure.contrib.http.agent :only (http-agent string)])
(string (http-agent "http://search.yahoo.co.jp"))

; ファイルオープン
(with-open [rdr (java.io.BufferedReader. (java.io.FileReader. "abc.txt"))]
  (doseq [line (line-seq rdr)]
    (println line)))

(doseq [f (file-seq (java.io.File. "/Users/kaku/Documents/Programs/Python"))]
  (println (.getAbsolutePath f)))
