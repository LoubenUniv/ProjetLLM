open Deduction.Assistant

(* Print the help message *)
let print_help () = 
  print_string "Install once, after build, with: dune install\n";
  print_string "Run as:\n Deduction p <filename> \n "

  (* MS: omitted the - before the options. Now possible to execute for example with:
    dune exec Deduction p foo.txt 
   *)
let main () = 
  if Array.length Sys.argv <= 1
  then print_help ()
  else match Sys.argv.(1) with
  | "v" -> annotate := false; verifier_preuve (Sys.argv.(2))
  | "a" -> annotate := true; verifier_preuve (Sys.argv.(2))
  | "b" -> annotate := true; adroite := false; verifier_preuve (Sys.argv.(2))
  | "p" -> dnpreuve (Sys.argv.(2))
  | _ -> failwith  "missing option"
;;


 (* ---------------------------------------------------------------- *)

let () = main ()

