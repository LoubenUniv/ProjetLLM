(* open Format;; *)
open String;;




type   formula =
  | Var of string
  | False
  | Imp of formula*formula
  | Disj of formula*formula
  | Conj of formula*formula
  | Neg of formula
  | Equiv of formula*formula
  [@@deriving show]


type command =
  | Prove of formula
  | Quit
  | Help
  | Syntax
;;

type line =
  | Assume of formula
  | Usable of formula
  | Therefore of formula
  [@@deriving show]

  (* MS *)
let show_list_of f ls = List.fold_left  (fun lstrs l -> lstrs ^ (f l) ^ "\n") "" ls


type preuve_arbre =
  | Atome of formula
  | Bloc of formula*preuve_arbre list*formula
  [@@deriving show]


type justified_line =
    { content : line; justification : string ; premisses_list : int list}
;;



let priority_imp = 20;;
let priority_disj = 30;;
let priority_conj = 40;;
let priority_neg = 50;;
let priority_equiv = 10;;






let rec espaces n =
  (* construit une chaîne de n espaces *)
  if n < 0 then " " else make n ' ';;



let string_of_litteral f =
  (* f : formula
     résultat : une chaîne représentant f si f est un littéral
     une exception (non rattrapée) si f n'est pas un littéral
  *)
  match f with
    | Var s -> s
    | Neg (Var s) -> "-"^s
    | _ -> failwith "string_of_litteral";;


 
let string_of_formula mg md df p f =
  (* mg marge gauche
     md marge droite
     df colonne début de la formule
     p entier 
     f une formule
     résultat (cf,sf)
     la formule est mise entre parenthèses si la priorité de son
       opération principale est inférieure à p   
     la chaîne est produite de façon à ce que 
     - la première ligne de la formule commence à la colonne df
     - la dernière ligne termine à la colone cf-1
     - les lignes sauf la première commence à la colonne mg 
     - les lignes sont coupées après une opération binaire si celle-ci termine en colonne md
     
  *)
  let rec rsof df p f =
    let assocd q op g h =
      (* q dot être la priorité de l'opération représentée par la chaîne op 
       assocd affiche la formule, g op d, sachant que op est prioritaire à droite *)
      if q >= p then
	(* formule sans parenthèses *)
	( let (cfg,opg) = rsof df (q+1) g in
	  let dopd = cfg + length op+2 in
	    if dopd < md
	    then 
	      let (cfd,opd) = rsof dopd q h in
		(cfd, opg^" "^op^" "^opd)
	    else
	      let (cfd,opd) = rsof mg q h in
		(cfd, opg^" "^op^"\n"^espaces (mg-1)^opd)
	)
      else
	(* formule avec parenthèses *) 
	( let (cfg,opg) = rsof (df+1) (q+1) g in
	  let dopd = cfg + length op+2 in
	    if dopd < md
	    then 
	      let (cfd,opd) = rsof dopd q h in
		(cfd+1, "("^opg^" "^op^" "^opd^")")
	    else
	      let (cfd,opd) = rsof mg q h in
		(cfd+1, "("^opg^" "^op^"\n"^espaces (mg-1)^opd^")")
	)

    and 
      assocg q op g d =
      (* q dot être la priorité de l'opération représentée par la chaîne op 
       assocd affiche la formule, g op d, sachant que op est prioritaire à gauche *)
      if q >= p then
	(* formule sans parenthèses *)
	( let (cfg,opg) = rsof df q g in
	  let dopd = cfg + length op+2 in
	    if dopd < md
	    then 
	      let (cfd,opd) = rsof dopd (q+1) d in
		(cfd, opg^" "^op^" "^opd)
	    else
	      let (cfd,opd) = rsof mg (q+1) d in
		(cfd, opg^" "^op^"\n"^espaces (mg-1)^opd)
	)
      else
	(* formule avec parenthèses *) 
	( let (cfg,opg) = rsof (df+1) q g in
	  let dopd = cfg + length op+2 in
	    if dopd < md
	    then 
	      let (cfd,opd) = rsof dopd (q+1) d in
		(cfd+1, "("^opg^" "^op^" "^opd^")")
	    else
	      let (cfd,opd) = rsof mg (q+1) d in
		(cfd+1, "("^opg^" "^op^"\n"^espaces (mg-1)^opd^")")
	)
    and
      unaire q op d =
      (* q est la priorité de l'opération représentée par la chaîne op 
	 unaire affiche la formule, op d *)
      if q >= p then
	(* formule sans parenthèses *)
	let (cfd,opd) = rsof (df+length op) q d
	in (cfd,op^opd)
      else 
	(* formule avec parenthèses *)
	let (cfd,opd) = rsof (df+1+length op) q d
	in (cfd+1,"("^op^opd^")")

	      
    in match f with
      | Var s -> (df+length s,s)
      | False -> (df+1,"F")
      | Imp (g,d) -> assocd priority_imp "=>" g d
      | Disj (g,d) -> assocg priority_disj "+" g d
      | Conj (g,d) -> assocg priority_conj "&" g d
      | Equiv (g,d) ->assocg priority_equiv "<=>" g d 
      | Neg d -> unaire priority_neg "-" d
  in rsof df p f
;;



(* MS *)

let paren_prio curr_prio context_prio s = 
  if curr_prio > context_prio 
  then s
  else "(" ^ s ^ ")"

let rec string_of_formula_simple context_prio = function 
| Var x -> x
| False -> "F"
| Imp (f1, f2) -> paren_prio priority_imp  context_prio (string_of_formula_simple priority_imp f1 ^ " => " ^  string_of_formula_simple  priority_imp f2)
| Disj (f1, f2) -> paren_prio priority_disj context_prio (string_of_formula_simple  priority_disj f1 ^ " + " ^  string_of_formula_simple priority_disj f2)
| Conj (f1, f2) -> paren_prio priority_conj context_prio (string_of_formula_simple priority_conj f1 ^ " & " ^ string_of_formula_simple  priority_conj f2)
| Neg (f) -> paren_prio priority_neg context_prio ("- " ^ string_of_formula_simple priority_neg f)
| Equiv (f1, f2) -> paren_prio priority_equiv context_prio (string_of_formula_simple priority_equiv f1 ^ " <=> " ^ string_of_formula_simple priority_equiv f2)

let indent_factor = 3
let indent ind s = (espaces (indent_factor * ind)) ^ s

let rec string_of_preuve_arbre ind = function
| Atome f -> indent ind (string_of_formula_simple 0 f)
| Bloc (fa, pas, fc) -> 
  indent ind ("(" ^ "assume " ^ string_of_formula_simple 0 fa ^ "\n") ^
            (show_list_of (string_of_preuve_arbre (ind + 1)) pas) ^
  indent ind ("therefore " ^ string_of_formula_simple 0 fc ^ ")\n")
