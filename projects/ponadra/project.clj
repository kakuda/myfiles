(defproject ponadra "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :source-paths ["src/clj"]
  :jvm-opts ["-Dfile.encoding=UTF-8"]
  :dependencies [[org.clojure/clojure "1.4.0"]
                 [org.clojure/data.json "0.2.0"]
                 [clj-http "0.6.0"]
                 [local/jaad "0.8.4"]
                 [com.novemberain/monger "1.4.1"]
                 [compojure "1.1.3"]
                 [domina "1.0.0"]
                 [hiccups "0.1.1"]
                 ]
  :repositories {"project" "file:repo"}
  :plugins [[lein-cljsbuild "0.2.10"]
            [lein-ring "0.8.0"]]
  :hooks [leiningen.cljsbuild]
  :ring {:handler ponadra.core/handler
         :init ponadra.db/init
         }
  :main ponadra.tool
  :cljsbuild {:builds
              {:dev
               {
                :source-path "src/cljs"
                :compiler {
                           :output-to "resources/public/js/modern_dbg.js"
                           :optimizations :whitespace
                           :pretty-print true}}
               :pre-prod
               {
                :source-path "src/cljs"
                :compiler {
                           :output-to "resources/public/js/modern_pre.js"
                           :optimizations :whitespace}}
               :prod
               {
                :source-path "src/cljs"
                :compiler {
                           :output-to "resources/public/js/modern.js"
                           :optimizations :advanced}}
               }}
  )
