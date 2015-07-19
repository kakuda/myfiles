(defproject brog "1.0.0-SNAPSHOT"
  :description "gae blog app"
  :repositories {"scala-tools" "http://scala-tools.org/repo-releases/"
                 "releases" "http://appengine-magic-mvn.googlecode.com/svn/releases/"}
  :dependencies [[org.clojure/clojure "1.2.1"]
                 [org.clojure/clojure-contrib "1.2.0"]
                 [compojure "[0.6,)"]
                 [enlive "[1.0,)"]
                 [com.google.appengine/appengine-api-1.0-sdk "[1.5,)"]
                 [org.pegdown/pegdown "0.9.1"]
                 ]
  :dev-dependencies [[lein-ring "0.4.5"]
                     [swank-clojure "1.3.1"]
                     [com.google.appengine/appengine-api-labs "1.5.1"]
                     [com.google.appengine/appengine-api-stubs "1.5.1"]
                     [com.google.appengine/appengine-local-runtime "1.5.1"]
                     [com.google.appengine/appengine-local-runtime-shared "1.5.1"]
                     [com.google.appengine/appengine-testing "1.5.1"]
                     [com.google.appengine/appengine-tools-api "1.5.1"]
                     ]
  :compile-path "war/WEB-INF/classes/"
  :library-path "war/WEB-INF/lib/"
  :jvm-opts ["-Dswank.encoding=UTF-8" "-Dfile.encoding=UTF-8" "-Dinput.encoding=UTF-8"]
  ;; :run-aliases {:server [brog.core -main 8080]}
  :ring {:handler brog.core/app}
  )
