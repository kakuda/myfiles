(ns ponadra.view
  (:use
   [hiccup.core :only [html h]]
   [hiccup.page :only [doctype include-js include-css]]
   [hiccup.form :only [form-to label text-area submit-button]])
  (:require
   [clojure.data.json :as json]))

(defn render-json [obj]
  {:status  200
   :headers {"Content-Type" "application/json"}
   :body    (json/write-str obj)}
  )

(defn layout [title & body]
  (html
   (doctype :html5)
   [:html
    [:head
     [:meta {:charset "utf-8"}]
     [:title title]
     [:meta {:name "viewport"
             :content "width=device-width, initial-scale=1.0"}]
     "<!--[if lt IE 9]>"
     (include-js "http://html5shim.googlecode.com/svn/trunk/html5.js")
     "<![endif]-->"
     (include-css "/css/bootstrap.min.css")
     (include-css "/css/bootstrap-responsive.min.css")
     (include-css "/css/bootswatch.css")
     (include-css "/css/bootstrap-image-gallery.css")]
    [:body {:class "preview" :data-spy "scroll"
            :data-target ".subnav" :data-offset "80"}
     body]
    (include-js "//ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js")
    (include-js "/js/bootstrap.min.js")
    (include-js "/js/load-image.min.js")
    (include-js "/js/bootstrap-image-gallery.js")
    (include-js "/js/main.js")
    (include-js "/js/albumcolors.js")
    ]))

(defn navbar []
  [:div {:class "navbar navbar-fixed-top"}
   [:div {:class "navbar-inner"}
    [:div {:class "container"}
     [:a {:class "btn btn-navbar" :data-toggle "collapse" :data-target ".nav-collapse"}
      [:span {:class "icon-bar"}]
      [:span {:class "icon-bar"}]
      [:span {:class "icon-bar"}]]
     [:a {:class "brand" :href "/"} "Ponadra"]
     [:div {:class "nav-collapse" :id "main-menu"}
      [:ul {:class "nav" :id "main-menu-left"}
       [:li {:class "active"} [:a {:href "/"} "Home"]]]
      [:ul {:class "nav pull-right" :id "main-menu-right"}
       [:li [:a {:href "#about"} "About"]]
       [:li [:a {:href "#contact"} "Contact"]]]
      ]
     ]
    ]])

(defn footer []
  [:footer
   [:p {:id "pd-footer"} (str "&copy; JavaEE Study Group ")]
   ])

(defn start-buttons []
  [:p
   [:button {:id "toggle-fullscreen" :class "btn btn-large btn-success" :data-toggle "button"} "Fullscreen"]])

(defn modal-gallery []
  [:div {:id "modal-gallery" :class "modal modal-gallery hide fade" :tabindex "-1"}
   [:div {:class "modal-header"}
    [:a {:class "close" :data-dismiss "modal"} "&times;"]
    [:h4 {:class "modal-title"}]]
   [:div {:class "modal-body"}
    [:div {:class "modal-image"}]]])

(defn index []
  (layout "Ponadra"
          (navbar)
          [:div {:class "container"}
           [:header {:class "jumbotron subhead" :id "overview"}
            [:div {:class "row"}
             [:div {:class "span6"}
              [:h1 "Ponadra"]
              [:p {:class "lead"} "iTunes Preview Song Player & Recommendation Service"]]
             [:div {:class "span6"}
             (start-buttons)
              ]
             ]
            ]
           [:div {:id "gallery" :data-toggle "modal-gallery" :data-target "#modal-gallery"}]
           [:br]
           (modal-gallery)
           (footer)
           ]
          ))
