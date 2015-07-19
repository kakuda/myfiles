(ns ponadra.core
  (:use
   [compojure.core :only [defroutes GET POST]])
  (:require
   [compojure.handler :as handler]
   [compojure.route :as route]
   [ponadra.view :as view]
   [ponadra.logic :as logic]
   ))

(defroutes app-routes
  (GET "/" []
       (view/index))

  (GET "/api/songs" []
       (view/render-json (logic/latest-songs)))
  (GET "/api/song/:id" [id]
       (view/render-json (logic/song id)))

  (route/resources "/")
  (route/not-found "<h1>Page Not Found.</h1>"))

(def handler
  (handler/site app-routes))
