#!/usr/bin/env bb
(require '[clojure.string :as str])
(->> (slurp (or (first *command-line-args*) "README.md"))
     (re-seq #"[a-zA-Z]+")
     (map str/lower-case)
     frequencies
     (sort-by val >)
     (run! (fn [[word count]] (println count word))))
