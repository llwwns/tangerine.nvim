; DEPENDS:
; (-string)  tangerine.fennel
; (-string)  tangerine.utils.logger
; (-file)    tangerine.utils.path
; (-file)    tangerine.utils.fs
(local fennel (require :tangerine.fennel))
(local p      (require :tangerine.utils.path))
(local fs     (require :tangerine.utils.fs))
(local log    (require :tangerine.utils.logger))

;; -------------------- ;;
;;         Utils        ;;
;; -------------------- ;;
(lambda get-lines [start end]
  (-> (vim.api.nvim_buf_get_lines 0 (- start 1) end true)
      (table.concat "\n")))

(lambda softerr [msg]
  (vim.cmd "echohl Error")
  (vim.cmd (.. "echo '" msg "'"))
  (vim.cmd "echohl none"))

;; -------------------- ;;
;;         Main         ;;
;; -------------------- ;;
(lambda eval-string [str ?filename]
  (let [fennel (fennel.load)
        filename (or ?filename :string)]
       :eval   (local result (fennel.eval str {: filename}))
       :logger (log.value result)))

(lambda eval-file [path]
  "slurp 'path' and pass it off for evaluation."
  (let [path (p.resolve path)
        filename (p.shortname path)]
       :eval (eval-string (fs.read path) filename)))

(lambda eval-range [start end ?count]
  "evalute lines 'start' to 'end' in current vim buffer."
  (when (= ?count 0)
    (softerr "[tangerine]: error in \"eval-range\", Missing argument {range}.")
    (lua :return))
  (let [lines   (get-lines start end)
        bufname (vim.fn.expand :%)]
       :eval (eval-string lines bufname)))

(lambda eval-buffer []
  "evaluate all lines in current vim buffer."
  :eval ";)" (eval-range 1 -1))

:return {
  :string eval-string         
  :file   eval-file
  :range  eval-range
  :buffer eval-buffer
}