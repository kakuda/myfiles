(ns brog.middleware)

(defn wrap-charset [handler charset]
  (fn [request]
    (if-let [response (handler request)]
      (if-let [content-type (get-in response [:headers "Content-Type"])]
        (if (.contains content-type "charset")
          response
          (assoc-in response
                    [:headers "Content-Type"]
                    (str content-type "; charset=" charset)))
        response))))

(defn- log [msg & vals]
  (let [line (apply format msg vals)]
    (locking System/out (println line))))

(defn wrap-request-logging [handler]
  (fn [{:keys [request-method uri] :as req}]
    (let [resp (handler req)]
      (log "Processing %s %s" request-method uri)
      resp)))

(defn wrap-request-dump [handler]
  (fn [request]
    (let [response (handler request)
          req-keys (keys request)]
      (println "-----------start---------")
      (doseq [k req-keys]
        (println (format "%s => %s" (name k) (k request))))
      (println "------------end----------")
      response)))
