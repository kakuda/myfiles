(ns filesize)

(println (.length (java.io.File. (first *command-line-args*))))
