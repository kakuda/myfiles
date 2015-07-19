(ns brog.core
  (:use
   compojure.core
   [ring.adapter.jetty :only [run-jetty]]
   ring.middleware.stacktrace
   ring.middleware.reload
   brog.middleware
   brog.datastore)
  (:require
   [compojure.route :as route]
   [brog.templates :as tmpl])
  (:gen-class
   :extends javax.servlet.http.HttpServlet))

(defn render [t]
  (apply str t))

(defn post-article [params]
  (println params)
  "post")

(defroutes main-routes
  (GET "/" [] (render (tmpl/index {:message "最新の記事っす"})))
  (GET "/admin/posts" [] (render (tmpl/admin-posts)))
  (POST "/admin/posts" {params :params} (post-article params))
  (route/not-found "<h1>Page Not Found.</h1>"))

(def app
     (-> main-routes
         (wrap-charset "utf-8")
;         (wrap-request-logging)
         (wrap-request-dump)
         (wrap-reload '[brog.core])
         (wrap-stacktrace)))

(defn start-server [port]
  (run-jetty app {:port port}))

;; (defn- main [& port]
;;   (if port
;;     (start-server (Integer/parseInt port))
;;     (start-server 8080)))
