(ns brog.templates
  (:require
   [net.cgrand.enlive-html :as html]))

(html/deftemplate index "views/index.html"
  [ctxt]
  [:p#message] (html/content (:message ctxt)))

(html/deftemplate admin-posts "views/admin/posts.html"
  [])

