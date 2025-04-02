
type vname = string   (* names for variables ... *)
  [@@deriving show]

  (* binary logic operators *)
type binop = Band | Bor | Bimpl
  [@@deriving show]

type expr
    = Const of bool                     (* Constant *)
    | Var of vname                      (* Variable *)
    | Neg of expr                       (* Negation *)
    | BinOp of binop * expr * expr       (* Binary operation *)
[@@deriving show]

let show_binop = function
    Band -> "&&"
  | Bor -> "||"
  | Bimpl -> "->"    


let rec show_expr = function
    Const b -> string_of_bool b
  | Var v -> " " ^ v ^ " "
  | Neg e -> " (! " ^ (show_expr e) ^ ") "
  | BinOp (bop, e1, e2) -> " (" ^ (show_expr e1) ^ show_binop bop ^ (show_expr e2) ^ ") "


    
