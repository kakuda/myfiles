(ns brog.datastore
  (:import
   [com.google.appengine.api.datastore
    DatastoreServiceFactory DatastoreService Entity Query PreparedQuery Key]
   [java.util Date]))

(defonce *ds* (DatastoreServiceFactory/getDatastoreService))

(defn add-article!
  [title body]
  (add-article! title body (Date.))
  [title body created-at]
  (let [article (Entity. "Article")]
    (.put *ds*
          (doto article
              (.setProperty "title" title)
              (.setProperty "body" body)
              (.setProperty "created_at" created-at)))))

(defn all-articles []
  (let [query (Query. "Article")
        preq (.prepare *ds* query)]
    (iterator-seq (.asIterator preq))))

(defn delete-all-articles! []
  (let [keys (map #(.getKey %) (all-articles))]
    (.delete *ds* Key (into-array keys))))

(comment
  DatastoreService datastore = DatastoreServiceFactory.getDatastoreService();

Entity employee = new Entity("Employee");
employee.setProperty("firstName", "Antonio");
employee.setProperty("lastName", "Salieri");
Date hireDate = new Date();
employee.setProperty("hireDate", hireDate);
employee.setProperty("attendedHrTraining", true);

datastore.put(employee);

// all items
DatastoreService datastoreService
     = DatastoreServiceFactory.getDatastoreService();
Query query = new Query("Employee");
PreparedQuery preparedQuery = datastoreService.prepare(query);
for(Entity empEntity : preparedQuery.asIterable()){
     System.out.println(
          empEntity.getKind() + " - " + empEntity.getKey() );
                                                   }

// delete
DatastoreService datastoreService
     = DatastoreServiceFactory.getDatastoreService();
Query query = new Query("Employee");
         
PreparedQuery preparedQuery = datastoreService.prepare(query);
for(Entity empEntity : preparedQuery.asIterable()){
     datastoreService.delete(empEntity.getKey());
                                                   }

// filter query
DatastoreService datastoreService
     = DatastoreServiceFactory.getDatastoreService();
Query query = new Query("Employee");
query.addFilter("lastName", Query.FilterOperator.EQUAL, "Oyama");

PreparedQuery preparedQuery = datastoreService.prepare(query);
for(Entity empEntity : preparedQuery.asIterable()){
     System.out.println(
          empEntity.getKind() + " - " + empEntity.getKey()
     );
}
)
