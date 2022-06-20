; ABOUT:
;   Contains diffing algorithm used by compiler.
;
;   Works by creating marker that looks like `-- :fennel:<UTC>`,
;   compares UTC in marker to ftime(source).
(local df {})

;; -------------------- ;;
;;         Main         ;;
;; -------------------- ;;
(lambda df.create-marker [source]
  "generates a comment tag from ftime of 'source'."
  "-- :fennel:generated")

(lambda df.read-marker [path]
  "reads marker located in first 21 bytes of 'path'."
  (with-open [file (assert (io.open path "r"))]
    (local bytes  (or (file:read 21) ""))
    (bytes:match ":fennel:generated")))

(lambda df.stale? [source target]
  "compares marker of 'target' with ftime(source), true if source is stale."
  (if (not= 1 (vim.fn.filereadable target))
      (lua "return true"))
  (let [source-time (vim.fn.getftime source)
        target-time (vim.fn.getftime target)]
    (> source-time target-time)))


:return df
