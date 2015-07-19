(defproject mawl "1.0.0-SNAPSHOT"
  :description "FIXME: write"
  :dependencies [[org.clojure/clojure "1.4.0"]
                 [org.clojure/tools.nrepl "0.2.0-beta10"]
                 [org.clojure/data.json "0.2.0"]
                 [clj-http "0.5.8"]
                 [com.google.gerrit/juniversalchardet "1.0.3"]]
  :jvm-opts ["-Dswank.encoding=utf-8-unix"]
  :repositories {"gerrit" "http://gerrit.googlecode.com/svn/mavenrepo/"}
  )
